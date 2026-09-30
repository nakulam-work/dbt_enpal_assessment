-- Deal change log, one row per field change on a deal.
with source as (
    select * from {{ source('pipedrive', 'deal_changes') }}
)

select
    deal_id,
    changed_field_key   as field_key,
    new_value,
    change_time         as changed_at,
    change_time::date   as changed_date
from source