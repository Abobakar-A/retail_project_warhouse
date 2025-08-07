SELECT
    date_id as date_key,
    year,
    quarter,
    month,
    day,
    day_of_week
FROM {{ source('retail', 'dim_time') }}