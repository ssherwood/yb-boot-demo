create table api_db_domestic.yb_notify_log_uuid(
    id UUID primary key,
    ingest_date timestamptz,
    notification varchar(255),
    subscription_id varchar(255),
    user_id bigint);
