-- One row per (month, funnel_step).
select month, funnel_step, count(*)
from {{ ref('rep_sales_funnel_monthly') }}
group by month, funnel_step
having count(*) > 1