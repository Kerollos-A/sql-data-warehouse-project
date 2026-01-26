/*****************************************************************************************
 Project      : SQL Data Warehouse (Medallion Architecture)
 Layer        : Bronze Layer (Raw Data)
 Database     : DataWarehouse
 Schema       : bronze

 Description  :
 This script is responsible for creating raw (Bronze layer) tables.
 The Bronze layer stores data exactly as received from source systems
 (CRM & ERP) with no transformations applied.

 Key Notes :
 - Tables are dropped and recreated to support Full Load / Truncate & Load strategy.
 - Data is stored in its original structure and data types.
 - No constraints, keys, or business logic are applied at this stage.

*****************************************************************************************/


/*****************************************************************************************
 CRM - Customer Information
 Source System : CRM
 Description   : Stores raw customer master data from CRM system.
*****************************************************************************************/
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE
);


/*****************************************************************************************
 CRM - Product Information
 Source System : CRM
 Description   : Stores raw product master data including lifecycle dates.
*****************************************************************************************/
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info (
    prd_id        INT,
    prd_key       NVARCHAR(50),
    prd_nm        NVARCHAR(50),
    prd_cost      INT,
    prd_line      NVARCHAR(50),
    prd_start_dt  DATETIME,
    prd_end_dt    DATETIME
);


/*****************************************************************************************
 CRM - Sales Details
 Source System : CRM
 Description   : Stores raw transactional sales data.
 Notes         : Date columns are stored as INT as received from source.
*****************************************************************************************/
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num   NVARCHAR(20),
    sls_prd_key   NVARCHAR(50),
    sls_cust_id   INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);


/*****************************************************************************************
 ERP - Location Demographics (AZ12)
 Source System : ERP
 Description   : Stores customer demographic data such as birth date and gender.
*****************************************************************************************/
IF OBJECT_ID('bronze.erp_loc_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12 (
    cid   NVARCHAR(50),
    bdate DATE,
    gen   NVARCHAR(50)
);


/*****************************************************************************************
 ERP - Location Country (A101)
 Source System : ERP
 Description   : Stores customer country information.
*****************************************************************************************/
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101 (
    cid   NVARCHAR(50),
    cntry NVARCHAR(50)
);


/*****************************************************************************************
 ERP - Product Category Mapping
 Source System : ERP
 Description   : Stores product category, subcategory, and maintenance classification.
*****************************************************************************************/
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id          NVARCHAR(50),
    cat         NVARCHAR(50),
    subcat      NVARCHAR(50),
    maintenance NVARCHAR(50)
);
