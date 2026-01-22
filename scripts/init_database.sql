/* ============================================================================
   Script Name : 01_create_datawarehouse_and_schemas.sql
   Project     : SQL Data Warehouse Project
   Purpose     :
       - Create the DataWarehouse database if it does not already exist
       - Initialize Medallion Architecture schemas:
           • bronze  → Raw / source-aligned data
           • silver  → Cleaned & standardized data
           • gold    → Business-ready & analytics-ready data

   Description :
       This script is designed to be idempotent and safe to run multiple times.
       It checks for the existence of the database and schemas before creating them.
       The structure follows best practices for modern Data Warehouse design
       using SQL Server and Medallion Architecture.

   Environment :
       - SQL Server

   Author      : Kero
   Created On  : 2026-01-22

   Notes :
       - Intended to be executed as part of the initial DWH setup
       - Can be reused in CI/CD or automated deployment pipelines
============================================================================ */



/* =========================================
   Create Data Warehouse Database & Schemas
   ========================================= */

USE master;
GO

--  Create Database only if it does NOT exist
IF NOT EXISTS (
    SELECT 1 
    FROM sys.databases 
    WHERE name = 'DataWarehouse'
)
BEGIN
    CREATE DATABASE DataWarehouse;
    PRINT 'Database DataWarehouse created successfully.';
END
ELSE
BEGIN
    PRINT 'Database DataWarehouse already exists.';
END
GO

--  Switch to DataWarehouse
USE DataWarehouse;
GO

--  Create Bronze Schema
IF NOT EXISTS (
    SELECT 1 
    FROM sys.schemas 
    WHERE name = 'bronze'
)
BEGIN
    EXEC('CREATE SCHEMA bronze');
    PRINT 'Schema bronze created.';
END
ELSE
BEGIN
    PRINT 'Schema bronze already exists.';
END
GO

-- Create Silver Schema
IF NOT EXISTS (
    SELECT 1 
    FROM sys.schemas 
    WHERE name = 'silver'
)
BEGIN
    EXEC('CREATE SCHEMA silver');
    PRINT 'Schema silver created.';
END
ELSE
BEGIN
    PRINT 'Schema silver already exists.';
END
GO

-- 5️⃣ Create Gold Schema
IF NOT EXISTS (
    SELECT 1 
    FROM sys.schemas 
    WHERE name = 'gold'
)
BEGIN
    EXEC('CREATE SCHEMA gold');
    PRINT 'Schema gold created.';
END
ELSE
BEGIN
    PRINT 'Schema gold already exists.';
END
GO
