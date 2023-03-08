CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE DATABASE nexvidplus;
CREATE SCHEMA nexvidplus_na;

CREATE TYPE content_genre AS ENUM ('Action', 'Adventure', 'Animation', 'Biography', 'Comedy', 'Crime', 'Documentary', 'Drama', 'Family', 'Fantasy', 'Film Noir', 'History', 'Horror', 'Music', 'Musical', 'Mystery', 'Romance', 'Sci-Fi', 'Short', 'Sport', 'Superhero', 'Thriller', 'War', 'Western');
CREATE TYPE content_format AS ENUM ('Movie', 'TV Show', 'Documentary', 'Short Film', 'Web Series');
CREATE TYPE content_rating AS ENUM ('G', 'PG', 'PG-13', 'R', 'NC-17', 'TV-Y', 'TV-Y7', 'TV-G', 'TV-PG', 'TV-14', 'TV-MA');
CREATE TYPE content_type AS ENUM ('SD', 'HD', 'UHD');
CREATE TYPE device_type AS ENUM ('Computer', 'Mobile', 'Tablet', 'Smart TV', 'Game Console');
CREATE TYPE thumb_rating AS ENUM ('Down', 'Middle', 'Up');

CREATE TABLE account
(
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(60)  NOT NULL,
    created_at    TIMESTAMPTZ  NOT NULL,
    updated_at    TIMESTAMPTZ  NOT NULL
);

CREATE TABLE sub_account
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

CREATE TABLE content
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

CREATE TABLE login_history
(
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id       UUID         NOT NULL REFERENCES account (id),
    device_type      device_type  NOT NULL,
    device_signature VARCHAR(255) NOT NULL,
    ip_address       INET         NOT NULL,
    created_at       TIMESTAMPTZ  NOT NULL
);

CREATE TABLE watch_list
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

CREATE TABLE wish_list
(
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sub_account_id UUID REFERENCES sub_account (id) ON DELETE CASCADE,
    content_id     UUID        NOT NULL REFERENCES content (id) ON DELETE CASCADE,
    created_at     TIMESTAMPTZ NOT NULL
);

CREATE TABLE subscription
(
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID        NOT NULL REFERENCES account (id) ON DELETE CASCADE,
    start_date TIMESTAMPTZ NOT NULL,
    end_date   TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ      DEFAULT NOW(),
    updated_at TIMESTAMPTZ      DEFAULT NOW()
);