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

create index yb_device_model_idx on yb_device(model asc) including(model, version, created_date, updated_date, updated_by) split into 1 tablets;

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

CREATE TABLE yb_device_tracker (
    device_id uuid NOT NULL,
    media_id text NOT NULL,
    status varchar(16) NOT NULL,
    created_date timestamptz NOT NULL default current_timestamp,
    updated_date timestamptz NOT NULL default current_timestamp,
    CONSTRAINT yb_device_tracker_pkey PRIMARY KEY(device_id HASH, media_id ASC)
) SPLIT INTO 100 TABLETS;

create index on yb_device_tracker(updated_date) split into 100 tablets;

-- load
insert into yb_device_tracker (device_id, media_id, status)
select uuid('cdd7cacd-8e0a-4372-8ceb-'||lpad(seq::text, 12, '0')),
       '48d1c2c2-0d83-43d9-'||lpad(seq2::text,4,'0')||'-'||lpad(seq::text, 12, '0'),
       'ACTIVE'||seq
from generate_series(1,11000) as seq, generate_series(1,60) seq2;

-- load data into the devices tables

insert into yb_device(model, version) select 'model'||seq, 1 from generate_series(1,1500) as seq;
insert into yb_device_version(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated) select seq, 'model'||seq, 1, 1, 'Notes:'||seq, 1, 'token', 'secret', false from generate_series(1,1500) as seq;
insert into yb_device_model(device_id, model) select seq, 'model'||seq from generate_series(1, 1500) as seq;
insert into yb_device_model_version(version_id, model) select seq, 'model'||seq from generate_series(1, 1500) as seq;



-- special tablespaces for regional covering indexes

CREATE TABLESPACE east1_ts_rf5 WITH (replica_placement='{ "num_replicas": 5, "placement_blocks": [ { "cloud": "gcp", "region": "us-east1", "zone": "us-east1-c", "min_num_replicas": 1, "leader_preference": 1 }, { "cloud": "gcp", "region": "us-east1", "zone": "us-east1-d", "min_num_replicas": 1, "leader_preference": 1 }, { "cloud": "gcp", "region": "us-central1", "zone": "us-central1-c", "min_num_replicas": 1, "leader_preference": 2 }, { "cloud": "gcp", "region": "us-central1", "zone": "us-central1-f", "min_num_replicas": 1, "leader_preference": 2 }, { "cloud": "gcp", "region": "us-west1", "zone": "us-west1-c", "min_num_replicas": 1, "leader_preference": 3 } ]}');
CREATE TABLESPACE central1_ts_rf5 WITH (replica_placement='{ "num_replicas": 5, "placement_blocks": [ { "cloud": "gcp", "region": "us-central1", "zone": "us-central1-c", "min_num_replicas": 1, "leader_preference": 1 }, { "cloud": "gcp", "region": "us-central1", "zone": "us-central1-f", "min_num_replicas": 1, "leader_preference": 1 }, { "cloud": "gcp", "region": "us-east1", "zone": "us-east1-c", "min_num_replicas": 1, "leader_preference": 2 }, { "cloud": "gcp", "region": "us-east1", "zone": "us-east1-d", "min_num_replicas": 1, "leader_preference": 2 }, { "cloud": "gcp", "region": "us-west1", "zone": "us-west1-c", "min_num_replicas": 1, "leader_preference": 3 } ]}');
CREATE TABLESPACE west1_ts_rf5 WITH (replica_placement='{ "num_replicas": 5, "placement_blocks": [ { "cloud": "gcp", "region": "us-west1", "zone": "us-west1-c", "min_num_replicas": 1, "leader_preference": 1 }, { "cloud": "gcp", "region": "us-central1", "zone": "us-central1-d", "min_num_replicas": 1, "leader_preference": 2 }, { "cloud": "gcp", "region": "us-central1", "zone": "us-central1-f", "min_num_replicas": 1, "leader_preference": 2 }, { "cloud": "gcp", "region": "us-east1", "zone": "us-east1-c", "min_num_replicas": 1, "leader_preference": 3 }, { "cloud": "gcp", "region": "us-east1", "zone": "us-east1-d", "min_num_replicas": 1, "leader_preference": 3 } ]}');

create unique index geo_email_east1 on yb_user (email) include (id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "east1_ts_rf5" split into 100 tablets;
create unique index geo_email_central1 on yb_user (email) include (id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "central1_ts_rf5" split into 100 tablets;
create unique index geo_email_west1 on yb_user (email) include (id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "west1_ts_rf5" split into 100 tablets;

create unique index geo_device_east1 on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace "east1_ts_rf5" split into 1 tablets;
create unique index geo_device_central1 on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace "central1_ts_rf5" split into 1 tablets;
create unique index geo_device_west1 on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace "west1_ts_rf5" split into 1 tablets;

create unique index geo_device_model_east1 on yb_device_model(device_id, model) tablespace "east1_ts_rf5" split into 1 tablets;
create unique index geo_device_model_central1 on yb_device_model(device_id, model) tablespace "central1_ts_rf5" split into 1 tablets;
create unique index geo_device_model_west1 on yb_device_model(device_id, model) tablespace "west1_ts_rf5" split into 1 tablets;

create unique index geo_device_version_east1 on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace "east1_ts_rf5" split into 1 tablets;
create unique index geo_device_version_central1 on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace "central1_ts_rf5" split into 1 tablets;
create unique index geo_device_version_west1 on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace "west1_ts_rf5" split into 1 tablets;

create unique index geo_device_model_version_east1 on yb_device_model_version(version_id, model) tablespace "east1_ts_rf5" split into 1 tablets;
create unique index geo_device_model_version_central1 on yb_device_model_version(version_id, model) tablespace "central1_ts_rf5" split into 1 tablets;
create unique index geo_device_model_version_west1 on yb_device_model_version(version_id, model) tablespace "west1_ts_rf5" split into 1 tablets;


drop index geo_email_east1;
drop index geo_email_central1;
drop index geo_email_west1;

drop index geo_device_east1;
drop index geo_device_central1;
drop index geo_device_west1;

drop index geo_device_model_east1;
drop index geo_device_model_central1;
drop index geo_device_model_west1;

drop index geo_device_version_east1;
drop index geo_device_version_central1;
drop index geo_device_version_west1;

drop index geo_device_model_version_east1;
drop index geo_device_model_version_central1;
drop index geo_device_model_version_west1;



-- old dysfunctional tablespace/index
create tablespace geo_us_e1c with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-east1", "zone" : "us-east1-c", "min_num_replicas" : 1}]}');
create tablespace geo_us_e1d with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-east1", "zone" : "us-east1-d", "min_num_replicas" : 1}]}');
create tablespace geo_us_c1a with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-central1", "zone" : "us-central1-a", "min_num_replicas" : 1}]}');
create tablespace geo_us_c1f with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-central1", "zone" : "us-central1-f", "min_num_replicas" : 1}]}');
create tablespace geo_us_w1a with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-west1", "zone" : "us-west1-a", "min_num_replicas" : 1}]}');

create unique index yb_d_id_geo_e1c on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace geo_us_e1c split into 1 tablets;
create unique index yb_d_id_geo_e1d on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace geo_us_e1d split into 1 tablets;
create unique index yb_d_id_geo_c1a on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace geo_us_c1a split into 1 tablets;
create unique index yb_d_id_geo_c1f on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace geo_us_c1f split into 1 tablets;
create unique index yb_d_id_geo_w1a on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace geo_us_w1a split into 1 tablets;

create unique index yb_dm_pk_geo_e1c on yb_device_model(device_id, model) tablespace geo_us_e1c split into 1 tablets;
create unique index yb_dm_pk_geo_e1d on yb_device_model(device_id, model) tablespace geo_us_e1d split into 1 tablets;
create unique index yb_dm_pk_geo_c1a on yb_device_model(device_id, model) tablespace geo_us_c1a split into 1 tablets;
create unique index yb_dm_pk_geo_c1f on yb_device_model(device_id, model) tablespace geo_us_c1f split into 1 tablets;
create unique index yb_dm_pk_geo_w1a on yb_device_model(device_id, model) tablespace geo_us_w1a split into 1 tablets;

create unique index yb_dv_pk_geo_e1c on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_e1c split into 1 tablets;
create unique index yb_dv_pk_geo_e1e on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_e1d split into 1 tablets;
create unique index yb_dv_pk_geo_c1a on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_c1a split into 1 tablets;
create unique index yb_dv_pk_geo_c1f on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_c1f split into 1 tablets;
create unique index yb_dv_pk_geo_w1a on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_w1a split into 1 tablets;

create unique index yb_dmv_pk_geo_e1c on yb_device_model_version(version_id, model) tablespace geo_us_e1c split into 1 tablets;
create unique index yb_dmv_pk_geo_e1d on yb_device_model_version(version_id, model) tablespace geo_us_e1d split into 1 tablets;
create unique index yb_dmv_pk_geo_c1a on yb_device_model_version(version_id, model) tablespace geo_us_c1a split into 1 tablets;
create unique index yb_dmv_pk_geo_c1f on yb_device_model_version(version_id, model) tablespace geo_us_c1f split into 1 tablets;
create unique index yb_dmv_pk_geo_w1a on yb_device_model_version(version_id, model) tablespace geo_us_w1a split into 1 tablets;





-- 2.14
create tablespace geo_us_e1c with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-east1", "zone" : "us-east1-c", "min_num_replicas" : 1}]}');
create tablespace geo_us_e1d with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-east1", "zone" : "us-east1-d", "min_num_replicas" : 1}]}');
create tablespace geo_us_c1c with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-central1", "zone" : "us-central1-c", "min_num_replicas" : 1}]}');
create tablespace geo_us_c1f with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-central1", "zone" : "us-central1-f", "min_num_replicas" : 1}]}');
create tablespace geo_us_w1c with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-west1", "zone" : "us-west1-c", "min_num_replicas" : 1}]}');

create unique index yb_d_id_geo_e1c on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace geo_us_e1c split into 1 tablets;
create unique index yb_d_id_geo_e1d on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace geo_us_e1d split into 1 tablets;
create unique index yb_d_id_geo_c1c on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace geo_us_c1c split into 1 tablets;
create unique index yb_d_id_geo_c1f on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace geo_us_c1f split into 1 tablets;
create unique index yb_d_id_geo_w1c on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace geo_us_w1c split into 1 tablets;

create unique index yb_dm_pk_geo_e1c on yb_device_model(device_id, model) tablespace geo_us_e1c split into 1 tablets;
create unique index yb_dm_pk_geo_e1d on yb_device_model(device_id, model) tablespace geo_us_e1d split into 1 tablets;
create unique index yb_dm_pk_geo_c1c on yb_device_model(device_id, model) tablespace geo_us_c1c split into 1 tablets;
create unique index yb_dm_pk_geo_c1f on yb_device_model(device_id, model) tablespace geo_us_c1f split into 1 tablets;
create unique index yb_dm_pk_geo_w1c on yb_device_model(device_id, model) tablespace geo_us_w1c split into 1 tablets;

create unique index yb_dv_pk_geo_e1c on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_e1c split into 1 tablets;
create unique index yb_dv_pk_geo_e1d on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_e1d split into 1 tablets;
create unique index yb_dv_pk_geo_c1c on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_c1c split into 1 tablets;
create unique index yb_dv_pk_geo_c1f on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_c1f split into 1 tablets;
create unique index yb_dv_pk_geo_w1c on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_w1c split into 1 tablets;

create unique index yb_dmv_pk_geo_e1c on yb_device_model_version(version_id, model) tablespace geo_us_e1c split into 1 tablets;
create unique index yb_dmv_pk_geo_e1d on yb_device_model_version(version_id, model) tablespace geo_us_e1d split into 1 tablets;
create unique index yb_dmv_pk_geo_c1c on yb_device_model_version(version_id, model) tablespace geo_us_c1c split into 1 tablets;
create unique index yb_dmv_pk_geo_c1f on yb_device_model_version(version_id, model) tablespace geo_us_c1f split into 1 tablets;
create unique index yb_dmv_pk_geo_w1c on yb_device_model_version(version_id, model) tablespace geo_us_w1c split into 1 tablets;


create tablespace geo_us_e1c with (replica_placement='{"num_replicas" : 1, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-east1", "zone" : "us-east1-c", "min_num_replicas" : 1}]}');
create tablespace geo_us_e1d with (replica_placement='{"num_replicas" : 1, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-east1", "zone" : "us-east1-d", "min_num_replicas" : 1}]}');
create tablespace geo_us_c1c with (replica_placement='{"num_replicas" : 1, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-central1", "zone" : "us-central1-c", "min_num_replicas" : 1}]}');
create tablespace geo_us_c1f with (replica_placement='{"num_replicas" : 1, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-central1", "zone" : "us-central1-f", "min_num_replicas" : 1}]}');
create tablespace geo_us_w1c with (replica_placement='{"num_replicas" : 1, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-west1", "zone" : "us-west1-c", "min_num_replicas" : 1}]}');


-- 1
-- select d1_0.id,d1_0.created_by,d1_0.created_date,d1_0.model,d1_0.updated_by,d1_0.updated_date,d1_0.version from yb_device d1_0 order by d1_0.model asc
--
-- plan?


-- 2
-- yugabyte=# explain analyze select d1_0.device_id,d1_0.model from yb_device_model d1_0 where d1_0.device_id in(select d2_0.id from yb_device d2_0);
--                                                                         QUERY PLAN
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------
--  Hash Join  (cost=120.50..231.14 rows=1000 width=40) (actual time=18.758..20.031 rows=1500 loops=1)
--    Hash Cond: (d1_0.device_id = d2_0.id)
--    ->  Index Only Scan using yb_dm_pk_geo_c1f on yb_device_model d1_0  (cost=0.00..108.00 rows=1000 width=40) (actual time=7.461..8.350 rows=1500 loops=1)
--          Heap Fetches: 0
--    ->  Hash  (cost=108.00..108.00 rows=1000 width=8) (actual time=11.256..11.256 rows=1500 loops=1)
--          Buckets: 2048 (originally 1024)  Batches: 1 (originally 1)  Memory Usage: 75kB
--          ->  Index Only Scan using yb_d_id_geo_c1f on yb_device d2_0  (cost=0.00..108.00 rows=1000 width=8) (actual time=6.752..10.891 rows=1500 loops=1)
--                Heap Fetches: 0
--  Planning Time: 0.720 ms
--  Execution Time: 20.201 ms
--  Peak Memory Usage: 271 kB
-- (11 rows)

-- 3
--
-- (normal)
-- yugabyte=# explain analyze select d1_0.id,d1_0.build_number,d1_0.created_by,d1_0.created_date,d1_0.deprecated,d1_0.model,d1_0.partner_id,d1_0.partner_token,d1_0.secret,d1_0.updated_by,d1_0.updated_date,d1_0.version,d1_0.version_notes from yb_device_version d1_0 where d1_0.deprecated=false and d1_0.id in(select d2_0.id from yb_device d2_0);
--                                                                            QUERY PLAN
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Hash Join  (cost=120.50..231.14 rows=1000 width=605) (actual time=71.992..76.966 rows=1500 loops=1)
--    Hash Cond: (d1_0.id = d2_0.id)
--    ->  Index Only Scan using yb_dv_pk_geo_c1f on yb_device_version d1_0  (cost=0.00..108.00 rows=1000 width=605) (actual time=35.325..39.646 rows=1500 loops=1)
--          Filter: (NOT deprecated)
--          Heap Fetches: 0
--    ->  Hash  (cost=108.00..108.00 rows=1000 width=8) (actual time=36.626..36.626 rows=1500 loops=1)
--          Buckets: 2048 (originally 1024)  Batches: 1 (originally 1)  Memory Usage: 75kB
--          ->  Index Only Scan using yb_d_id_geo_c1f on yb_device d2_0  (cost=0.00..108.00 rows=1000 width=8) (actual time=25.050..36.124 rows=1500 loops=1)
--                Heap Fetches: 0
--  Planning Time: 0.866 ms
--  Execution Time: 77.160 ms
--  Peak Memory Usage: 464 kB
-- (12 rows)
--
-- (abnormal)
-- yugabyte=# explain analyze select d1_0.id,d1_0.build_number,d1_0.created_by,d1_0.created_date,d1_0.deprecated,d1_0.model,d1_0.partner_id,d1_0.partner_token,d1_0.secret,d1_0.updated_by,d1_0.updated_date,d1_0.version,d1_0.version_notes from yb_device_version d1_0 where d1_0.deprecated=false and d1_0.id in(select d2_0.id from yb_device d2_0);
--                                                                             QUERY PLAN
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Hash Join  (cost=120.50..231.14 rows=1000 width=605) (actual time=38.017..4815.525 rows=1500 loops=1)
--    Hash Cond: (d1_0.id = d2_0.id)
--    ->  Index Only Scan using yb_dv_pk_geo_c1f on yb_device_version d1_0  (cost=0.00..108.00 rows=1000 width=605) (actual time=22.909..4799.931 rows=1500 loops=1)
--          Filter: (NOT deprecated)
--          Heap Fetches: 0
--    ->  Hash  (cost=108.00..108.00 rows=1000 width=8) (actual time=15.067..15.068 rows=1500 loops=1)
--          Buckets: 2048 (originally 1024)  Batches: 1 (originally 1)  Memory Usage: 75kB
--          ->  Index Only Scan using yb_d_id_geo_c1f on yb_device d2_0  (cost=0.00..108.00 rows=1000 width=8) (actual time=8.733..14.657 rows=1500 loops=1)
--                Heap Fetches: 0
--  Planning Time: 0.824 ms
--  Execution Time: 4815.696 ms
--  Peak Memory Usage: 377 kB
-- (12 rows)
--
-- 4.
--
-- (normal)
-- yugabyte=# explain analyze select d1_0.model,d1_0.version_id from yb_device_model_version d1_0 where d1_0.version_id in(select d2_0.id from yb_device_version d2_0 where d2_0.deprecated=false and d2_0.id in(select d3_0.id from yb_device d3_0));
--                                                                                 QUERY PLAN
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Hash Semi Join  (cost=243.64..359.82 rows=500 width=40) (actual time=64.506..65.929 rows=1500 loops=1)
--    Hash Cond: (d1_0.version_id = d2_0.id)
--    ->  Index Only Scan using yb_dmv_pk_geo_c1f on yb_device_model_version d1_0  (cost=0.00..108.00 rows=1000 width=40) (actual time=5.876..6.836 rows=1500 loops=1)
--          Heap Fetches: 0
--    ->  Hash  (cost=231.14..231.14 rows=1000 width=16) (actual time=58.494..58.494 rows=1500 loops=1)
--          Buckets: 2048 (originally 1024)  Batches: 1 (originally 1)  Memory Usage: 87kB
--          ->  Hash Join  (cost=120.50..231.14 rows=1000 width=16) (actual time=54.489..58.132 rows=1500 loops=1)
--                Hash Cond: (d2_0.id = d3_0.id)
--                ->  Index Only Scan using yb_dv_pk_geo_c1f on yb_device_version d2_0  (cost=0.00..108.00 rows=1000 width=8) (actual time=35.332..38.430 rows=1500 loops=1)
--                      Filter: (NOT deprecated)
--                      Heap Fetches: 0
--                ->  Hash  (cost=108.00..108.00 rows=1000 width=8) (actual time=19.116..19.116 rows=1500 loops=1)
--                      Buckets: 2048 (originally 1024)  Batches: 1 (originally 1)  Memory Usage: 75kB
--                      ->  Index Only Scan using yb_d_id_geo_c1f on yb_device d3_0  (cost=0.00..108.00 rows=1000 width=8) (actual time=13.361..18.778 rows=1500 loops=1)
--                            Heap Fetches: 0
--  Planning Time: 2.113 ms
--  Execution Time: 66.128 ms
--  Peak Memory Usage: 673 kB
-- (18 rows)
--
-- (abnormal)
-- yugabyte=# explain analyze select d1_0.model,d1_0.version_id from yb_device_model_version d1_0 where d1_0.version_id in(select d2_0.id from yb_device_version d2_0 where d2_0.deprecated=false and d2_0.id in(select d3_0.id from yb_device d3_0));
--                                                                                  QUERY PLAN
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Hash Semi Join  (cost=243.64..359.82 rows=500 width=40) (actual time=5046.574..5047.820 rows=1500 loops=1)
--    Hash Cond: (d1_0.version_id = d2_0.id)
--    ->  Index Only Scan using yb_dmv_pk_geo_c1f on yb_device_model_version d1_0  (cost=0.00..108.00 rows=1000 width=40) (actual time=6.286..7.162 rows=1500 loops=1)
--          Heap Fetches: 0
--    ->  Hash  (cost=231.14..231.14 rows=1000 width=16) (actual time=5040.253..5040.253 rows=1500 loops=1)
--          Buckets: 2048 (originally 1024)  Batches: 1 (originally 1)  Memory Usage: 87kB
--          ->  Hash Join  (cost=120.50..231.14 rows=1000 width=16) (actual time=57.185..5039.797 rows=1500 loops=1)
--                Hash Cond: (d2_0.id = d3_0.id)
--                ->  Index Only Scan using yb_dv_pk_geo_c1f on yb_device_version d2_0  (cost=0.00..108.00 rows=1000 width=8) (actual time=41.449..5023.306 rows=1500 loops=1)
--                      Filter: (NOT deprecated)
--                      Heap Fetches: 0
--                ->  Hash  (cost=108.00..108.00 rows=1000 width=8) (actual time=15.698..15.698 rows=1500 loops=1)
--                      Buckets: 2048 (originally 1024)  Batches: 1 (originally 1)  Memory Usage: 75kB
--                      ->  Index Only Scan using yb_d_id_geo_c1f on yb_device d3_0  (cost=0.00..108.00 rows=1000 width=8) (actual time=10.119..15.194 rows=1500 loops=1)
--                            Heap Fetches: 0
--  Planning Time: 1.427 ms
--  Execution Time: 5047.993 ms
--  Peak Memory Usage: 585 kB
-- (18 rows)



-- 2.16
create tablespace geo_us_e4a with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-east4", "zone" : "us-east4-a", "min_num_replicas" : 1}]}');
create tablespace geo_us_e4b with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-east4", "zone" : "us-east4-b", "min_num_replicas" : 1}]}');
create tablespace geo_us_c1a with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-central1", "zone" : "us-central1-a", "min_num_replicas" : 1}]}');
create tablespace geo_us_c1b with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-central1", "zone" : "us-central1-b", "min_num_replicas" : 1}]}');
create tablespace geo_us_w1a with (replica_placement='{"num_replicas" : 3, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-west1", "zone" : "us-west1-a", "min_num_replicas" : 1}]}');

create unique index yb_d_id_geo_e4a on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace geo_us_e4a split into 1 tablets;
create unique index yb_d_id_geo_e4b on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace geo_us_e4b split into 1 tablets;
create unique index yb_d_id_geo_c1a on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace geo_us_c1a split into 1 tablets;
create unique index yb_d_id_geo_c1b on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace geo_us_c1b split into 1 tablets;
create unique index yb_d_id_geo_w1a on yb_device(id) include(model, version, created_date, created_by, updated_date, updated_by) tablespace geo_us_w1a split into 1 tablets;

create unique index yb_dm_pk_geo_e4a on yb_device_model(device_id, model) tablespace geo_us_e4a split into 1 tablets;
create unique index yb_dm_pk_geo_e4b on yb_device_model(device_id, model) tablespace geo_us_e4b split into 1 tablets;
create unique index yb_dm_pk_geo_c1a on yb_device_model(device_id, model) tablespace geo_us_c1a split into 1 tablets;
create unique index yb_dm_pk_geo_c1b on yb_device_model(device_id, model) tablespace geo_us_c1b split into 1 tablets;
create unique index yb_dm_pk_geo_w1a on yb_device_model(device_id, model) tablespace geo_us_w1b split into 1 tablets;

create unique index yb_dv_pk_geo_e4a on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_e4a split into 1 tablets;
create unique index yb_dv_pk_geo_e4b on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_e4b split into 1 tablets;
create unique index yb_dv_pk_geo_c1a on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_c1a split into 1 tablets;
create unique index yb_dv_pk_geo_c1b on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_c1b split into 1 tablets;
create unique index yb_dv_pk_geo_w1a on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_w1a split into 1 tablets;

create unique index yb_dmv_pk_geo_e4a on yb_device_model_version(version_id, model) tablespace geo_us_e4a split into 1 tablets;
create unique index yb_dmv_pk_geo_e4b on yb_device_model_version(version_id, model) tablespace geo_us_e4b split into 1 tablets;
create unique index yb_dmv_pk_geo_c1a on yb_device_model_version(version_id, model) tablespace geo_us_c1a split into 1 tablets;
create unique index yb_dmv_pk_geo_c1b on yb_device_model_version(version_id, model) tablespace geo_us_c1b split into 1 tablets;
create unique index yb_dmv_pk_geo_w1a on yb_device_model_version(version_id, model) tablespace geo_us_w1a split into 1 tablets;

--
-- yugabyte=# set enable_nestloop to off;
-- SET
-- yugabyte=# set enable_seqscan to off;
--
-- q1
--
-- yugabyte=# explain (analyze, dist) select d1_0.id,d1_0.created_by,d1_0.created_date,d1_0.model,d1_0.updated_by,d1_0.updated_date,d1_0.version from yb_device d1_0 order by d1_0.model asc;
--                                                                    QUERY PLAN
-- -------------------------------------------------------------------------------------------------------------------------------------------------
--  Index Scan using yb_device_model_idx on yb_device d1_0  (cost=0.00..124.00 rows=1000 width=496) (actual time=89.655..122.164 rows=1500 loops=1)
--    Storage Index Read Requests: 2
--    Storage Index Execution Time: 27.000 ms
--    Storage Table Read Requests: 2
--    Storage Table Execution Time: 94.000 ms
--  Planning Time: 0.198 ms
--  Execution Time: 122.343 ms
--  Storage Read Requests: 4
--  Storage Write Requests: 0
--  Storage Execution Time: 121.000 ms
--  Peak Memory Usage: 0 kB
-- (11 rows)
--
--
--
-- q2
-- yugabyte=# explain (analyze, dist) select d1_0.device_id,d1_0.model from yb_device_model d1_0 where d1_0.device_id in(select d2_0.id from yb_device d2_0);
--                                                                         QUERY PLAN
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------
--  Hash Join  (cost=120.50..231.14 rows=1000 width=40) (actual time=15.226..16.350 rows=1500 loops=1)
--    Hash Cond: (d1_0.device_id = d2_0.id)
--    ->  Index Only Scan using yb_dm_pk_geo_c1b on yb_device_model d1_0  (cost=0.00..108.00 rows=1000 width=40) (actual time=5.025..5.726 rows=1500 loops=1)
--          Heap Fetches: 0
--          Storage Index Read Requests: 2
--          Storage Index Execution Time: 5.000 ms
--    ->  Hash  (cost=108.00..108.00 rows=1000 width=8) (actual time=10.179..10.179 rows=1500 loops=1)
--          Buckets: 2048 (originally 1024)  Batches: 1 (originally 1)  Memory Usage: 75kB
--          ->  Index Only Scan using yb_d_id_geo_c1b on yb_device d2_0  (cost=0.00..108.00 rows=1000 width=8) (actual time=6.391..9.898 rows=1500 loops=1)
--                Heap Fetches: 0
--                Storage Index Read Requests: 2
--                Storage Index Execution Time: 9.000 ms
--  Planning Time: 0.612 ms
--  Execution Time: 16.502 ms
--  Storage Read Requests: 4
--  Storage Write Requests: 0
--  Storage Execution Time: 14.000 ms
--  Peak Memory Usage: 271 kB
-- (18 rows)
--
--
-- q3
--
-- (normal)
-- yugabyte=# explain (analyze, dist) select d1_0.id,d1_0.build_number,d1_0.created_by,d1_0.created_date,d1_0.deprecated,d1_0.model,d1_0.partner_id,d1_0.partner_token,d1_0.secret,d1_0.updated_by,d1_0.updated_date,d1_0.version,d1_0.version_notes from yb_device_version d1_0 where d1_0.deprecated=false and d1_0.id in(select d2_0.id from yb_device d2_0);
--                                                                            QUERY PLAN
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Hash Join  (cost=120.50..231.14 rows=1000 width=605) (actual time=26.190..28.964 rows=1500 loops=1)
--    Hash Cond: (d1_0.id = d2_0.id)
--    ->  Index Only Scan using yb_dv_pk_geo_c1b on yb_device_version d1_0  (cost=0.00..108.00 rows=1000 width=605) (actual time=16.683..19.059 rows=1500 loops=1)
--          Remote Filter: (NOT deprecated)
--          Heap Fetches: 0
--          Storage Index Read Requests: 2
--          Storage Index Execution Time: 16.000 ms
--    ->  Hash  (cost=108.00..108.00 rows=1000 width=8) (actual time=9.472..9.472 rows=1500 loops=1)
--          Buckets: 2048 (originally 1024)  Batches: 1 (originally 1)  Memory Usage: 75kB
--          ->  Index Only Scan using yb_d_id_geo_c1b on yb_device d2_0  (cost=0.00..108.00 rows=1000 width=8) (actual time=5.303..9.190 rows=1500 loops=1)
--                Heap Fetches: 0
--                Storage Index Read Requests: 2
--                Storage Index Execution Time: 9.000 ms
--  Planning Time: 0.638 ms
--  Execution Time: 29.122 ms
--  Storage Read Requests: 4
--  Storage Write Requests: 0
--  Storage Execution Time: 25.000 ms
--  Peak Memory Usage: 442 kB
-- (19 rows)
--
--
-- (abnormal)
-- yugabyte=# explain (analyze, dist) select d1_0.id,d1_0.build_number,d1_0.created_by,d1_0.created_date,d1_0.deprecated,d1_0.model,d1_0.partner_id,d1_0.partner_token,d1_0.secret,d1_0.updated_by,d1_0.updated_date,d1_0.version,d1_0.version_notes from yb_device_version d1_0 where d1_0.deprecated=false and d1_0.id in(select d2_0.id from yb_device d2_0);
--                                                                             QUERY PLAN
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Hash Join  (cost=120.50..231.14 rows=1000 width=605) (actual time=25.521..4963.614 rows=1500 loops=1)
--    Hash Cond: (d1_0.id = d2_0.id)
--    ->  Index Only Scan using yb_dv_pk_geo_c1b on yb_device_version d1_0  (cost=0.00..108.00 rows=1000 width=605) (actual time=16.666..4954.263 rows=1500 loops=1)
--          Remote Filter: (NOT deprecated)
--          Heap Fetches: 0
--          Storage Index Read Requests: 2
--          Storage Index Execution Time: 4952.001 ms
--    ->  Hash  (cost=108.00..108.00 rows=1000 width=8) (actual time=8.817..8.817 rows=1500 loops=1)
--          Buckets: 2048 (originally 1024)  Batches: 1 (originally 1)  Memory Usage: 75kB
--          ->  Index Only Scan using yb_d_id_geo_c1b on yb_device d2_0  (cost=0.00..108.00 rows=1000 width=8) (actual time=5.454..8.424 rows=1500 loops=1)
--                Heap Fetches: 0
--                Storage Index Read Requests: 2
--                Storage Index Execution Time: 7.000 ms
--  Planning Time: 0.665 ms
--  Execution Time: 4963.756 ms
--  Storage Read Requests: 4
--  Storage Write Requests: 0
--  Storage Execution Time: 4959.001 ms
--  Peak Memory Usage: 376 kB
-- (19 rows)
--
--
-- q4
--
-- need to test
-- yugabyte=# set yb_read_from_followers = true;
-- SET
-- yugabyte=# SET default_transaction_read_only = true;
-- SET
-- yugabyte=# set enable_nestloop = false;