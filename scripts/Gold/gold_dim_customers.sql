/*****************************************************************************************
 Project      : SQL Data Warehouse (Medallion Architecture)
 Layer        : Gold Layer (Business-Ready Data)
 Object Type  : View
 Object Name  : gold.dim_customers
 Database     : DataWarehouse

 Description  :
 This view represents the Customer Dimension in the Gold layer.
 It provides a unified and business-friendly customer profile by
 integrating CRM and ERP customer data.

 Grain        :
 One record per customer.

 Source Tables:
 - silver.crm_cust_info
 - silver.erp_cust_az12
 - silver.erp_loc_a101

 Attributes   :
 - first_name
 - last_name
 - gender
 - marital_status
 - country
 - birthdate
 - create_date

 Business Rules:
 - CRM is the master source for gender.
 - ERP gender is used only when CRM gender is 'n/a'.

 Notes        :
 - Surrogate key (customer_key) is generated using ROW_NUMBER().
 - Designed for Star Schema consumption.

*****************************************************************************************/

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers
AS
    SELECT
        ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
        ci.cst_id           AS customer_id,
        ci.cst_key          AS customer_number,
        ci.cst_firstname    AS first_name,
        ci.cst_lastname     AS last_name,
        la.cntry            AS country,
        ci.cst_marital_status AS marital_status,
        CASE 
        WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr  -- CRM is the master for gender info
        ELSE COALESCE(ca.gen, 'n/a')
    END                 AS gender,
        ca.bdate            AS birthdate,
        ci.cst_create_date  AS create_date
    FROM silver.crm_cust_info ci
        LEFT JOIN silver.erp_cust_az12 ca
        ON ci.cst_key = ca.cid
        LEFT JOIN silver.erp_loc_a101 la
        ON ci.cst_key = la.cid;
GO




     