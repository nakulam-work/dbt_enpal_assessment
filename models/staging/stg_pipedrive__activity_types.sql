-- Activity type lookup (maps the activity.type key to a readable name).
with source as (
    select * from {{ source('pipedrive', 'activity_types') }}
)

select
    id                        as activity_type_id,
    type                      as activity_type_key,
    name                      as activity_name,
    (lower(active) = 'yes')   as is_active
from source