----------------------------------------------------------------------------------------------------------

-- جدول أبعاد العملاء (Customer Dimension)
CREATE TABLE retail.dim_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    region VARCHAR(50),
    signup_date DATE
);
----------------------------------------------------------------------------------------------------------

-- جدول أبعاد المنتجات (Product Dimension)
CREATE TABLE retail.dim_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);
----------------------------------------------------------------------------------------------------------

-- جدول أبعاد المتاجر (Store Dimension)
CREATE TABLE retail.dim_stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100),
    location VARCHAR(100), -- تم تعديل الاسم من 'city' إلى 'location' ليناسب 'Address'
    manager_name VARCHAR(100)
);
----------------------------------------------------------------------------------------------------------

-- جدول أبعاد الوقت (Time Dimension)
CREATE TABLE retail.dim_time (
    date_id DATE PRIMARY KEY,
    year INT,
    quarter INT,
    month INT,
    day INT,
    day_of_week VARCHAR(20)
);
----------------------------------------------------------------------------------------------------------

-- جدول أبعاد الموظفين (Employee Dimension)
CREATE TABLE retail.dim_employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(255), -- يفضل استخدام VARCHAR بدلاً من TEXT
    department VARCHAR(50),     -- يفضل استخدام VARCHAR بدلاً من TEXT
    employment_type VARCHAR(50), -- يفضل استخدام VARCHAR بدلاً من TEXT
    hire_date DATE,
    store_id INT
);
----------------------------------------------------------------------------------------------------------

-- جدول حقائق المبيعات (Fact Sales)
CREATE TABLE retail.fact_sales (
    sale_id INT PRIMARY KEY,
    customer_id INT REFERENCES retail.dim_customers(customer_id),
    product_id INT REFERENCES retail.dim_products(product_id),
    store_id INT REFERENCES retail.dim_stores(store_id),
    sale_date DATE REFERENCES retail.dim_time(date_id),
    quantity_sold INT,
    total_amount DECIMAL(10,2)
);
----------------------------------------------------------------------------------------------------------

-- جدول حقائق المخزون (Fact Inventory)
CREATE TABLE retail.fact_inventory (
    inventory_id INT PRIMARY KEY,
    product_id INT REFERENCES retail.dim_products(product_id),
    store_id INT REFERENCES retail.dim_stores(store_id),
    stock_date DATE REFERENCES retail.dim_time(date_id),
    stock_level INT
);
----------------------------------------------------------------------------------------------------------

-- إدخال البيانات في جدول dim_customers
INSERT INTO retail.dim_customers
SELECT
    ROW_NUMBER() OVER(ORDER BY 1) AS customer_id, -- يفضل استخدام ORDER BY في OVER()
    'Customer_' || ROW_NUMBER() OVER(ORDER BY 1) AS customer_name,
    'customer' || ROW_NUMBER() OVER(ORDER BY 1) || '@example.com' AS email,
    CASE
        WHEN ROW_NUMBER() OVER(ORDER BY 1) % 4 = 0 THEN 'North'
        WHEN ROW_NUMBER() OVER(ORDER BY 1) % 4 = 1 THEN 'South'
        WHEN ROW_NUMBER() OVER(ORDER BY 1) % 4 = 2 THEN 'East'
        ELSE 'West'
    END AS region,
    -- توليد تاريخ عشوائي خلال 10 سنوات سابقة
    DATEADD(day, -CAST(UNIFORM(0, 3650, RANDOM()) AS INT), CURRENT_DATE()) AS signup_date
FROM TABLE(GENERATOR(ROWCOUNT => 100000)); -- التعديل هنا

----------------------------------------------------------------------------------------------------------

-- إدخال البيانات في جدول dim_products
INSERT INTO retail.dim_products
SELECT
    ROW_NUMBER() OVER(ORDER BY 1) AS product_id,
    'Product_' || ROW_NUMBER() OVER(ORDER BY 1) AS product_name,
    CASE
        WHEN ROW_NUMBER() OVER(ORDER BY 1) % 3 = 0 THEN 'Electronics'
        WHEN ROW_NUMBER() OVER(ORDER BY 1) % 3 = 1 THEN 'Clothing'
        ELSE 'Home & Kitchen'
    END AS category,
    ROUND(UNIFORM(500, 50000, RANDOM()) / 100.0, 2) AS price -- توليد سعر بين 5 و 500
FROM TABLE(GENERATOR(ROWCOUNT => 500)); -- التعديل هنا

----------------------------------------------------------------------------------------------------------

-- إدخال البيانات في جدول dim_stores
INSERT INTO retail.dim_stores
SELECT
    ROW_NUMBER() OVER(ORDER BY 1) AS store_id,
    'Store_' || ROW_NUMBER() OVER(ORDER BY 1) AS store_name,
    CASE
        WHEN ROW_NUMBER() OVER(ORDER BY 1) % 4 = 0 THEN 'New York'
        WHEN ROW_NUMBER() OVER(ORDER BY 1) % 4 = 1 THEN 'Los Angeles'
        WHEN ROW_NUMBER() OVER(ORDER BY 1) % 4 = 2 THEN 'Chicago'
        ELSE 'Houston'
    END AS location, -- تم تعديل الاسم ليتوافق مع تعريف الجدول
    'Manager_' || ROW_NUMBER() OVER(ORDER BY 1) AS manager_name -- تم إضافة هذا العمود
FROM TABLE(GENERATOR(ROWCOUNT => 100)); -- التعديل هنا

----------------------------------------------------------------------------------------------------------

-- إسقاط جدول fact_sales قبل إعادة الإدخال (للتجربة)
-- DROP TABLE IF EXISTS retail.fact_sales; -- يفضل استخدام IF EXISTS لتجنب الأخطاء إذا لم يكن الجدول موجودًا
-- CREATE TABLE retail.fact_sales ( ... ); -- يجب إعادة تعريف الجدول إذا تم إسقاطه

INSERT INTO retail.fact_sales
SELECT
    ROW_NUMBER() OVER(ORDER BY 1) AS sale_id,
    CAST(UNIFORM(1, 100000, RANDOM()) AS INT) AS customer_id, -- توليد customer_id
    CAST(UNIFORM(1, 500, RANDOM()) AS INT) AS product_id,     -- توليد product_id
    CAST(UNIFORM(1, 100, RANDOM()) AS INT) AS store_id,       -- توليد store_id
    -- توليد تاريخ مبيعات عشوائي خلال 5 سنوات سابقة
    DATEADD(day, -CAST(UNIFORM(0, 1825, RANDOM()) AS INT), CURRENT_DATE()) AS sale_date,
    CAST(UNIFORM(1, 100, RANDOM()) AS INT) AS quantity_sold,
    -- توليد total_amount
    ROUND(CAST(UNIFORM(1, 100, RANDOM()) AS DECIMAL(10,2)) * CAST(UNIFORM(5, 100, RANDOM()) AS DECIMAL(10,2)), 2) AS total_amount
FROM TABLE(GENERATOR(ROWCOUNT => 1000000)); -- التعديل هنا

----------------------------------------------------------------------------------------------------------

-- إدخال البيانات في جدول fact_inventory
INSERT INTO retail.fact_inventory
SELECT
    ROW_NUMBER() OVER(ORDER BY 1) AS inventory_id,
    CAST(UNIFORM(1, 500, RANDOM()) AS INT) AS product_id,
    CAST(UNIFORM(1, 100, RANDOM()) AS INT) AS store_id,
    -- توليد تاريخ مخزون عشوائي خلال 5 سنوات سابقة
    DATEADD(day, -CAST(UNIFORM(0, 1825, RANDOM()) AS INT), CURRENT_DATE()) AS stock_date,
    CAST(UNIFORM(1, 100, RANDOM()) AS INT) AS stock_level
FROM TABLE(GENERATOR(ROWCOUNT => 500000)); -- التعديل هنا

----------------------------------------------------------------------------------------------------------

-- إنشاء جدول مؤقت لسلسلة التواريخ
CREATE TEMPORARY TABLE temp_date_series AS
SELECT DATEADD(day, -seq4(), CURRENT_DATE()) AS date_id -- استخدام seq4() لتوليد أرقام متسلسلة
FROM TABLE(GENERATOR(ROWCOUNT => 5000)); -- التعديل هنا

-- إدخال البيانات في جدول dim_time باستخدام الجدول المؤقت
INSERT INTO retail.dim_time (date_id, year, quarter, month, day, day_of_week)
SELECT
    date_id,
    EXTRACT(YEAR FROM date_id) AS year,
    EXTRACT(QUARTER FROM date_id) AS quarter,
    EXTRACT(MONTH FROM date_id) AS month,
    EXTRACT(DAY FROM date_id) AS day,
    TO_CHAR(date_id, 'DY') AS day_of_week -- استخدام 'DY' لاسم اليوم المختصر (Mon, Tue)
                                        -- أو 'Day' للاسم الكامل (Monday, Tuesday)
FROM temp_date_series;

-- تنظيف بإسقاط الجدول المؤقت
DROP TABLE temp_date_series;

----------------------------------------------------------------------------------------------------------

-- إدخال البيانات في جدول dim_employees
INSERT INTO retail.dim_employees (employee_id, employee_name, department, employment_type, hire_date, store_id)
SELECT
    CAST(ROW_NUMBER() OVER(ORDER BY 1) AS INTEGER) AS employee_id,
    'Employee_' || CAST(ROW_NUMBER() OVER(ORDER BY 1) AS VARCHAR(255)) AS employee_name,
    CASE
        WHEN ROW_NUMBER() OVER(ORDER BY 1) % 3 = 0 THEN 'HR'
        WHEN ROW_NUMBER() OVER(ORDER BY 1) % 3 = 1 THEN 'Sales'
        ELSE 'Operations'
    END AS department,
    CASE
        WHEN ROW_NUMBER() OVER(ORDER BY 1) % 2 = 0 THEN 'Full-time'
        ELSE 'Part-time'
    END AS employment_type,
    -- توليد تاريخ تعيين عشوائي في الماضي
    DATEADD(day, -CAST(UNIFORM(0, 3650, RANDOM()) AS INT), CURRENT_DATE()) AS hire_date,
    -- توليد store_id كعدد صحيح (قيم بين 1 و 5)
    CAST((ROW_NUMBER() OVER(ORDER BY 1) % 5) + 1 AS INT) AS store_id
FROM TABLE(GENERATOR(ROWCOUNT => 10000)); -- التعديل هنا
