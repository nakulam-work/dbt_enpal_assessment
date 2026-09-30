-- One row per stage-entry event for a deal. is_first_entry flags the first time a
-- deal reached a stage, so downstream models can count first entries (funnel) or
-- all entries (re-entry / churn-back analysis) without re-deriving the logic.
with stage_moves as (
    select
        deal_id,
        new_value::int   as stage_id,
        changed_at,
        changed_date
    from {{ ref('stg_pipedrive__deal_changes') }}
    where field_key = 'stage_id'
)

select
    m.deal_id,
    m.stage_id,
    s.stage_number,
    s.stage_name,
    m.changed_at,
    m.changed_date,
    date_trunc('month', m.changed_date)::date as changed_month,
    (row_number() over (partition by m.deal_id, m.stage_id order by m.changed_at) = 1) as is_first_entry
from stage_moves m
join {{ ref('dim_stages') }} s on s.stage_id = m.stage_id