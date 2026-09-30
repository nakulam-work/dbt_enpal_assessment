-- One row per CRM activity, enriched with activity-type attributes.
with activities as (
    select * from {{ ref('stg_pipedrive__activities') }}
),

activity_types as (
    select * from {{ ref('dim_activity_types') }}
)

select
    a.activity_sk,
    a.activity_id,
    a.deal_id,
    a.user_id,
    a.activity_type_key,
    t.activity_name,
    t.is_sales_call,
    a.is_done,
    a.occurred_at,
    a.occurred_date,
    date_trunc('month', a.occurred_date)::date as occurred_month
from activities a
Inner join activity_types t on t.activity_type_key = a.activity_type_key