-- check for null or dupilicate in primary keys before loading data from bronze to silver
-- example query to check for nulls and duplicates:
use DataWarehouse;
GO
select
    cst_id ,
    count(*) as cnt
from bronze.crm_cust_info
group by cst_id
having cst_id is null or count(*) > 1;

-- check for unwanted spaces 
select
    cst_firstname,
    cst_lastname
from bronze.crm_cust_info
where cst_firstname like '% %' or cst_lastname like '% %';

select
    cst_gndr
from bronze.crm_cust_info
where cst_gndr != TRIM(cst_gndr);

select
    cst_firstname,
    cst_lastname
from bronze.crm_cust_info
where cst_firstname != REPLACE(cst_firstname, ' ', '')
;
-- if the original value is not equal to the trimmed value it means there are unwanted spaces
select trim(' Joh n ');



select *
from bronze.crm_cust_info;

select distinct cst_gndr
from bronze.crm_cust_info;






-- load data from bronze to silver with necessary transformations
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
    REPLACE(SUBSTRING(prd_key, 1 , 5) , '-' , '_') as cat_id,
    SUBSTRING(prd_key, 7 , len(prd_key)) as prd_key,
    prd_nm,
    isnull(prd_cost, 0) as prd_cost,
    case UPPER(TRIM(prd_line))
    when 'M' then 'Mountain'
    when 'R' then 'Road'
    when 'S' then 'Other Sales'
    when 'T' then 'Touring'
    else 'n/a'
end as prd_line,
    cast (prd_start_dt as date ) as prd_start_dt,
    cast(lead(prd_start_dt ) over (partition by prd_key order by prd_start_dt) -1  as date) as prd_end_dt
from bronze.crm_prd_info



select sls_prd_key
from bronze.crm_sales_details



