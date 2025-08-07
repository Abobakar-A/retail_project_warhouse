SELECT
    inventory_id as inventory_key,
    product_id,
    store_id,
    stock_date,
    stock_level
FROM {{ source('retail', 'fact_inventory') }}