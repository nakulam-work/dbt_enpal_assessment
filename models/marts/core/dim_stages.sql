-- Stage dimension. stage_id also serves as the stage's ordinal position (1-9).
with stages as (
    select * from {{ ref('stg_pipedrive__stages') }}
)

select
    stage_id,
    stage_id     as stage_number,
    stage_name
from stages