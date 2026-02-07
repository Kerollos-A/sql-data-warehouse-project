/*****************************************************************************************
 Project      : SQL Data Warehouse (Medallion Architecture)
 Layer        : Gold Layer (Business-Ready Data)
 Object Type  : View
 Object Name  : gold.dim_products
 Database     : DataWarehouse

 Description  :
 This view represents the Product Dimension in the Gold layer.
 It provides a business-friendly view of current product master data,
 enriched with category information for analytical use cases.

 Grain        :
 One record per current product.

 Source Tables:
 - silver.crm_prd_info
 - silver.erp_px_cat_g1v2

 Attributes   :
 - product_name
 - product_line
 - category
 - subcategory
 - maintenance
 - cost

 SCD Handling :
 - Type 1 (current state only)
 - Historical records are excluded using prd_end_dt IS NULL

 Notes        :
 - Surrogate key (product_key) is generated using ROW_NUMBER().
 - Designed for Star Schema consumption.

*****************************************************************************************/

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products
AS
    SELECT
        ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
        pn.prd_id        AS product_id,
        pn.prd_key       AS product_number,
        pn.prd_nm        AS product_name,
        pn.cat_id        AS category_id,
        pc.cat           AS category,
        pc.subcat        AS subcategory,
        pc.maintenance,
        pn.prd_cost      AS cost,
        pn.prd_line      AS product_line,
        pn.prd_start_dt  AS start_date
    FROM silver.crm_prd_info pn
        LEFT JOIN silver.erp_px_cat_g1v2 pc
        ON pn.cat_id = pc.id
    WHERE pn.prd_end_dt IS NULL; -- filter out all historical data
GO

