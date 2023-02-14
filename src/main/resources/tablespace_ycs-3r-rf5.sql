--- Create tablespace for RF5 indexes
CREATE TABLESPACE east4_ts_rf5 WITH (replica_placement='{ "num_replicas": 5, "placement_blocks": [ { "cloud": "gcp", "region": "us-east4", "zone": "us-east4-a", "min_num_replicas": 1, "leader_preference": 1 }, { "cloud": "gcp", "region": "us-east4", "zone": "us-east4-b", "min_num_replicas": 1, "leader_preference": 1 }, { "cloud": "gcp", "region": "us-central1", "zone": "us-central1-a", "min_num_replicas": 1, "leader_preference": 2 }, { "cloud": "gcp", "region": "us-central1", "zone": "us-central1-b", "min_num_replicas": 1, "leader_preference": 2 }, { "cloud": "gcp", "region": "us-west1", "zone": "us-west1-a", "min_num_replicas": 1, "leader_preference": 3 } ]}');
CREATE TABLESPACE central1_ts_rf5 WITH (replica_placement='{ "num_replicas": 5, "placement_blocks": [ { "cloud": "gcp", "region": "us-central1", "zone": "us-central1-a", "min_num_replicas": 1, "leader_preference": 1 }, { "cloud": "gcp", "region": "us-central1", "zone": "us-central1-b", "min_num_replicas": 1, "leader_preference": 1 }, { "cloud": "gcp", "region": "us-east4", "zone": "us-east4-a", "min_num_replicas": 1, "leader_preference": 2 }, { "cloud": "gcp", "region": "us-east4", "zone": "us-east4-b", "min_num_replicas": 1, "leader_preference": 2 }, { "cloud": "gcp", "region": "us-west1", "zone": "us-west1-a", "min_num_replicas": 1, "leader_preference": 3 } ]}');

create unique index geo_email_east4 on yb_user (email) include (id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "east4_ts_rf5" split into 100 tablets;
create unique index geo_email_central1 on yb_user (email) include (id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "central1_ts_rf5" split into 100 tablets;

--- yugabyte=# create unique index geo_email_central1 on yb_user (email) include (id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "central1_ts_rf5" split into 100 tablets;
--- CREATE INDEX
---    Time: 169622.641 ms (02:49.623)
--- ^ on 600k rows


CREATE TABLESPACE geo_east4a_rf5 WITH (replica_placement='{ "num_replicas": 5, "placement_blocks": [ { "cloud": "gcp", "region": "us-east4", "zone": "us-east4-a", "min_num_replicas": 1 } ]}');
CREATE TABLESPACE geo_east4b_rf5 WITH (replica_placement='{ "num_replicas": 5, "placement_blocks": [ { "cloud": "gcp", "region": "us-east4", "zone": "us-east4-b", "min_num_replicas": 1 } ]}');
CREATE TABLESPACE geo_central1a_rf5 WITH (replica_placement='{ "num_replicas": 5, "placement_blocks": [ { "cloud": "gcp", "region": "us-central1", "zone": "us-central1-a", "min_num_replicas": 1 } ]}');
CREATE TABLESPACE geo_central1b_rf5 WITH (replica_placement='{ "num_replicas": 5, "placement_blocks": [ { "cloud": "gcp", "region": "us-central1", "zone": "us-central1-b", "min_num_replicas": 1 } ]}');
CREATE TABLESPACE geo_west1a_rf5 WITH (replica_placement='{ "num_replicas": 5, "placement_blocks": [ { "cloud": "gcp", "region": "us-west1", "zone": "us-west1-a", "min_num_replicas": 1 } ]}');

create index geo_device_e4a on yb_device(model) include (id, created_date, updated_date, model, partner_id, partner_token, secret, version, build_number, version_notes, deprecated) tablespace "geo_east4a_rf5" split into 100 tablets;
create index geo_device_e4b on yb_device(model) include (id, created_date, updated_date, model, partner_id, partner_token, secret, version, build_number, version_notes, deprecated) tablespace "geo_east4b_rf5" split into 100 tablets;
create index geo_device_c1a on yb_device(model) include (id, created_date, updated_date, model, partner_id, partner_token, secret, version, build_number, version_notes, deprecated) tablespace "geo_central1a_rf5" split into 100 tablets;
create index geo_device_c1b on yb_device(model) include (id, created_date, updated_date, model, partner_id, partner_token, secret, version, build_number, version_notes, deprecated) tablespace "geo_central1b_rf5" split into 100 tablets;
create index geo_device_w1a on yb_device(model) include (id, created_date, updated_date, model, partner_id, partner_token, secret, version, build_number, version_notes, deprecated) tablespace "geo_west1a_rf5" split into 100 tablets;

---
-- yb_test1=# select distinct cloud,region,zone from yb_servers();
-- cloud |   region    |     zone
-------+-------------+---------------
-- gcp   | us-west1    | us-west1-a
-- gcp   | us-central1 | us-central1-b
-- gcp   | us-central1 | us-central1-a
-- gcp   | us-east4    | us-east4-b
-- gcp   | us-east4    | us-east4-a
-- (5 rows)
