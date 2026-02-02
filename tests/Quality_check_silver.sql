/*****************************************************************************************
 Project      : SQL Data Warehouse
 Layer        : Data Quality Checks (Bronze & Silver)
 Script Type  : Validation Queries (Pre/Post Load)

 Description  :
 This script runs data quality checks on Bronze and Silver layer tables.
 It validates:
 - Primary key integrity (NULLs / duplicates)
 - Unwanted spaces (leading/trailing / internal)
 - Domain consistency (gender, product line, country)
 - Numeric validity (negative/NULL costs, invalid sales)
 - Date validity (format, range, logical order)

 Usage:
 - Run BEFORE loading (Bronze checks) and AFTER loading (Silver checks).
*****************************************************************************************/

USE DataWarehouse;
GO

/*========================================================================================
  1) BRONZE LAYER CHECKS
========================================================================================*/

PRINT '==================================================';
PRINT 'BRONZE LAYER - DATA QUALITY CHECKS';
PRINT '==================================================';

/*-------------------------------
  CRM - Customer Info (bronze.crm_cust_info)
--------------------------------*/

-- 1.1 Primary Key Checks: NULL IDs
SELECT *
FROM bronze.crm_cust_info
WHERE cst_id IS NULL;

-- 1.2 Primary Key Checks: Duplicate IDs (excluding NULL)
SELECT
    cst_id,
    COUNT(*) AS cnt
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- 1.3 Unwanted spaces: leading/trailing spaces (TRIM mismatch)
SELECT
    cst_firstname,
    cst_lastname
FROM bronze.crm_cust_info
WHERE cst_firstname <> TRIM(cst_firstname)
    OR cst_lastname  <> TRIM(cst_lastname);

-- 1.4 Unwanted spaces: internal spaces inside names (e.g., "Joh n")
SELECT
    cst_firstname,
    cst_lastname
FROM bronze.crm_cust_info
WHERE cst_firstname <> REPLACE(cst_firstname, ' ', '')
    OR cst_lastname  <> REPLACE(cst_lastname, ' ', '');

-- 1.5 Gender values with extra spaces
SELECT
    cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr <> TRIM(cst_gndr);

-- 1.6 Gender domain review
SELECT DISTINCT
    cst_gndr
FROM bronze.crm_cust_info;

-- 1.7 Sample data preview
SELECT *
FROM bronze.crm_cust_info;
GO


/*-------------------------------
  CRM - Product Info (bronze.crm_prd_info)
--------------------------------*/

-- 1.8 Validate end date calculation logic for specific product keys
SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_start_dt,
    LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS prd_end_dt_next
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');
GO


/*-------------------------------
  CRM - Sales Details (bronze.crm_sales_details)
--------------------------------*/

-- 1.9 Invalid due dates (format/range)
SELECT
    sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt IS NULL
    OR sls_due_dt <= 0
    OR sls_due_dt > 20500101
    OR sls_due_dt < 19000101
    OR LEN(sls_due_dt) <> 8;
GO



/*========================================================================================
  2) SILVER LAYER CHECKS
========================================================================================*/

PRINT '==================================================';
PRINT 'SILVER LAYER - DATA QUALITY CHECKS';
PRINT '==================================================';

/*-------------------------------
  CRM - Customer Info (silver.crm_cust_info)
--------------------------------*/

-- 2.1 Primary Key Checks: NULL IDs
SELECT *
FROM silver.crm_cust_info
WHERE cst_id IS NULL;

-- 2.2 Primary Key Checks: Duplicate IDs (excluding NULL)
SELECT
    cst_id,
    COUNT(*) AS cnt
FROM silver.crm_cust_info
WHERE cst_id IS NOT NULL
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- 2.3 Unwanted spaces: internal spaces inside names (should be clean in Silver)
SELECT
    cst_firstname,
    cst_lastname
FROM silver.crm_cust_info
WHERE cst_firstname <> REPLACE(cst_firstname, ' ', '')
    OR cst_lastname  <> REPLACE(cst_lastname, ' ', '');

-- 2.4 Gender domain review (should be standardized)
SELECT DISTINCT
    cst_gndr
FROM silver.crm_cust_info;
GO


/*-------------------------------
  CRM - Product Info (silver.crm_prd_info)
--------------------------------*/

-- 2.5 Product name should not contain leading/trailing spaces
SELECT
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);

-- 2.6 Primary Key Checks: NULL / Duplicates
SELECT *
FROM silver.crm_prd_info
WHERE prd_id IS NULL;

SELECT
    prd_id,
    COUNT(*) AS cnt
FROM silver.crm_prd_info
WHERE prd_id IS NOT NULL
GROUP BY prd_id
HAVING COUNT(*) > 1;

-- 2.7 Validate cost (NULL / negative)
SELECT
    prd_id,
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL
    OR prd_cost < 0;

-- 2.8 Product line domain review
SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info;

-- 2.9 Date validity: end date should not be before start date
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- 2.10 Data preview
SELECT *
FROM silver.crm_prd_info;
GO


/*-------------------------------
  CRM - Sales Details (silver.crm_sales_details)
--------------------------------*/

-- 2.11 Date logic checks: order date should not be after ship/due dates
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
    OR sls_order_dt > sls_due_dt;

-- 2.12 Sales consistency checks:
-- price * quantity must equal sales, and all must be positive/non-null
SELECT DISTINCT
    sls_sales    AS sales_amount,
    sls_quantity AS quantity,
    sls_price    AS unit_price
FROM silver.crm_sales_details
WHERE (sls_price * sls_quantity) <> sls_sales
    OR sls_sales IS NULL
    OR sls_quantity IS NULL
    OR sls_price IS NULL
    OR sls_sales <= 0
    OR sls_quantity <= 0
    OR sls_price <= 0
ORDER BY sales_amount, quantity, unit_price;

-- 2.13 Data preview
SELECT *
FROM silver.crm_sales_details;
GO


/*-------------------------------
  ERP - Customer (silver.erp_cust_az12)
--------------------------------*/

-- 2.14 Out-of-range birth dates (business rule example)
SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
    OR bdate > GETDATE();
GO


/*-------------------------------
  ERP - Location (silver.erp_loc_a101)
--------------------------------*/

-- 2.15 Country domain review (standardization check)
SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101;

-- 2.16 Data preview
SELECT *
FROM silver.erp_loc_a101;
GO
