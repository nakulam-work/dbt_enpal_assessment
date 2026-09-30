-- Lost-reason dimension.
with lost_reasons as (
    select * from {{ ref('stg_pipedrive__lost_reasons') }}
)

select
    lost_reason_id,
    lost_reason_label
from lost_reasons