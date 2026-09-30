-- Total Lead Generation deals should equal distinct created deals in dim_deals.
with lead_gen as (
    select coalesce(sum(deals_count), 0) as n
    from {{ ref('rep_sales_funnel_monthly') }}
    where funnel_step = 'Step 1'
),

created as (
    select count(*) as n from {{ ref('dim_deals') }}
)

select
    lead_gen.n   as lead_gen_deals,
    created.n    as created_deals
from lead_gen
cross join created
where lead_gen.n <> created.n