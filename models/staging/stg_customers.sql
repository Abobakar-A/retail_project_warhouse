SELECT
  customer_id,
  customer_name,
  email,
  region,
  signup_date
FROM {{ source('retail', 'dim_customers') }}