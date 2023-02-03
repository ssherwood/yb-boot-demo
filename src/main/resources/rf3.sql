CREATE TABLESPACE e1c_ts_rf3 WITH (replica_placement=
    '{"num_replicas":3,"placement_blocks":[{"cloud":"gcp","region":"us-east1","zone":"us-east1-c","min_num_replicas":1,"leader_preference":1},{"cloud":"gcp","region":"us-central1","zone":"us-central1-c","min_num_replicas":1,"leader_preference":2},{"cloud":"gcp","region":"us-west1","zone":"us-west1-c","min_num_replicas":1,"leader_preference":3}]}');

CREATE TABLESPACE e1d_ts_rf3 WITH (replica_placement=
    '{"num_replicas":3,"placement_blocks":[{"cloud":"gcp","region":"us-east1","zone":"us-east1-d","min_num_replicas":1,"leader_preference":1},{"cloud":"gcp","region":"us-central1","zone":"us-central1-f","min_num_replicas":1,"leader_preference":2},{"cloud":"gcp","region":"us-west1","zone":"us-west1-c","min_num_replicas":1,"leader_preference":3}]}');

CREATE TABLESPACE c1c_ts_rf3 WITH (replica_placement=
    '{"num_replicas":3,"placement_blocks":[{"cloud":"gcp","region":"us-central1","zone":"us-central1-c","min_num_replicas":1,"leader_preference":1},{"cloud":"gcp","region":"us-east1","zone":"us-east1-c","min_num_replicas":1,"leader_preference":2},{"cloud":"gcp","region":"us-west-1","zone":"us-west-1a","min_num_replicas":1,"leader_preference":3}]}');

CREATE TABLESPACE c1f_ts_rf3 WITH (replica_placement=
    '{"num_replicas":3,"placement_blocks":[{"cloud":"gcp","region":"us-central1","zone":"us-central1-f","min_num_replicas":1,"leader_preference":1},{"cloud":"gcp","region":"us-east1","zone":"us-east1-d","min_num_replicas":1,"leader_preference":2},{"cloud":"gcp","region":"us-west-1","zone":"us-west-1a","min_num_replicas":1,"leader_preference":3}]}');


create unique index geo_email_e1c on yb_user (email) include(id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "e1c_ts_rf3" split into 100 tablets;
create unique index geo_email_e1d on yb_user (email) include(id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "e1d_ts_rf3" split into 100 tablets;
create unique index geo_email_c1c on yb_user (email) include(id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "c1c_ts_rf3" split into 100 tablets;
create unique index geo_email_c1f on yb_user (email) include(id, created_date, updated_date, email, display_name, type, status, region, password_hash, avatar_url, full_name, phone_number, birth_date, last_active_date) tablespace "c1f_ts_rf3" split into 100 tablets;
