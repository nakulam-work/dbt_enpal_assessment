-- Activity-type dimension, flagging the two sales calls used as funnel sub-steps.
with activity_types as (
    select * from {{ ref('stg_pipedrive__activity_types') }}
)

select
    activity_type_id,
    activity_type_key,
    activity_name,
    is_active,
    activity_name in ('Sales Call 1', 'Sales Call 2') as is_sales_call
from activity_types