USE DataWarehouse;
GO

/*****************************************************************************************
 Project      : SQL Data Warehouse (Medallion Architecture)
 Layer        : Silver Layer (Cleaned & Standardized Data)
 Database     : DataWarehouse
 Schema       : silver

 Description  :
 This script is responsible for creating Silver layer tables.
 The Silver layer contains cleaned, standardized, and structured data
 derived from the Bronze (raw) layer.

 Data in this layer:
 - Has consistent naming conventions
 - Uses appropriate data types
 - Is ready for transformation, enrichment, and integration
 - Serves as a reliable source for the Gold layer

 Key Notes :
 - Tables are dropped and recreated to support Full Load processing.
 - Basic structural cleanup is applied (data types, column naming).
 - No business aggregations are applied at this stage.
 - Data is optimized for downstream analytics and reporting.

*****************************************************************************************/



/*****************************************************************************************
 CRM - Customer Information
 Source System : CRM
 Layer         : Silver
 Description   : Stores cleaned and standardized customer master data originating
                from the CRM system.
*****************************************************************************************/
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info
(
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);


/*****************************************************************************************
 CRM - Product Information
 Source System : CRM
 Layer         : Silver
 Description   : Stores cleaned product master data including product lifecycle dates.
****************************************************************************************/
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info
(
    prd_id INT,
    cat_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);



/*****************************************************************************************
 CRM - Sales Details
 Source System : CRM
 Layer         : Silver
 Description   : Stores standardized transactional sales data.
 Date fields are kept in their original INT format
 to preserve source system consistency.
*****************************************************************************************/
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details
(
    sls_ord_num NVARCHAR(20),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt date,
    sls_ship_dt date,
    sls_due_dt date,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);


/*****************************************************************************************
 ERP - Customer Demographics (AZ12)
 Source System : ERP
 Layer         : Silver
 Description   :
 Stores customer demographic attributes such as
 birth date and gender.
*****************************************************************************************/
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;

CREATE TABLE silver.erp_cust_az12
(
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);


/*****************************************************************************************
 ERP - Customer Country (A101)
 Source System : ERP
 Layer         : Silver
 Description   :
 Stores standardized customer country information.
*****************************************************************************************/
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101
(
    cid NVARCHAR(50),
    cntry NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);


/*****************************************************************************************
 ERP - Product Category Mapping
 Source System : ERP
 Layer         : Silver
 Description   :
 Stores product category, subcategory,
 and maintenance classification data.
*****************************************************************************************/
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2
(
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
