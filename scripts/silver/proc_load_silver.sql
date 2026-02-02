/*****************************************************************************************
 Project      : SQL Data Warehouse
 Layer        : Silver Layer (Clean & Standardized Data)
 Object       : Stored Procedure [silver.load_silver_data]

 Description  :
 This procedure loads and transforms data from the Bronze layer into the Silver layer.
 It applies data cleansing, standardization, normalization, and basic business rules
 to produce consistent and analytics-ready datasets.

 Load Strategy:
 - Batch Processing
 - Full Load (Truncate & Insert)

 Source Tables :
 - bronze.crm_cust_info
 - bronze.crm_prd_info
 - bronze.crm_sales_details
 - bronze.erp_cust_az12
 - bronze.erp_loc_a101
 - bronze.erp_px_cat_g1v2

 Target Tables :
 - silver.crm_cust_info
 - silver.crm_prd_info
 - silver.crm_sales_details
 - silver.erp_cust_az12
 - silver.erp_loc_a101
 - silver.erp_px_cat_g1v2
*****************************************************************************************/

create or alter procedure silver.load_silver_data
as
BEGIN
    declare @start_time datetime , @end_time datetime , @batch_start_time datetime , @batch_end_time datetime;
    BEGIN TRY
        set @batch_start_time = GETDATE();
        print '===============================';
        print 'Loading data into Silver layer tables...';
        print '===============================';

        print '-------------------------------';
        print 'Loading crm tables...';
        print '-------------------------------';

        set @start_time = GETDATE();
        print '>> Truncateing TAble silver.crm_cust_info'
        truncate table silver.crm_cust_info;
        print '>> inserting data into silver.crm_cust_info'
        insert into silver.crm_cust_info
        (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
        )
    select
        cst_id,
        cst_key,
        trim(cst_firstname) as cst_firstname,
        trim(cst_lastname) as cst_lastname,
        case    
                when UPPER(TRIM(cst_marital_status)) = 'S' then 'Single'
                when UPPER(TRIM(cst_marital_status)) = 'M' then 'Married'
                else 'n/a' 
            end as cst_marital_status, -- normalize marital status values to readable format
        case    
                when UPPER(TRIM(cst_gndr)) = 'F' then 'Female'
                when UPPER(TRIM(cst_gndr)) = 'M' then 'Male'
                else 'n/a' 
            end as cst_gndr, -- normalize gender values to readable format
        cst_create_date
    from(
        select
            *,
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flage_last
        from bronze.crm_cust_info
        where cst_id is not null
        )t
    where flage_last = 1
        -- get the latest record for each customer ID
        ;
        set @end_time = GETDATE();
        print '>> load duration: ' + cast(datediff(SECOND , @start_time, @end_time)as nvarchar(10)) + ' seconds';
        print '-------------------------------';

        set @start_time = GETDATE();
        print '>> Truncating TAble silver.crm_prd_info'
        truncate table silver.crm_prd_info;
        print '>> inserting data into silver.crm_prd_info'
        insert into silver.crm_prd_info
        (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
        )
    select
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1 , 5) , '-' , '_') as cat_id, -- extract category ID from product key
        SUBSTRING(prd_key, 7 , len(prd_key)) as prd_key, -- extract product key without category prefix
        prd_nm,
        isnull(prd_cost, 0) as prd_cost,
        case UPPER(TRIM(prd_line))
            when 'M' then 'Mountain'
            when 'R' then 'Road'
            when 'S' then 'Other Sales'
            when 'T' then 'Touring'
            else 'n/a'
        end as prd_line, -- map product line codes to descriptive names
        cast (prd_start_dt as date ) as prd_start_dt,
        cast(lead(prd_start_dt ) over (partition by prd_key order by prd_start_dt) -1  as date) as prd_end_dt
    -- calculate end date as one day before next start date
    from bronze.crm_prd_info
        set @end_time = GETDATE();
        print '>> load duration: ' + cast(datediff(SECOND , @start_time, @end_time)as nvarchar(10)) + ' seconds';
        print '-------------------------------';


        ---------------------------------------------------------------------------------------------------------------------
        set @start_time = GETDATE();
        print '>> Truncating TAble silver.crm_sales_details'
        truncate table silver.crm_sales_details;
        print '>> inserting data into silver.crm_sales_details'
        insert into silver.crm_sales_details
        (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
        )
    select
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        case when sls_order_dt = 0 or len(sls_order_dt) <> 8 then null
                else cast (cast(sls_order_dt as varchar(8)) as date)
            end as sls_order_dt,
        case when sls_ship_dt = 0 or len(sls_ship_dt) <> 8 then null
                else cast (cast(sls_ship_dt as varchar(8)) as date)
            end as sls_ship_dt,
        case when sls_due_dt = 0 or len(sls_due_dt) <> 8 then null
                else cast (cast(sls_due_dt as varchar(8)) as date)
            end as sls_due_dt,
        CASE WHEN sls_sales IS NULL or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price)
                THEN sls_quantity * abs(sls_price)
            ELSE sls_sales
            END AS sls_sales , -- recalculate sales amount if inconsistent with quantity and price
        sls_quantity,
        CASE WHEN sls_price IS NULL or sls_price <=0 
                THEN abs(sls_sales) / NULLIF(sls_quantity,0)
            ELSE abs(sls_price)
        END AS sls_price
    from bronze.crm_sales_details
        set @end_time = GETDATE();
        print '>> load duration: ' + cast(datediff(SECOND , @start_time, @end_time)as nvarchar(10)) + ' seconds';
        print '-------------------------------';


        -- ************************************************************************************************************* --
        
        set @start_time = GETDATE();
        print '>> Truncating TAble silver.erp_cust_az12'
        truncate table silver.erp_cust_az12;
        print '>> inserting data into silver.erp_cust_az12'
        insert into silver.erp_cust_az12
        (
        cid,
        bdate,
        gen
        )
    select
        case
            when cid like 'nas%' then SUBSTRING(cid, 4 , len(cid)) -- remove 'nas' prefix from customer ID
            else cid
        end as cid,
        case 
            when bdate > GETDATE() then null
            else bdate
        end as bdate, -- set birth dates in the future to null
        case    
            when UPPER(TRIM(gen)) in ( 'F' , 'FEMALE') then 'Female'
            when UPPER(TRIM(gen)) in ( 'M' , 'MALE') then 'Male'
            else 'n/a' 
        end as gen
    -- standardize gender values 
    from bronze.erp_cust_az12
        set @end_time = GETDATE();
        print '>> load duration: ' + cast(datediff(SECOND , @start_time, @end_time)as nvarchar(10)) + ' seconds';
        print '-------------------------------';


        ---------------------------------------------------------------------------------
        set @start_time = GETDATE();
        print '>> Truncating TAble silver.erp_loc_a101'
        truncate table silver.erp_loc_a101;
        print '>> inserting data into silver.erp_loc_a101'
        insert into silver.erp_loc_a101
        (
        cid,
        cntry
        )
    SELECT
        REPLACE(cid, '-', '') as cid,
        case 
            when trim(cntry) in ('DE') then 'Germany'
            when trim(cntry) in ('US', 'USA') then 'United States'
            when trim(cntry) = ' ' or cntry is null THEN 'n/a'
            else trim(cntry)
        end as cntry
    -- normalize and handle missing country values
    from bronze.erp_loc_a101
        set @end_time = GETDATE();
        print '>> load duration: ' + cast(datediff(SECOND , @start_time, @end_time)as nvarchar(10)) + ' seconds';
        print '-------------------------------';
        ------------------ -------------------------------------------------------
        set @start_time = GETDATE();
        print '>> Truncating TAble silver.erp_px_cat_g1v2'
        truncate table silver.erp_px_cat_g1v2;
        print '>> inserting data into silver.erp_px_cat_g1v2'
        INSERT INTO silver.erp_px_cat_g1v2
        (
        id,
        cat,
        subcat,
        maintenance
        )
    select
        id,
        cat,
        subcat,
        maintenance
    from bronze.erp_px_cat_g1v2
        set @end_time = GETDATE();
        print '>> load duration: ' + cast(datediff(SECOND , @start_time, @end_time)as nvarchar(10)) + ' seconds';
        print '-------------------------------';
    end try
    BEGIN CATCH
        PRINT 'Error occurred while loading data into Silver layer tables: ' + ERROR_MESSAGE();
    END CATCH;
END


EXEC silver.load_silver_data;