SELECT
    product_id as product_key,
    product_name,
    category,
    price
FROM {{ source('retail', 'dim_products') }}