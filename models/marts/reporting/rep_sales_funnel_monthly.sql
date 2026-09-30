-- Monthly sales funnel: distinct deals that entered each step per month.
-- Stage steps use first entry; sales-call sub-steps use completed calls.
-- Columns this model needs: month, kpi_name, funnel_step, deals_count.
with funnel_steps as (
    select * from {{ ref('seed_funnel_steps') }}
),

stage_steps as (
    select
        f.changed_month             as month,
        s.kpi_name,
        s.funnel_step,
        s.sort_order,
        count(distinct f.deal_id)   as deals_count
    from {{ ref('fct_deal_stage_changes') }} f
    join funnel_steps s
        on s.source_type = 'stage'
       and s.source_key = f.stage_id::varchar
    where f.is_first_entry
    group by 1, 2, 3, 4
),

activity_steps as (
    select
        a.occurred_month            as month,
        s.kpi_name,
        s.funnel_step,
        s.sort_order,
        count(distinct a.deal_id)   as deals_count
    from {{ ref('fct_deal_activities') }} a
    join funnel_steps s
        on s.source_type = 'activity'
       and s.source_key = a.activity_type_key
    where a.is_sales_call
      and a.is_done
    group by 1, 2, 3, 4
)

select
    month,
    kpi_name,
    funnel_step,
    deals_count
from (
    select * from stage_steps
    union all
    select * from activity_steps
) combined
order by month, sort_order