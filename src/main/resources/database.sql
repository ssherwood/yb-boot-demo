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
    id           bigserial primary key,
    model        text,
    version      int          not null default 0,
    created_date timestamptz  not null default current_timestamp,
    created_by   varchar(100) not null default current_user,
    updated_date timestamptz  not null default current_timestamp,
    updated_by   varchar(100) not null default current_user
) SPLIT INTO 1 TABLETS;

-- insert into yb_device(model, version) select 'model'||seq, 1 from generate_series(1,1500) as seq;

create table yb_device_version
(
    id            bigserial primary key,
    device_id     bigint,
    model         text,
    version       int          not null default 0,
    build_number  int          not null default 0,
    version_notes text,
    partner_id    bigint       not null,
    partner_token text         not null,
    secret        text         not null,
    deprecated    boolean      not null default false,
    created_date  timestamptz  not null default current_timestamp,
    created_by    varchar(100) not null default current_user,
    updated_date  timestamptz  not null default current_timestamp,
    updated_by    varchar(100) not null default current_user,
    constraint yb_device_version_device_id_fkey foreign key (device_id) references yb_device (id)
) SPLIT INTO 1 TABLETS;

---  insert into yb_device_version(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated) select seq, 'model'||seq, 1, 1, 'Notes:'||seq, 1, 'token', 'secret', false from generate_series(1,1500) as seq;

create table yb_device_model
(
    device_id bigint,
    model     text,
    primary key (device_id, model),
    constraint yb_device_model_device_id_fkey foreign key (device_id) references yb_device (id)
) SPLIT INTO 1 TABLETS;

---  insert into yb_device_model(device_id, model) select seq, 'model'||seq from generate_series(1, 1500) as seq;

create table yb_device_model_version
(
    version_id bigint,
    model      text,
    primary key (version_id, model),
    constraint yb_device_model_version_id_fkey foreign key (version_id) references yb_device_version (id)
) SPLIT INTO 1 TABLETS;

---  insert into yb_device_model_version(version_id, model) select seq, 'model'||seq from generate_series(1, 1500) as seq;

--- yugabyte=# create tablespace geo_gcp_uswest1_1a with (replica_placement='{"num_replicas" : 1, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-west1", "zone" : "us-west1-a", "min_num_replicas" : 1}]}');
--- CREATE TABLESPACE
--- yugabyte=# create tablespace geo_gcp_uscentra1_1a with (replica_placement='{"num_replicas" : 1, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-central1", "zone" : "us-central1-a", "min_num_replicas" : 1}]}');
--- CREATE TABLESPACE
--- yugabyte=# create tablespace geo_gcp_uscentra1_1b with (replica_placement='{"num_replicas" : 1, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-central1", "zone" : "us-central1-b", "min_num_replicas" : 1}]}');
--- CREATE TABLESPACE
--- yugabyte=# create tablespace geo_gcp_useast4_4a with (replica_placement='{"num_replicas" : 1, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-east4", "zone" : "us-east4-a", "min_num_replicas" : 1}]}');
--- CREATE TABLESPACE
--- yugabyte=# create tablespace geo_gcp_useast4_4b with (replica_placement='{"num_replicas" : 1, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-east4", "zone" : "us-east4-b", "min_num_replicas" : 1}]}');
--- CREATE TABLESPACE

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
