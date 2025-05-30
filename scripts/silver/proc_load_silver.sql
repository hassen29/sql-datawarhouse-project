/*
==============================================================================================
Stored Procedure:Load Silver Layer (Bronze -> Silver)
==============================================================================================
Script Purpose:
      This stored procedure performs the ETL (Extract , Transform , Load) process to
      populate the 'silver' schema table from the 'bronze' schema.
    Actions Performed:
       - Truncates the silver tables before loading data.
       - Inserts transformed and cleaned data from Bronze into Silver tables.
Parameters :
     None.
   This stored procedure does not accept any parameters or return any values.
Usage Example:
     Exec silver.load_silver;
================================================================================================
NB:
And first u should create procedure 
*/


exec silver.load_silver;
--create or Alter
Alter  procedure silver.load_silver As
begin
	declare @start_time Datetime, @end_time Datetime , @batch_start_time datetime, @batch_end_time Datetime
	begin try

			print '=============================='
			print 'Loading Silver Layer'  
			print '=============================='
			print '------------------------------'
			print 'Loading CRM Tables'
			print '------------------------------'

			Set @batch_start_time = GETDATE()
			
			print '>> Truncating Table: silver.crm_cust_info';
			Truncate table silver.crm_cust_info;
			print ('>> inserting data into : silver.crm_cust_info')
			Insert into silver.crm_cust_info(
			cut_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr, cst_create_date)
			select 
			cut_id,
			cst_Key,
			LTRIM(rtrim(cst_firstname)) as cst_firstname,
			LTRIM(rtrim(cst_lastname)) as cst_lastname,
			case when upper(ltrim(rtrim(cst_marital_status))) = 'S' Then 'Single'
				 when upper(ltrim(rtrim(cst_marital_status))) = 'M' then 'Married'
				 else 'n/a'
			End cst_marital_status,
			case when upper(ltrim(rtrim(cst_gndr))) = 'F' Then 'Female'
				 when upper(ltrim(rtrim(cst_gndr))) = 'M' then 'Male'
				 else 'n/a'
			End cst_gndr,
			cst_create_date
			from (

			select
			*,
			row_number() over (partition by cut_id order by cst_create_date DESC) as flag_last

			from bronze.crm_cust_info
			where cut_id is not null
			)  t where flag_last =1 ;


			print '>> truncating data into : silver.crm_prd_info'
			truncate table silver.crm_prd_info
			print '>> Inserting data into : silver.crm_prd_info'
			Insert into  silver.crm_prd_info (
			prd_id ,
			cat_key ,
			prd_key ,
			prd_nm ,
			prd_cost,
			prd_line ,
			prd_start_dt ,
			prd_end_date 
			)
			SELECT  prd_id,
    
	  
				   replace (SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
				   substring(prd_key,7,len(prd_key)) AS prd_key
	   
				  ,prd_nm
				  , ISNULL(prd_cost,0) AS prd_cost,
				  case when upper(ltrim(rtrim(prd_line))) = 'M' Then 'Mountain'
					   when upper(ltrim(rtrim(prd_line))) = 'R' then 'Road'
					   when upper(ltrim(rtrim(prd_line))) = 'S' then 'Other Sales'
					   when upper(ltrim(rtrim(prd_line))) = 'T' then 'Touring'
					   else 'n/a'
				  END AS prd_line
				  ,cast (prd_start_dt AS date) As prd_start_dt
				  ,
			  cast (Lead(prd_start_dt) over ( partition by prd_key order By prd_start_dt  ) -1 as date) AS prd_end_dt               
			  FROM bronze.crm_prd_info
  
			  -- filters out unmatched data after applying transformation
			 /* where replace (SUBSTRING(prd_key,1,5),'-','_') not in 
			  (select distinct id from bronze.erp_px_cat_g1v2)*/
			  /*where substring(prd_key,7,len(prd_key)) in(
			  select sls_prd_key from bronze.crm_sales_details )*/


			  --Select prd_id,
			  --prd_key,
			  --prd_nm,
			  --prd_start_dt,
			  --prd_end_date,

			  --Lead(prd_start_dt) over ( partition by prd_key order By prd_start_dt ) -1 AS prd_end_dt_test

			  --from bronze.crm_prd_info
 







			 print '>>Truncating table silver.crm_sales_details'
			truncate table silver.crm_sales_details

			print '>> Inserting data into: silver.crm_sales_details'
			insert into silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price)

			select 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,

			case when sls_order_dt = 0 or len(sls_order_dt)!= 8 then null
				 else cast (CAST(sls_order_dt as varchar) as date) 
			End as sls_order_dt,

			case when sls_ship_dt = 0 or len(sls_ship_dt)!= 8 then null
				 else cast (CAST(sls_ship_dt as varchar) as date) 
			End as sls_ship_dt,

			case when sls_due_dt = 0 or len(sls_due_dt)!= 8 then null
				 else cast (CAST(sls_due_dt as varchar) as date) 
			End as sls_due_dt,


			case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
					  then sls_quantity * ABS (sls_price)
				Else sls_sales
			End as sls_sales,
			sls_quantity,

			case when sls_price is null or sls_price <= 0 
				   then sls_sales / nullif(sls_quantity, 0)
				Else sls_price
			End as sls_price

			from bronze.crm_sales_details




			--select * from silver.crm_sales_details




			print '------------------------------'
			print 'Loading ERP Tables'
			print '------------------------------'

			print '>> truncating data into : silver.erp_cust_az12'
			truncate table silver.erp_cust_az12
			print '>> Inserting data into : silver.erp_cust_az12'
			insert into silver.erp_cust_az12(
			cid
			,bdate
			,gen
			)

			select 
			case when cid like 'NAS%' then substring (cid , 4 ,LEN (cid)) -- removes 'Nas' prefix if present
				 else cid
			end as  cid,
			case when bdate> GETDATE() then null
				  else bdate
			end as bdate -- set future birthdates to null
			,
			case when  upper (LTRIM(rtrim(gen))) in ('F', 'Female') then 'Female'
				 when  upper (LTRIM(rtrim(gen))) in ('M', 'Male') then 'Male'
				 else 'n/a'
			end as gen -- normalize gender values and handle unknown cases
			from bronze.erp_cust_az12
 
			print '>> truncating data into : silver.erp_loc_a101'
			truncate table silver.erp_loc_a101
			print '>> Inserting data into : silver.erp_loc_a101'
			insert into silver.erp_loc_a101 (
			cid,
			cntry
			)

			select   REPLACE(cid, '-', '') as cid,
			 case when ltrim(rtrim(cntry)) in ('US' , 'USA') then 'United states'
				  when ltrim(rtrim(cntry)) = ('DE') then 'Germany'
				  when ltrim(rtrim(cntry)) = '' or cntry is null then 'n/a'
				  Else ltrim(rtrim(cntry))
	  
			end as cntry -- Normalize and handle missing or blank country codes
			from bronze.erp_loc_a101 


			--- we create cat_id from prd table to join this table
			print '>> truncating data into : silver.erp_px_cat_g1v2'
			truncate table silver.erp_px_cat_g1v2
			print '>> Inserting data into : silver.erp_px_cat_g1v2'
			insert into silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
			)
			select  id,
			cat,
			subcat,
			maintenance

			 from bronze.erp_px_cat_g1v2
			Set @batch_end_time = GETDATE();
			print 'Loading whole batch' + cast (datediff (second, @batch_start_time, @batch_end_time) as nvarchar) + ' seconds'
	end try
	begin catch
	print '================================'
	print 'Error Occured During Loading Silver Layer'
	print 'Error Message'+Error_message();
	print 'Error Message'+ Cast (Error_number() As Nvarchar);
	print 'Error Message'+ Cast (Error_state() As Nvarchar);

	print '================================'
	End catch


end;
