
/*
================================================================================
DDL Script : Create Bronze Tables
================================================================================
Script Purpose:
    this script creates tables in the 'bronze' schema, dropping existing tables
    if they already exist.
    Run this script to re-define the DDL structure of 'bronze' Tables
================================================================================

*/




if OBJECT_ID ('bronze.crm_cust_info' , 'U') is not null
	Drop table bronze.crm_cust_info;
create table bronze.crm_cust_info (
cut_id Int,
cst_Key nvarchar(50),
cst_firstname nvarchar(50),
cst_lastname nvarchar(50),
cst_marital_status nvarchar(50),
cst_gndr nvarchar(50),
cst_create_date date
);

if OBJECT_ID ('bronze.crm_prd_info' , 'U') is not null
	Drop table bronze.crm_prd_info;
create table bronze.crm_prd_info (
prd_id Int,
prd_key nvarchar(50),
prd_nm nvarchar(50),
prd_cost Int,
prd_line nvarchar(50),
prd_start_dt datetime,
prd_end_date datetime,
);

if OBJECT_ID ('bronze.crm_sales_details' , 'U') is not null
	Drop table bronze.crm_sales_details;
create table bronze.crm_sales_details (
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id Int,
sls_order_dt Int,
sls_ship_dt Int,
sls_due_dt Int,
sls_sales Int,
sls_quantity int,
sls_price Int,
);

if OBJECT_ID ('bronze.erp_cust_az12' , 'U') is not null
	Drop table bronze.erp_cust_az12;
create table bronze.erp_cust_az12 (
cid nvarchar(50),
bdate Date,
gen nvarchar(50)
);


if OBJECT_ID ('bronze.erp_loc_a101' , 'U') is not null
	Drop table bronze.erp_loc_a101;
create table bronze.erp_loc_a101 (
cid nvarchar(50),
cntry nvarchar(50)
);


if OBJECT_ID ('bronze.erp_px_cat_g1v2' , 'U') is not null
	Drop table bronze.erp_px_cat_g1v2;
create table bronze.erp_px_cat_g1v2 (
id nvarchar (50),
cat nvarchar (50),
subcat nvarchar (50),
maintenance nvarchar (50)
);








