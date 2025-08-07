SELECT
  sale_id as sales_id,
  customer_id,
  product_id,
  store_id,
  sale_date as sales_date, -- تم تغيير sales_date إلى sale_date
  quantity_sold,
  total_amount
FROM {{ source('retail', 'fact_sales') }}