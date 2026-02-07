/*****************************************************************************************
 Project      : SQL Data Warehouse (Medallion Architecture)
 Layer        : Gold Layer (Business-Ready Data)
 Object Type  : View
 Object Name  : gold.fact_sales
 Database     : DataWarehouse

 Description  :
 This view represents the Sales Fact table in the Gold layer.
 It integrates sales transaction data with customer and product dimensions
 to support analytical and reporting use cases.

 Grain        :
 One record per sales order line (order number × product × customer).

 Source Tables:
 - silver.crm_sales_details
 - gold.dim_products
 - gold.dim_customers

 Measures     :
 - sales_amount
 - quantity
 - price

 Date Fields  :
 - order_date
 - shipping_date
 - due_date

 Notes        :
 - Uses LEFT JOIN to preserve all sales records.
 - Designed for Star Schema consumption (BI & analytics).

*****************************************************************************************/

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales
AS
    SELECT
        sd.sls_ord_num   AS order_number,
        pr.product_key,
        cu.customer_key,
        sd.sls_order_dt  AS order_date,
        sd.sls_ship_dt   AS shipping_date,
        sd.sls_due_dt    AS due_date,
        sd.sls_sales     AS sales_amount,
        sd.sls_quantity  AS quantity,
        sd.sls_price     AS price
    FROM silver.crm_sales_details sd
        LEFT JOIN gold.dim_products pr
        ON sd.sls_prd_key = pr.product_number
        LEFT JOIN gold.dim_customers cu
        ON sd.sls_cust_id = cu.customer_id;
GO
