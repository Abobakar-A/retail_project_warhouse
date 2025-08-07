SELECT
    employee_id as employee_key,
    employee_name,
    department,
    employment_type,
    hire_date,
    store_id
FROM {{ source('retail', 'dim_employees') }}