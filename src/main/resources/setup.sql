--- This loosely models the problem table structure and queries from the customer...
---
--- The problem seems to be linked to --stream_compression_algo=3 (not 2) and geo local covering indexes
---
--- This setup is expecting an 3 region RF5 (2 east, 2 central, and 1 west), east and central are the preferred regions
--- Due to the tablespace definitions, it is important to use the same regions:
--- east1c, east1d, central1c, central1f, and west1c

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

create index yb_device_model_idx on yb_device(model asc);

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

create table yb_device_model
(
    device_id bigint,
    model     text,
    primary key (device_id, model),
    constraint yb_device_model_device_id_fkey foreign key (device_id) references yb_device (id)
) SPLIT INTO 1 TABLETS;

create table yb_device_model_version
(
    version_id bigint,
    model      text,
    primary key (version_id, model),
    constraint yb_device_model_version_id_fkey foreign key (version_id) references yb_device_version (id)
) SPLIT INTO 1 TABLETS;

---
--- NOTE you need to have your regions match these
---
create tablespace geo_us_e1c with (replica_placement='{"num_replicas" : 1, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-east1", "zone" : "us-east1-c", "min_num_replicas" : 1}]}');
create tablespace geo_us_e1d with (replica_placement='{"num_replicas" : 1, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-east1", "zone" : "us-east1-d", "min_num_replicas" : 1}]}');
create tablespace geo_us_c1c with (replica_placement='{"num_replicas" : 1, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-central1", "zone" : "us-central1-c", "min_num_replicas" : 1}]}');
create tablespace geo_us_c1f with (replica_placement='{"num_replicas" : 1, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-central1", "zone" : "us-central1-f", "min_num_replicas" : 1}]}');
create tablespace geo_us_w1c with (replica_placement='{"num_replicas" : 1, "placement_blocks" : [{"cloud" : "gcp", "region" : "us-west1", "zone" : "us-west1-c", "min_num_replicas" : 1}]}');

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
create unique index yb_dv_pk_geo_e1e on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_e1d split into 1 tablets;
create unique index yb_dv_pk_geo_c1c on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_c1c split into 1 tablets;
create unique index yb_dv_pk_geo_c1f on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_c1f split into 1 tablets;
create unique index yb_dv_pk_geo_w1c on yb_device_version(id) include(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated, created_date, created_by, updated_date, updated_by) tablespace geo_us_w1c split into 1 tablets;

create unique index yb_dmv_pk_geo_e1c on yb_device_model_version(version_id, model) tablespace geo_us_e1c split into 1 tablets;
create unique index yb_dmv_pk_geo_e1d on yb_device_model_version(version_id, model) tablespace geo_us_e1d split into 1 tablets;
create unique index yb_dmv_pk_geo_c1c on yb_device_model_version(version_id, model) tablespace geo_us_c1c split into 1 tablets;
create unique index yb_dmv_pk_geo_c1f on yb_device_model_version(version_id, model) tablespace geo_us_c1f split into 1 tablets;
create unique index yb_dmv_pk_geo_w1c on yb_device_model_version(version_id, model) tablespace geo_us_w1c split into 1 tablets;

insert into yb_device(model, version) select 'model'||seq, 1 from generate_series(1,1500) as seq;
insert into yb_device_version(device_id, model, version, build_number, version_notes, partner_id, partner_token, secret, deprecated) select seq, 'model'||seq, 1, 1, 'Notes:'||seq, 1, 'token', 'secret', false from generate_series(1,1500) as seq;
insert into yb_device_model(device_id, model) select seq, 'model'||seq from generate_series(1, 1500) as seq;
insert into yb_device_model_version(version_id, model) select seq, 'model'||seq from generate_series(1, 1500) as seq;

--- Now to see the problem:
---
--- Start a ysqlsh session on one of the east or central nodes
---
--- Run the following:
---
--- yugabyte=# set enable_nestloop to off;
--- yugabyte=# set enable_seqscan to off;
---
--- Then run the query:
---
--- # explain (analyze, dist) select d1_0.id,d1_0.build_number,d1_0.created_by,d1_0.created_date,d1_0.deprecated,d1_0.model,d1_0.partner_id,d1_0.partner_token,d1_0.secret,d1_0.updated_by,d1_0.updated_date,d1_0.version,d1_0.version_notes from yb_device_version d1_0 where d1_0.deprecated=false and d1_0.id in(select d2_0.id from yb_device d2_0);
---
--- ^ note it will take several attempts - I typically see it after running this 5-10 times in the same session, just keep
--- hitting the up arrow key + enter and you will periodically see queries lasting > 3-5 seconds.
---


-- yugabyte=# explain (analyze, dist) select d1_0.id,d1_0.build_number,d1_0.created_by,d1_0.created_date,d1_0.deprecated,d1_0.model,d1_0.partner_id,d1_0.partner_token,d1_0.secret,d1_0.updated_by,d1_0.updated_date,d1_0.version,d1_0.version_notes from yb_device_version d1_0 where d1_0.deprecated=false and d1_0.id in(select d2_0.id from yb_device d2_0);
-- QUERY PLAN
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Hash Join  (cost=120.50..231.14 rows=1000 width=605) (actual time=19.354..22.359 rows=1500 loops=1)
--    Hash Cond: (d1_0.id = d2_0.id)
--    ->  Index Only Scan using yb_dv_pk_geo_c1c on yb_device_version d1_0  (cost=0.00..108.00 rows=1000 width=605) (actual time=12.432..15.027 rows=1500 loops=1)
--          Remote Filter: (NOT deprecated)
--          Heap Fetches: 0
--          Storage Index Read Requests: 2
--          Storage Index Execution Time: 13.001 ms
--    ->  Hash  (cost=108.00..108.00 rows=1000 width=8) (actual time=6.891..6.891 rows=1500 loops=1)
--          Buckets: 2048 (originally 1024)  Batches: 1 (originally 1)  Memory Usage: 75kB
--          ->  Index Only Scan using yb_d_id_geo_c1c on yb_device d2_0  (cost=0.00..108.00 rows=1000 width=8) (actual time=3.703..6.592 rows=1500 loops=1)
--                Heap Fetches: 0
--                Storage Index Read Requests: 2
--                Storage Index Execution Time: 5.000 ms
--  Planning Time: 0.534 ms
--  Execution Time: 22.509 ms
--  Storage Read Requests: 4
--  Storage Write Requests: 0
--  Storage Execution Time: 18.002 ms
--  Peak Memory Usage: 376 kB
-- (19 rows)
