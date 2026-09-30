-- Lost-reason id/label pairs, unnested from the lost_reason field's JSON options.
with fields as (
    select * from {{ ref('stg_pipedrive__fields') }}
),

options as (
    select jsonb_array_elements(field_value_options::jsonb) as option
    from fields
    where field_key = 'lost_reason'
)

select
    (option ->> 'id')::int   as lost_reason_id,
    option ->> 'label'       as lost_reason_label
from options