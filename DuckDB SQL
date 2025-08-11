-- DuckDB SQL Script for Retail Data Setup
-- هذا السكريبت يقوم بإنشاء مخطط (schema) وجداول (tables) وإدخال بيانات عينة (sample data)
-- في قاعدة بيانات DuckDB، مشابهة للبنية المستخدمة في مشروع dbt الخاص بك.

-- ملاحظة: في DuckDB، لا توجد مستودعات. أنت تتصل مباشرة بملف قاعدة بيانات.
-- يمكنك تشغيل هذا السكريبت عن طريق:
-- 1. فتح DuckDB CLI: duckdb
-- 2. ثم تشغيل الأمر: .read your_script_name.sql
-- أو من Python/R/Node.js/Java/Go/C++:
-- con = duckdb.connect('retail_data.duckdb')
-- con.execute(sql_script_content)

-- إنشاء مخطط (schema)
CREATE SCHEMA IF NOT EXISTS retail;
SET SCHEMA 'retail'; -- تحديد المخطط الافتراضي للجلسة الحالية

----------------------------------------------------------------------------------------------------------

-- جدول أبعاد العملاء (Customer Dimension)
CREATE TABLE IF NOT EXISTS retail.dim_customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    region VARCHAR(50),
    signup_date DATE
);
----------------------------------------------------------------------------------------------------------

-- جدول أبعاد المنتجات (Product Dimension)
CREATE TABLE IF NOT EXISTS retail.dim_products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);
----------------------------------------------------------------------------------------------------------

-- جدول أبعاد المتاجر (Store Dimension)
CREATE TABLE IF NOT EXISTS retail.dim_stores (
    store_id INTEGER PRIMARY KEY,
    store_name VARCHAR(100),
    location VARCHAR(100),
    manager_name VARCHAR(100)
);
----------------------------------------------------------------------------------------------------------

-- جدول أبعاد الوقت (Time Dimension)
CREATE TABLE IF NOT EXISTS retail.dim_time (
    date_id DATE PRIMARY KEY,
    year INTEGER,
    quarter INTEGER,
    month INTEGER,
    day INTEGER,
    day_of_week VARCHAR(20)
);
----------------------------------------------------------------------------------------------------------

-- جدول أبعاد الموظفين (Employee Dimension)
CREATE TABLE IF NOT EXISTS retail.dim_employees (
    employee_id INTEGER PRIMARY KEY,
    employee_name VARCHAR(255),
    department VARCHAR(50),
    employment_type VARCHAR(50),
    hire_date DATE,
    store_id INTEGER
);
----------------------------------------------------------------------------------------------------------

-- جدول حقائق المبيعات (Fact Sales)
CREATE TABLE IF NOT EXISTS retail.fact_sales (
    sale_id INTEGER PRIMARY KEY,
    customer_id INTEGER, -- لا يمكن استخدام REFERENCES مباشرة إذا كانت الجداول غير موجودة بعد
    product_id INTEGER,
    store_id INTEGER,
    sale_date DATE,
    quantity_sold INTEGER,
    total_amount DECIMAL(10,2)
);
----------------------------------------------------------------------------------------------------------

-- جدول حقائق المخزون (Fact Inventory)
CREATE TABLE IF NOT EXISTS retail.fact_inventory (
    inventory_id INTEGER PRIMARY KEY,
    product_id INTEGER,
    store_id INTEGER,
    stock_date DATE,
    stock_level INTEGER
);
----------------------------------------------------------------------------------------------------------

-- إدخال البيانات في جدول dim_customers
INSERT INTO retail.dim_customers
SELECT
    id AS customer_id,
    'Customer_' || id AS customer_name,
    'customer' || id || '@example.com' AS email,
    CASE
        WHEN id % 4 = 0 THEN 'North'
        WHEN id % 4 = 1 THEN 'South'
        WHEN id % 4 = 2 THEN 'East'
        ELSE 'West'
    END AS region,
    -- توليد تاريخ عشوائي خلال 10 سنوات سابقة (3650 يوم)
    CURRENT_DATE - INTERVAL (random_int(0, 3650)) DAY AS signup_date
FROM generate_series(1, 100000) AS t(id);

----------------------------------------------------------------------------------------------------------

-- إدخال البيانات في جدول dim_products
INSERT INTO retail.dim_products
SELECT
    id AS product_id,
    'Product_' || id AS product_name,
    CASE
        WHEN id % 3 = 0 THEN 'Electronics'
        WHEN id % 3 = 1 THEN 'Clothing'
        ELSE 'Home & Kitchen'
    END AS category,
    -- توليد سعر بين 5 و 500
    ROUND(CAST(random_int(500, 50000) AS DECIMAL) / 100.0, 2) AS price
FROM generate_series(1, 500) AS t(id);

----------------------------------------------------------------------------------------------------------

-- إدخال البيانات في جدول dim_stores
INSERT INTO retail.dim_stores
SELECT
    id AS store_id,
    'Store_' || id AS store_name,
    CASE
        WHEN id % 4 = 0 THEN 'New York'
        WHEN id % 4 = 1 THEN 'Los Angeles'
        WHEN id % 4 = 2 THEN 'Chicago'
        ELSE 'Houston'
    END AS location,
    'Manager_' || id AS manager_name
FROM generate_series(1, 100) AS t(id);

----------------------------------------------------------------------------------------------------------

-- إدخال البيانات في جدول fact_sales
INSERT INTO retail.fact_sales
SELECT
    id AS sale_id,
    random_int(1, 100000) AS customer_id, -- توليد customer_id
    random_int(1, 500) AS product_id,     -- توليد product_id
    random_int(1, 100) AS store_id,       -- توليد store_id
    -- توليد تاريخ مبيعات عشوائي خلال 5 سنوات سابقة (1825 يوم)
    CURRENT_DATE - INTERVAL (random_int(0, 1825)) DAY AS sale_date,
    random_int(1, 100) AS quantity_sold,
    -- توليد total_amount
    ROUND(CAST(random_int(1, 100) AS DECIMAL) * CAST(random_int(5, 100) AS DECIMAL), 2) AS total_amount
FROM generate_series(1, 1000000) AS t(id);

----------------------------------------------------------------------------------------------------------

-- إدخال البيانات في جدول fact_inventory
INSERT INTO retail.fact_inventory
SELECT
    id AS inventory_id,
    random_int(1, 500) AS product_id,
    random_int(1, 100) AS store_id,
    -- توليد تاريخ مخزون عشوائي خلال 5 سنوات سابقة (1825 يوم)
    CURRENT_DATE - INTERVAL (random_int(0, 1825)) DAY AS stock_date,
    random_int(1, 100) AS stock_level
FROM generate_series(1, 500000) AS t(id);

----------------------------------------------------------------------------------------------------------

-- إدخال البيانات في جدول dim_time
INSERT INTO retail.dim_time (date_id, year, quarter, month, day, day_of_week)
SELECT
    date_series AS date_id,
    CAST(strftime(date_series, '%Y') AS INTEGER) AS year,
    CAST(strftime(date_series, '%q') AS INTEGER) AS quarter, -- %q for quarter in DuckDB
    CAST(strftime(date_series, '%m') AS INTEGER) AS month,
    CAST(strftime(date_series, '%d') AS INTEGER) AS day,
    strftime(date_series, '%a') AS day_of_week -- %a for abbreviated weekday name (Mon, Tue)
FROM generate_series(CURRENT_DATE - INTERVAL '5000 days', CURRENT_DATE, INTERVAL '1 day') AS t(date_series);

----------------------------------------------------------------------------------------------------------

-- إدخال البيانات في جدول dim_employees
INSERT INTO retail.dim_employees (employee_id, employee_name, department, employment_type, hire_date, store_id)
SELECT
    id AS employee_id,
    'Employee_' || id AS employee_name,
    CASE
        WHEN id % 3 = 0 THEN 'HR'
        WHEN id % 3 = 1 THEN 'Sales'
        ELSE 'Operations'
    END AS department,
    CASE
        WHEN id % 2 = 0 THEN 'Full-time'
        ELSE 'Part-time'
    END AS employment_type,
    -- توليد تاريخ تعيين عشوائي في الماضي (10 سنوات = 3650 يوم)
    CURRENT_DATE - INTERVAL (random_int(0, 3650)) DAY AS hire_date,
    random_int(1, 100) AS store_id -- توليد store_id عشوائي بين 1 و 100
FROM generate_series(1, 10000) AS t(id);


