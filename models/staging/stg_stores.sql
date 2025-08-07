SELECT
    store_id as store_key,
    store_name,
    location,
    manager_name
FROM {{ source('retail', 'dim_stores') }}