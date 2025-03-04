/*
==============================================================================================
Stored Procedure:Load Bronze Layer (Source -> Bronze)
==============================================================================================
Script Purpose:
      This stored procedure loads data into the 'bronze' schema from external CSV files.
      It performs the following actions:
       - Truncates the bronze tables before loading data.
       - Uses The `Bulk Insert` command to load data from csv Files to bronze tables.
Parameters :
     None.
   This stored procedure does not accept any parameters or return any values.
Usage Example:
     Exec bronze.load_bronze;
================================================================================================
NB:
And first u should create procedure 
*/

ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    --- declartion variables
	Declare @start_time Datetime, @end_time Datetime , @batch_start_time Datetime, @batch_end_time Datetime
	Begin try
		-- Truncate and load crm_cust_info
		print '=============================='
		print 'Loading Bronze Layer'  
		print '=============================='
		print '------------------------------'
		print 'Loading CRM Tables'
		print '------------------------------'
		
		Set @batch_start_time = GETDATE();

		Set @start_time = GETDATE();
		print '>> Truncating Table: bronze.crm_cust_info '
		TRUNCATE TABLE bronze.crm_cust_info;  
		print '>> Inserting data Into: bronze.crm_cust_info '
		BULK INSERT bronze.crm_cust_info  
		FROM 'C:\Users\hasse\Desktop\data engineering\source_crm\cust_info.csv'  
		WITH (  
			FIRSTROW = 2,  
			FIELDTERMINATOR = ',',  
			TABLOCK  
		);  
		--SELECT COUNT(*) FROM bronze.crm_cust_info;  
		Set @end_time = GETDATE();
		print '>> Load duration: ' + Cast (Datediff(second , @start_time, @end_time) AS nvarchar) + ' seconds '

		-- Truncate and load crm_prd_info
		print '>> Truncating Table: bronze.crm_prd_info '  
		TRUNCATE TABLE bronze.crm_prd_info;  
		print '>> Inserting data Into: bronze.crm_prd_info'
		BULK INSERT bronze.crm_prd_info  
		FROM 'C:\Users\hasse\Desktop\data engineering\source_crm\prd_info.csv'  
		WITH (  
			FIRSTROW = 2,  
			FIELDTERMINATOR = ',',  
			TABLOCK  
		);  
		--SELECT COUNT(*) FROM bronze.crm_prd_info;  

		-- Truncate and load crm_sales_details
		print '>> Truncating Table: bronze.crm_sales_details'   
		TRUNCATE TABLE bronze.crm_sales_details;
		print '>> Inserting data Into: bronze.crm_sales_details'  
		BULK INSERT bronze.crm_sales_details  
		FROM 'C:\Users\hasse\Desktop\data engineering\source_crm\sales_details.csv'  
		WITH (  
			FIRSTROW = 2,  
			FIELDTERMINATOR = ',',  
			TABLOCK  
		);  
		--SELECT * FROM bronze.crm_sales_details;  

		print '------------------------------'
		print 'Loading ERP Tables'
		print '------------------------------'
		-- Truncate and load erp_cust_az12
		print '>> Truncating Table: bronze.erp_cust_az12'  
		TRUNCATE TABLE bronze.erp_cust_az12;
		print '>> Inserting data Into: bronze.erp_cust_az12'   
		BULK INSERT bronze.erp_cust_az12  
		FROM 'C:\Users\hasse\Desktop\data engineering\source_erp\CUST_AZ12.csv'  
		WITH (  
			FIRSTROW = 2,  
			FIELDTERMINATOR = ',',  
			TABLOCK  
		);  
		--SELECT * FROM bronze.erp_cust_az12;  

		-- Truncate and load erp_loc_a101
		print '>> Truncating Table: bronze.erp_loc_a101'  
		TRUNCATE TABLE bronze.erp_loc_a101;
		print '>> Inserting data Into: bronze.erp_loc_a101'   
		BULK INSERT bronze.erp_loc_a101  
		FROM 'C:\Users\hasse\Desktop\data engineering\source_erp\LOC_A101.csv'  
		WITH (  
			FIRSTROW = 2,  
			FIELDTERMINATOR = ',',  
			TABLOCK  
		);  
		--SELECT * FROM bronze.erp_loc_a101;  

		-- Truncate and load erp_px_cat_g1v2
		print '>> Truncating Table: bronze.erp_px_cat_g1v2'  
		TRUNCATE TABLE bronze.erp_px_cat_g1v2; 
		print '>> Inserting data Into: bronze.erp_px_cat_g1v2'  
		BULK INSERT bronze.erp_px_cat_g1v2  
		FROM 'C:\Users\hasse\Desktop\data engineering\source_erp\PX_CAT_G1V2.csv'  
		WITH (  
			FIRSTROW = 2,  
			FIELDTERMINATOR = ',',  
			TABLOCK  
		);  
		--SELECT * FROM bronze.erp_px_cat_g1v2;
		Set @batch_end_time = GETDATE();
		print 'Loading whole batch '+ cast (Datediff(second, @batch_start_time,@batch_end_time) as nvarchar) + ' seconds' 
	End try
	Begin catch
	print '================================'
	print 'Error Occured During Loading Bronze Layer'
	print 'Error Message'+Error_message();
	print 'Error Message'+ Cast (Error_number() As Nvarchar);
	print 'Error Message'+ Cast (Error_state() As Nvarchar);

	print '================================'
	End catch
END  

