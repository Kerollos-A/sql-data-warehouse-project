# SQL Data Warehouse Project

Building a **Data Warehouse (DWH) 'Data Engineering' using SQL Server** following the **Medallion Architecture (Bronze, Silver, Gold layers)**.
This project demonstrates end-to-end **ELT processes**, **data modeling**, and **analytics-ready data** for reporting and machine learning use cases.

---

##  Project Overview

This repository showcases how to design and implement a modern Data Warehouse using **SQL Server**. The architecture is inspired by the **Medallion Architecture**, which separates data processing into clear, well-defined layers:

* **Bronze Layer** → Raw data ingestion (as-is)
* **Silver Layer** → Cleaned and standardized data
* **Gold Layer** → Business-ready data for analytics and reporting

The goal is to ensure:

* Data reliability
* Clear data lineage
* Scalability for analytics, BI, and ML

---

## 🏗 Architecture Overview (Medallion Architecture)

### 🔹 Data Sources

* **CRM systems**
* **ERP systems**
* **CSV files**
* **File-based interfaces (folders)**

These sources represent operational systems feeding the Data Warehouse.

---

## 🥉 Bronze Layer (Raw Data)

**Purpose:**

* Store raw data exactly as received from source systems.
* Act as a historical landing zone.

**Key Characteristics:**

* Object Type: **Tables**
* Data State: **Raw (as-is)**
* Transformations: ❌ None
* Data Model: **None (source-aligned)**

**Load Strategy:**

* Batch Processing
* Full Load
* Truncate & Insert

**Example Use Cases:**

* Auditing
* Data replay
* Source validation

---

## 🥈 Silver Layer (Clean & Standardized Data)

**Purpose:**

* Prepare data for analytics by improving quality and consistency.

**Key Characteristics:**

* Object Type: **Tables**
* Data State: **Cleaned & standardized**
* Data Model: **None (still flexible)**

**Load Strategy:**

* Batch Processing
* Full Load
* Truncate & Insert

**Transformations Applied:**

* Data cleansing
* Data standardization
* Data normalization
* Derived columns
* Data enrichment

**Example Use Cases:**

* Trusted analytical base
* Reusable datasets for multiple domains

---

## 🥇 Gold Layer (Business-Ready Data)

**Purpose:**

* Provide analytics-ready datasets aligned with business logic.

**Key Characteristics:**

* Object Type: **Views**
* Load Strategy: ❌ No physical load
* Data State: **Business-ready**

**Transformations Applied:**

* Business logic
* Aggregations
* Data integration across domains

**Data Models Used:**

* Star Schema
* Flat Tables
* Aggregated Tables

**Example Use Cases:**

* BI dashboards
* Ad-hoc SQL analysis
* Machine learning models

---

## 📊 Data Consumption Layer

The Gold layer feeds multiple consumers:

* 📈 **BI & Reporting tools**
* 🧠 **Machine Learning models**
* 🔎 **Ad-hoc SQL queries**

This separation ensures performance, clarity, and business alignment.

---

## 🛠 Technologies Used

* **SQL Server** (Data Warehouse)
* **T-SQL** (ETL & transformations)
* **Batch ETL processing**
* **Star Schema modeling**

---

##  Project Goals

* Demonstrate real-world **Data Engineering concepts**
* Apply **Medallion Architecture** using SQL Server
* Build clean, scalable, and analytics-ready data models
* Bridge operational data with business insights

---

##  Future Enhancements

* Incremental loading (CDC)
* Automation with SQL Agent / Airflow
* Performance tuning & indexing
* Integration with Power BI
* Data quality checks & monitoring

---

## 👤 Author

**Kero**
Data Engineer / Database Developer

---

⭐ If you find this project useful, feel free to star the repository!
