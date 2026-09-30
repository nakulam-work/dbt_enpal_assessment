-- CRM activities, one row per activity. activity_id is reused across rows in the
-- source, so we hash the business columns into a unique surrogate key.
with source as (
    select * from {{ source('pipedrive', 'activity') }}
)

select
    md5(concat_ws('|', activity_id, type, deal_id, due_to, done)) as activity_sk,
    activity_id,
    deal_id,
    assigned_to_user   as user_id,
    type               as activity_type_key,
    done               as is_done,
    due_to             as occurred_at,
    due_to::date       as occurred_date
from source