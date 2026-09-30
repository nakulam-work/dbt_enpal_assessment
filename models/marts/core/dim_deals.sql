-- One row per deal: current-state attributes collapsed from the change log.
-- Note: a lost_reason is recorded for ~all deals in this data, so treat it as an
-- attribute, not a reliable "deal lost" flag.
with deal_changes as (
    select * from {{ ref('stg_pipedrive__deal_changes') }}
),

created as (
    select deal_id, min(changed_at) as created_at
    from deal_changes
    where field_key = 'add_time'
    group by deal_id
),

current_stage as (
    select distinct on (deal_id)
        deal_id,
        new_value::int as current_stage_id
    from deal_changes
    where field_key = 'stage_id'
    order by deal_id, changed_at desc
),

current_owner as (
    select distinct on (deal_id)
        deal_id,
        new_value::int as current_owner_id
    from deal_changes
    where field_key = 'user_id'
    order by deal_id, changed_at desc
),

latest_lost_reason as (
    select distinct on (deal_id)
        deal_id,
        new_value::int as lost_reason_id
    from deal_changes
    where field_key = 'lost_reason'
    order by deal_id, changed_at desc
)

select
    c.deal_id,
    c.created_at,
    date_trunc('month', c.created_at)::date as created_month,
    cs.current_stage_id,
    s.stage_name as current_stage_name,
    co.current_owner_id,
    llr.lost_reason_id,
    lr.lost_reason_label
from created c
left join current_stage cs on cs.deal_id = c.deal_id
left join {{ ref('dim_stages') }} s on s.stage_id = cs.current_stage_id
left join current_owner co on co.deal_id = c.deal_id
left join latest_lost_reason llr on llr.deal_id = c.deal_id
left join {{ ref('dim_lost_reasons') }} lr on lr.lost_reason_id = llr.lost_reason_id