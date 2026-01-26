/*
===============================================================================
 Script Name   : load_bronze.sql
 Schema        : bronze
 Object Type  : Stored Procedure
 Object Name  : bronze.load_bronze
===============================================================================
 Description  :
    This stored procedure is responsible for loading raw source data
    into the 'Bronze layer' of the Data Warehouse.

    - Truncates existing Bronze tables
    - Performs BULK INSERT operations from CSV source files
    - Handles both CRM and ERP source systems
    - Captures load duration per table and total batch duration
    - Uses TRY...CATCH for basic error handling

 Data Sources :
    - source_crm (cust_info, prd_info, sales_details)
    - source_erp (loc_a101, px_cat_g1v2, cust_az12)

 Load Strategy :
    - Full refresh (TRUNCATE + BULK INSERT)
    - Intended for initial loads or controlled batch executions

parameters  : None.
            this stored procedure does not take any parameters.

 Notes :
    - File paths are currently local and environment-specific
    - For production, consider:
        * Using network paths or external data sources
        * Parameterizing file locations
        * Adding logging tables instead of PRINT statements

 Author        : Kerollos Abdo
 Created On    : 2026-01-26
===============================================================================
*/

create or alter PROCEDURE bronze.load_bronze
as
BEGIN
    declare @start_time datetime , @end_time datetime , @batch_start_time datetime , @batch_end_time datetime;
    BEGIN try
        set @batch_start_time = GETDATE();
        print '===============================';
        print 'Loading data into Bronze layer tables...';
        print '===============================';

        print '-------------------------------';
        print 'Loading crm tables...';
        print '-------------------------------';

        set @start_time = GETDATE();
        print '>> truncating and bulk inserting data into bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;
        bulk insert bronze.crm_cust_info
        from  'C:\Users\kerollos.abdo\Desktop\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock 
        );
        set @end_time = GETDATE();
        print '>> load duration: ' + cast(datediff(SECOND , @start_time, @end_time)as nvarchar(10)) + ' seconds';
        print '-------------------------------';

        set @start_time = GETDATE();
        print '>> truncating and bulk inserting data into bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;
        bulk insert bronze.crm_prd_info
        from  'C:\Users\kerollos.abdo\Desktop\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock 
        );
        set @end_time = GETDATE();
        print '>> load duration: ' + cast(datediff(SECOND , @start_time, @end_time)as nvarchar(10)) + ' seconds';
        print '-------------------------------';

        set @start_time = GETDATE();
        print '>> truncating and bulk inserting data into bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;
        bulk insert bronze.crm_sales_details
        from  'C:\Users\kerollos.abdo\Desktop\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock 
        );
        set @end_time = GETDATE();
        print '>> load duration: ' + cast(datediff(SECOND , @start_time, @end_time)as nvarchar(10)) + ' seconds';
        print '-------------------------------';



        print '-------------------------------';
        print 'Loading erp tables...';
        print '-------------------------------';

        set @start_time = GETDATE();
        print '>> truncating and bulk inserting data into bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;
        bulk insert bronze.erp_loc_a101
        from  'C:\Users\kerollos.abdo\Desktop\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock 
        );
        set @end_time = GETDATE();
        print '>> load duration: ' + cast(datediff(SECOND , @start_time, @end_time)as nvarchar(10)) + ' seconds';
        print '-------------------------------';

        set @start_time = GETDATE();
        print '>> truncating and bulk inserting data into bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        bulk insert bronze.erp_px_cat_g1v2
        from  'C:\Users\kerollos.abdo\Desktop\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock 
        );
        set @end_time = GETDATE();
        print '>> load duration: ' + cast(datediff(SECOND , @start_time, @end_time)as nvarchar(10)) + ' seconds';
        print '-------------------------------';

        set @start_time = GETDATE();
        print '>> truncating and bulk inserting data into bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;
        bulk insert bronze.erp_cust_az12
        from  'C:\Users\kerollos.abdo\Desktop\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock 
        );
        set @end_time = GETDATE();
        print '>> load duration: ' + cast(datediff(SECOND , @start_time, @end_time)as nvarchar(10)) + ' seconds';
        print '-------------------------------';


        set @batch_end_time = GETDATE();
        print '===============================';
        print 'Total batch load duration: ' + cast(datediff(SECOND , @batch_start_time, @batch_end_time)as nvarchar(10)) + ' seconds';
        print '===============================';

    end TRY
    BEGIN CATCH
        PRINT 'Error occurred while loading data into Bronze layer tables: ' + ERROR_MESSAGE();
    END CATCH;

end


EXEC bronze.load_bronze;