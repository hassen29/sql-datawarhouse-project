
/*

================================================
Create Database and Schemas
================================================

Script Purpose
       This script creates a new databases named 'DataWarehouse' after checking if it already exists.
	   If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
	   within the database: 'bronze' , 'silver' , and 'gold' .

WARNING:
     Running this script will drop the entire 'DataWarehouse' database if it exists.
	 All data in the database will be peramanently deleted. Proceed with caution
	 and ensure you have proper backups before running this script.

*/

-- Create datawarehouse

Use master;
Go

--Drop and recreate the 'DataWarehouse' database

if Exists (Select 1 From sys.databases WHERE name = 'DataWarehouse')
Begin
	Alter DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
End;

GO

-- Create the 'DataWarehouse' database

Create DATABASE DataWarehouse;
Go

Use DataWarehouse;
Go

-- Create Schemas
CREATE SCHEMA bronze;
Go 
Create schema gold;
Go 
Create Schema silver;
Go
