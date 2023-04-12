CREATE DATABASE nexvidplus; -- WITH OWNER?

-- TODO create users

\c nextvidplus

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE SCHEMA IF NOT EXISTS nexvidplus_us;

-- TODO GRANT privileges

CREATE TYPE nexvidplus_us.content_genre AS ENUM ('ACTION', 'ADVENTURE', 'ANIMATION', 'BIOGRAPHY', 'COMEDY', 'CRIME', 'DOCUMENTARY', 'DRAMA', 'FAMILY', 'FANTASY', 'FILM_NOIR', 'HISTORY', 'HORROR', 'MUSIC', 'MUSICAL', 'MYSTERY', 'ROMANCE', 'SCI_FI', 'SHORT', 'SPORT', 'SUPERHERO', 'THRILLER', 'WAR', 'WESTERN');
CREATE TYPE nexvidplus_us.content_format AS ENUM ('MOVIE', 'TV_SHOW', 'DOCUMENTARY', 'SHORT_FILM', 'WEB_SERIES');
CREATE TYPE nexvidplus_us.content_rating AS ENUM ('G', 'PG', 'PG_13', 'R', 'NC_17', 'TV_Y', 'TV_Y_7', 'TV_G', 'TV_PG', 'TV_14', 'TV_MA');
CREATE TYPE nexvidplus_us.content_type AS ENUM ('SD', 'HD', 'UHD');
CREATE TYPE nexvidplus_us.device_type AS ENUM ('COMPUTER', 'MOBILE', 'TABLET', 'SMART_TV', 'GAME_CONSOLE');
CREATE TYPE nexvidplus_us.thumb_rating AS ENUM ('DOWN', 'MIDDLE', 'UP');

CREATE TABLE nexvidplus_us.account
(
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(60)  NOT NULL,
    created_at    TIMESTAMPTZ  NOT NULL,
    updated_at    TIMESTAMPTZ  NOT NULL
);

CREATE TABLE nexvidplus_us.sub_account
(
    id         UUID                 DEFAULT uuid_generate_v4(),
    account_id UUID        NOT NULL REFERENCES account (id) ON DELETE CASCADE,
    name       VARCHAR(50) NOT NULL,
    is_child   BOOLEAN     NOT NULL DEFAULT false,
    avatar_url VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id, account_id)
);

CREATE TABLE nexvidplus_us.content
(
    id               UUID PRIMARY KEY      DEFAULT uuid_generate_v4(),
    genre            content_genre,
    content_type     content_type,
    content_format   content_format,
    content_rating   content_rating,
    title            VARCHAR(255) NOT NULL,
    description      TEXT,
    release_date     DATE,
    duration_seconds INTEGER,
    attributes       JSONB,
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE nexvidplus_us.login_history
(
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id       UUID         NOT NULL REFERENCES account (id),
    device_type      device_type  NOT NULL,
    device_signature VARCHAR(255) NOT NULL,
    ip_address       INET         NOT NULL,
    created_at       TIMESTAMPTZ  NOT NULL
);

CREATE TABLE nexvidplus_us.watch_list
(
    id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sub_account_id    UUID REFERENCES sub_account (id) ON DELETE CASCADE,
    content_id        UUID NOT NULL REFERENCES content (id) ON DELETE CASCADE,
    resume_at_seconds INTEGER          DEFAULT 0,
    completed_views   INTEGER          DEFAULT 0,
    thumb_rating      thumb_rating,
    created_at        TIMESTAMPTZ      DEFAULT NOW(),
    updated_at        TIMESTAMPTZ      DEFAULT NOW()
);

CREATE TABLE nexvidplus_us.wish_list
(
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sub_account_id UUID REFERENCES sub_account (id) ON DELETE CASCADE,
    content_id     UUID        NOT NULL REFERENCES content (id) ON DELETE CASCADE,
    created_at     TIMESTAMPTZ NOT NULL
);

CREATE TABLE nexvidplus_us.subscription
(
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID        NOT NULL REFERENCES account (id) ON DELETE CASCADE,
    start_date TIMESTAMPTZ NOT NULL,
    end_date   TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ      DEFAULT NOW(),
    updated_at TIMESTAMPTZ      DEFAULT NOW()
);