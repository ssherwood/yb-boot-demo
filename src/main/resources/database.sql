--- CREATE ENUM TYPES

create type account_status as enum('ACTIVE', 'INACTIVE', 'TRIAL', 'BANNED');
create type account_type as enum('ADMIN', 'SUPPORT', 'USER');
create type option_code_external as enum('EXT_OPT_A', 'EXT_OPT_B', 'EXT_OPT_C', 'EXT_OPT_D');
create type option_code_internal as enum('INT_OPT_A', 'INT_OPT_B', 'INT_OPT_C', 'INT_OPT_Z');
create type issue_type as enum('INCIDENT', 'SERVICE', 'PROBLEM', 'CHANGE');
create type option_state as enum('ACTIVE', 'INACTIVE', 'TRIAL');
create type origin_code as enum('ORIGIN_A', 'ORIGIN_B', 'ORIGIN_C');
create type product_code as enum('PROD_A', 'PROD_B', 'PROD_C');
create type profile_type as enum('ADULT', 'TEEN', 'CHILD');
create type region_code as enum('USA', 'CAN', 'MEX');
create type media_type as enum('ACTION', 'COMEDY', 'DOCUMENTARY', 'DRAMA', 'ROMANCE');

create table yb_user
(
    id               bigserial primary key,
    created_date     timestamptz    not null default current_timestamp,
    updated_date     timestamptz    not null default current_timestamp,
    email            varchar(100)   not null unique,
    display_name     varchar(25)    not null unique,
    type             account_type   not null default 'USER',
    status           account_status not null default 'TRIAL',
    region           region_code    not null,
    password_hash    text           not null,
    avatar_url       text           not null,
    full_name        text,
    phone_number     varchar(42),
    birth_date       date,
    last_active_date timestamptz    not null default current_timestamp
) SPLIT INTO 100 TABLETS;

create table yb_user_attr
(
    id           bigserial primary key,
    user_id      bigint      not null,
    created_date timestamptz not null default current_timestamp,
    updated_date timestamptz not null default current_timestamp,
    attributes   jsonb,
    constraint fk_user_id foreign key (user_id) references yb_user (id) on delete cascade
) SPLIT INTO 100 TABLETS;

create table yb_user_issue
(
    id           bigserial primary key,
    user_id      bigint      not null,
    created_date timestamptz not null default current_timestamp,
    updated_date timestamptz not null default current_timestamp,
    isssue_type  issue_type  not null default 'INCIDENT',
    resolved     boolean     not null default false,
    constraint fk_user_id foreign key (user_id) references yb_user (id) on delete cascade
) SPLIT INTO 100 TABLETS;

create table yb_user_subscription
(
    id                    bigserial primary key,
    user_id               bigint      not null,
    created_date          timestamptz not null default current_timestamp,
    updated_date          timestamptz not null default current_timestamp,
    source                varchar,
    active                boolean              default true,
    start_date            date        not null default current_date,
    end_date              date,
    product               product_code,
    origin                origin_code,
    origin_transaction_id text,
    constraint fk_user_id foreign key (user_id) references yb_user (id) on delete cascade
) SPLIT INTO 100 TABLETS;

create table yb_user_subscription_option
(
    id                      bigserial primary key,
    user_subscription_id    bigint       not null,
    created_date            timestamptz  not null default current_timestamp,
    updated_date            timestamptz  not null default current_timestamp,
    status                  option_state not null default 'ACTIVE',
    external_feature_option option_code_external,
    internal_feature_option option_code_internal,
    constraint fk_user_subscription_id foreign key (user_subscription_id) references yb_user_subscription (id) on delete cascade
) SPLIT INTO 100 TABLETS;

create table yb_user_profile
(
    id           bigint primary key,
    created_date timestamptz  not null default current_timestamp,
    updated_date timestamptz  not null default current_timestamp,
    user_id      bigint       not null,
    name         text         not null,
    main         boolean      not null default false,
    active       boolean      not null default true,
    deleted      boolean      not null default false,
    type         profile_type not null default 'ADULT',
    picture_url  text,
    constraint fk_user_id foreign key (user_id) references yb_user (id) on delete cascade
) SPLIT INTO 100 TABLETS;

create table yb_user_profile_limit
(
    id              bigserial primary key,
    user_profile_id bigint,
    enabled         boolean default false,
    limit_seconds   int     default 0,
    constraint fk_user_profile_id foreign key (user_profile_id) references yb_user_profile (id) on delete cascade
) SPLIT INTO 100 TABLETS;

create table yb_user_proxy_allow
(
    id           bigserial primary key,
    created_date timestamptz not null default current_timestamp,
    updated_date timestamptz not null default current_timestamp,
    user_id      bigint      not null,
    owner        varchar,
    region       varchar,
    constraint fk_user_id foreign key (user_id) references yb_user (id) on delete cascade
) SPLIT INTO 100 TABLETS;

create table yb_device
(
    id            bigserial primary key,
    created_date  timestamptz not null default current_timestamp,
    updated_date  timestamptz not null default current_timestamp,
    model         text,
    partner_id    bigint      not null,
    partner_token text        not null,
    secret        text        not null,
    version       varchar(30) not null,
    build_number  int,
    version_notes text,
    deprecated    boolean
) SPLIT INTO 100 TABLETS;

create table yb_notify_log
(
    id              bigserial primary key,
    ingest_date     timestamptz,
    notification    varchar(255),
    subscription_id varchar(255),
    user_id         bigint
) SPLIT INTO 100 TABLETS;

create table yb_notify_log_uuid
(
    id              UUID primary key,
    ingest_date     timestamptz,
    notification    varchar(255),
    subscription_id varchar(255),
    user_id         bigint
) SPLIT INTO 100 TABLETS;

-- TODO this probably needs a "media" table for FK
create table yb_watch_list
(
    id              bigserial primary key,
    created_date    timestamptz not null default current_timestamp,
    updated_date    timestamptz not null default current_timestamp,
    user_profile_id bigint,
    media_id        bigint,
    watch_type      media_type,
    constraint fk_user_profile_id foreign key (user_profile_id) references yb_user_profile (id) on delete cascade
) SPLIT INTO 100 TABLETS;

create table yb_subscription_log
(
    external_subscription_id varchar(255) primary key,
    partner_id               varchar(255),
    subscription_id          varchar(255),
    created_date             timestamptz  not null default current_timestamp,
    updated_date             timestamptz  not null default current_timestamp,
    registration_status      option_state not null default 'INACTIVE',
    start_date               timestamptz,
    end_date                 timestamptz
) SPLIT INTO 100 TABLETS;

create index on yb_subscription_log(partner_id) split into 100 tablets;

-- create tablespace "geo_east4a" with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-east4", "zone" : "us-east4-a", "min_num_replicas" : 1}]}');
-- create tablespace "geo_east4b" with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-east4", "zone" : "us-east4-b", "min_num_replicas" : 1}]}');
-- create tablespace "geo_central1a" with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-central1", "zone" : "us-central1-a", "min_num_replicas" : 1}]}');
-- create tablespace "geo_central1b" with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-central1", "zone" : "us-central1-b", "min_num_replicas" : 1}]}');
--
-- create unique index geo_email_e4a on yb_user (email) include(id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "geo_east4a";
-- create unique index geo_email_e4b on yb_user (email) include(id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "geo_east4b";
-- create unique index geo_email_c1a on yb_user (email) include(id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "geo_central1a";
-- create unique index geo_email_c1b on yb_user (email) include(id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "geo_central1b";
--
--
--
-- create tablespace "geo_east1c" with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-east1", "zone" : "us-east1-c", "min_num_replicas" : 3}]}');
-- create tablespace "geo_east1d" with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-east1", "zone" : "us-east1-d", "min_num_replicas" : 3}]}');
-- create tablespace "geo_central1c" with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-central1", "zone" : "us-central1-c", "min_num_replicas" : 3}]}');
-- create tablespace "geo_central1f" with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-central1", "zone" : "us-central1-f", "min_num_replicas" : 3}]}');
--
-- create unique index geo_email_e1c on yb_user (email) include(id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "geo_east1c" split into 100 tablets;
-- create unique index geo_email_e1d on yb_user (email) include(id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "geo_east1d" split into 100 tablets;
-- create unique index geo_email_c1c on yb_user (email) include(id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "geo_central1c" split into 100 tablets;
-- create unique index geo_email_c1f on yb_user (email) include(id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "geo_central1f" split into 100 tablets;
