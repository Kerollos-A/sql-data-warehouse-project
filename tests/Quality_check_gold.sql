
/*****************************************************************************************
 Project      : SQL Data Warehouse (Medallion Architecture)
 Layer        : Gold Layer (Business-Ready Data)
 Purpose      : Data Quality Checks for Star Schema (Fact + Dimensions)
 Database     : DataWarehouse

 Description  :
 This script validates the Gold layer model by checking:
 - Referential integrity between fact and dimensions
 - Nulls in critical keys and dates
 - Duplicate keys in dimensions
 - Invalid measures (negative/zero values when not allowed)
 - Date consistency (order/ship/due)
 - Basic anomaly checks (quantity vs sales/price)

 Notes:
 - Gold layer is implemented as VIEWS, so checks are SELECT queries only.
 - Run these checks after refreshing Silver layer and before publishing reports.

*****************************************************************************************/

---------------------------------------------
-- 1) Orphan Records (Fact references missing Dimension rows)
--    Goal: Ensure every fact row has matching customer & product in dimensions.
---------------------------------------------
SELECT
    f.order_number,
    f.customer_key,
    f.product_key
FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers cu
    ON f.customer_key = cu.customer_key
    LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
WHERE cu.customer_key IS NULL
    OR p.product_key IS NULL;
-- use OR (either missing is a problem)


---------------------------------------------
-- 2) Null Checks on Fact Keys and Critical Dates
--    Goal: Fact table should not have null foreign keys or business-critical dates.
---------------------------------------------
SELECT *
FROM gold.fact_sales f
WHERE f.order_number  IS NULL
    OR f.customer_key  IS NULL
    OR f.product_key   IS NULL
    OR f.order_date    IS NULL;
-- order date is usually mandatory


---------------------------------------------
-- 3) Duplicate Natural Keys in Dimensions
--    Goal: Natural keys should be unique in dimensions to avoid many-to-one joins.
---------------------------------------------

-- 3A) Customers: customer_id / customer_number duplicates
SELECT
    customer_id,
    COUNT(*) AS cnt
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT
    customer_number,
    COUNT(*) AS cnt
FROM gold.dim_customers
GROUP BY customer_number
HAVING COUNT(*) > 1;

-- 3B) Products: product_id / product_number duplicates
SELECT
    product_id,
    COUNT(*) AS cnt
FROM gold.dim_products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT
    product_number,
    COUNT(*) AS cnt
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;


---------------------------------------------
-- 4) Duplicate Surrogate Keys in Dimensions (should never happen)
--    Goal: ensure surrogate keys are unique per dimension.
---------------------------------------------
SELECT customer_key, COUNT(*) AS cnt
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

SELECT product_key, COUNT(*) AS cnt
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


---------------------------------------------
-- 5) Measure Validations (Sales / Quantity / Price)
--    Goal: identify invalid or suspicious values.
---------------------------------------------
SELECT *
FROM gold.fact_sales f
WHERE f.quantity < 0
    OR f.sales_amount < 0
    OR f.price < 0;
-- negative values are usually invalid unless returns exist


---------------------------------------------
-- 6) Date Consistency Checks
--    Goal: ensure dates follow a logical order.
--    Typical rule: order_date <= shipping_date <= due_date
---------------------------------------------
SELECT *
FROM gold.fact_sales f
WHERE (f.shipping_date IS NOT NULL AND f.order_date > f.shipping_date)
    OR (f.due_date      IS NOT NULL AND f.shipping_date IS NOT NULL AND f.shipping_date > f.due_date)
    OR (f.due_date      IS NOT NULL AND f.order_date > f.due_date);


---------------------------------------------
-- 7) Price × Quantity vs Sales Amount (Anomaly Check)
--    Goal: sales_amount should be close to (quantity * price).
--    Note: allow a tolerance because of discounts/taxes/rounding.
---------------------------------------------
SELECT
    f.*,
    (f.quantity * f.price) AS expected_amount,
    (f.sales_amount - (f.quantity * f.price)) AS diff_amount
FROM gold.fact_sales f
WHERE f.quantity IS NOT NULL
    AND f.price IS NOT NULL
    AND f.sales_amount IS NOT NULL
    AND ABS(f.sales_amount - (f.quantity * f.price)) > 1;
-- tolerance = 1 currency unit


---------------------------------------------
-- 8) Unused Dimension Rows (Optional)
--    Goal: find dimension records that are not referenced by fact.
--    Helpful to detect stale dimension members.
---------------------------------------------

-- 8A) Customers not used in fact
SELECT cu.*
FROM gold.dim_customers cu
    LEFT JOIN gold.fact_sales f
    ON f.customer_key = cu.customer_key
WHERE f.customer_key IS NULL;

-- 8B) Products not used in fact
SELECT p.*
FROM gold.dim_products p
    LEFT JOIN gold.fact_sales f
    ON f.product_key = p.product_key
WHERE f.product_key IS NULL;


---------------------------------------------
-- 9) Join Explosion Check (Many-to-many risk indicator)
--    Goal: ensure joining fact to dims doesn't increase row count.
--    If rowcount increases, you probably have duplicates in a dimension natural key.
---------------------------------------------
SELECT
    (SELECT COUNT(*)
    FROM gold.fact_sales) AS fact_rows,
    (SELECT COUNT(*)
    FROM gold.fact_sales f
        LEFT JOIN gold.dim_customers cu ON f.customer_key = cu.customer_key
        LEFT JOIN gold.dim_products  p ON f.product_key  = p.product_key
    ) AS joined_rows;
