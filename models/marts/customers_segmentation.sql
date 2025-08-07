with customer_sales as (
    SELECT
        s.customer_id,
        sum(s.quantity_sold) as total_purchases,
        sum(s.total_amount) as total_spend
    from {{ ref('stg_fact_sales') }} s
    group by s.customer_id
)
select 
    customer_id,
    total_purchases,
    total_spend,
    case
        when total_purchases >= 50 then 'High-Value'
        when total_purchases >= 20 then 'Medium-Value'
        when total_purchases < 20 then 'Low-Value'
        else 'Unknown'
    end as customer_segment 
from customer_sales
