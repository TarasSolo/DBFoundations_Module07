--*************************************************************************--
-- Title: Assignment07
-- Author: YourNameHere
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_Taras_S')
	 Begin 
	  Alter Database [Assignment07DB_Taras_S] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_Taras_S;
	 End
	Create Database Assignment07DB_Taras_S;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_Taras_S;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- <Put Your Code Here> --
/*
-- Select statement
Select ProductName, UnitPrice From vProducts;
go
*/
-- Input Format function to show price as US dollars -- final code

Select	
	ProductName
	,Format(UnitPrice, 'C', 'en-us') As [UnitPrice]
From dbo.vProducts
Order By ProductName;
go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- <Put Your Code Here> --

/*
-- select statements

Select CategoryName From dbo.vCategories;
go
Select ProductName, Format (UnitPrice, 'C', 'en-us') As [UnitPrice] From dbo.vProducts;
go
*/

-- join tables for the final code

Select 
	CategoryName
	, ProductName
	, Format (UnitPrice, 'C', 'en-us') As [UnitPrice]
From dbo.vCategories As vc
	Join dbo.vProducts As vp
	On vc.CategoryID = vp.CategoryID
Order By CategoryName, ProductName;
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

--select statements

/*
Select ProductName From vProducts;
go
Select InventoryDate, [Count] From vInventories;
go

-- formatting the Inventory date with a built in function
Select DateName (M, InventoryDate) + ', ' + DateName(YY, InventoryDate), [Count] From vInventories;
go

-- join tables

Select ProductName
	, DateName (M, InventoryDate) + ', ' + DateName(YY, InventoryDate) as [InventoryDate]
	, [Count]
From vProducts as vp
	Inner Join	vInventories as vi
	On vp.ProductID = vi.ProductID;
go

--adding Order By

Select 
	ProductName
	, [InventoryDate] = DateName (M, InventoryDate) + ', ' + DateName(YY, InventoryDate)
	, [Count]
From vProducts as vp
	Inner Join	vInventories as vi
	On vp.ProductID = vi.ProductID
Order By ProductName, InventoryDate;-- This Order By clause does not work for the Inventory date - it seems to order 
go									-- by the month name of the function column instead of the actual date of the inventory !!

*/

-- fixing Order By InventoryDate by replacing the new InventoryDate with function by the inventory date from the vInventories vew
-- final code:

Select 
	ProductName
	, [InventoryDate] = DateName (M, InventoryDate) + ', ' + DateName(YY, InventoryDate)
	, [Count]
From vProducts as vp
	Join vInventories as vi
	On vp.ProductID = vi.ProductID
Order By ProductName, vi.InventoryDate;
go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

-- re-using the select statment from question 3, create view, final code

Create 
View vProductInventories
As
Select Top 10000 
	ProductName
	, [InventoryDate] = DateName (M, InventoryDate) + ', ' + DateName(YY, InventoryDate)
	, [Count]
From vProducts as vp
	Join vInventories as vi
	On vp.ProductID = vi.ProductID
Order By ProductName, vi.InventoryDate;
go


-- Check that it works: 
Select * From vProductInventories;
go


-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

/*
--Select statements

Select CategoryName From vCategories; -- 8 rows
go
Select InventoryDate, [Count] From vInventories; -- 231 rows
go

--Join select statement via bridge view vProducts

Select
	CategoryName
	, InventoryDate
	, [Count]
From vCategories As vc
	Inner Join vProducts As vp
	On vc.CategoryID = vp.CategoryID
	Inner Join vInventories As vi
	On vp.ProductID = vi.ProductID; -- 231 rows
go

-- adding TOTAL Inventory Count BY CATEGORY with a Sum function

Select
	CategoryName
	, InventoryDate
	, [InventoryCountByCategory] = Sum([Count])
From vCategories As vc
	Inner Join vProducts As vp
	On vc.CategoryID = vp.CategoryID
	Inner Join vInventories As vi
	On vp.ProductID = vi.ProductID
Group By CategoryName, InventoryDate; -- 24 rows
go

-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

Select
	CategoryName
	, [InventoryDate] = DateName(M, InventoryDate) + ' ' + DateName(YY, InventoryDate)
	, [InventoryCountByCategory] = Sum([Count])
From vCategories As vc
	Inner Join vProducts As vp
	On vc.CategoryID = vp.CategoryID
	Inner Join vInventories As vi
	On vp.ProductID = vi.ProductID
Group By CategoryName, InventoryDate
Order By CategoryName, vi.InventoryDate; -- 24 rows
go

*/

-- CREATE A VIEW called vCategoryInventories, final code

Create View vCategoryInventories
As
Select Top 100000
	CategoryName
	, [InventoryDate] = DateName(M, InventoryDate) + ' ' + DateName(YY, InventoryDate)
	, [InventoryCountByCategory] = Sum([Count])
From vCategories As vc
	Join vProducts As vp
	On vc.CategoryID = vp.CategoryID
	Join vInventories As vi
	On vp.ProductID = vi.ProductID
Group By CategoryName, InventoryDate
Order By CategoryName, vi.InventoryDate;
go

-- Check that it works: 
Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --
 /*
Select * From vProductInventories;
go

-- Adding the Previous Month Count column with the LAG function

Select
	ProductName
	, InventoryDate
	, [InventoryCount] = [Count]
	, [PreviousMonthCount] = Lag ([Count]) Over(Order By (InventoryDate))
From vProductInventories
Group By ProductName, InventoryDate, [Count]

-- Method 1 to correctly Order By ProductName and InventoryDate 
-- Join the vProductInventories view with the base vInventories view to pull the InventoryDate in ANSI format

-- Join VProductInventories view with the vInventories base view to Order By Product Name and Inventory Date

Select
	vpi.ProductName
	, vpi.InventoryDate
	, [InventoryCount] = vpi.[Count]
	, [PreviousMonthCount] = Lag (vpi.[Count]) Over (Order By vpi.ProductName, vi.InventoryDate)
From vProductInventories As vpi
	Join vInventories As vi
	On vpi.InventoryDate = vi.InventoryDate
Group By vpi.ProductName, vpi.InventoryDate, vi.InventoryDate, vpi.[Count]
Order By vpi.ProductName, vi.InventoryDate
go

-- Use the Immediate If function to set any January NULL counts to zero. 

Select
	vpi.ProductName
	, vpi.InventoryDate
	, [InventoryCount] = vpi.[Count]
	, [PreviousMonthCount] = IIF(Month(vpi.InventoryDate) = 1, 0, Lag (vpi.[Count]) Over (Order By vpi.ProductName, vi.InventoryDate))
From vProductInventories As vpi
	Join vInventories As vi
	On vpi.InventoryDate = vi.InventoryDate
Group By vpi.ProductName, vpi.InventoryDate, vi.InventoryDate, vpi.[Count]
Order By vpi.ProductName, vi.InventoryDate
go

-- Create view vProductInventoriesWithPreviousMonthCounts -- final code for the method 1:

go
Create View vProductInventoriesWithPreviousMonthCounts
As
Select Top 100000
	vpi.ProductName
	, vpi.InventoryDate
	, [InventoryCount] = vpi.[Count]
	, [PreviousMonthCount] = IIF(Month(vpi.InventoryDate) = 1, 0, Lag (vpi.[Count]) Over (Order By vpi.ProductName, vi.InventoryDate))
From vProductInventories As vpi
	Join vInventories As vi
	On vpi.InventoryDate = vi.InventoryDate
Group By vpi.ProductName, vpi.InventoryDate, vi.InventoryDate, vpi.[Count]
Order By vpi.ProductName, vi.InventoryDate
go

-- End of Method 1

-- Method 2 to correctly Order By ProductName and InventoryDate
-- Use Datepart function in the Select statement

Select
	ProductName
	, InventoryDate
	, [InventoryCount] = [Count]
	, [PreviousMonthCount] = IIF(Month(InventoryDate) = 1, 0, Lag ([Count]) Over (Order By ProductName, Datepart(M, InventoryDate)))
From vProductInventories
Group By ProductName, InventoryDate, InventoryDate, [Count]
Order By ProductName, Datepart(M, InventoryDate)
go

-- Create view vProductInventoriesWithPreviousMonthCounts with Datepart function for the correct Order By
-- End of Method 2
-- final code:
*/

Create View vProductInventoriesWithPreviousMonthCounts
As
Select Top 10000
	ProductName
	, InventoryDate
	, [InventoryCount] = [Count]
	, [PreviousMonthCount] = IIF(Month(InventoryDate) = 1, 0, Lag ([Count]) Over (Order By ProductName, Datepart(M, InventoryDate)))
From vProductInventories
Group By ProductName, InventoryDate, InventoryDate, [Count]
Order By ProductName, Datepart(M, InventoryDate)
go

-- Check that it works: 
Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!

-- Create a KPI Select statement based on the vProductInventoriesWithPreviousMonthCounts view
/*
Select
	ProductName
	, InventoryDate
	, InventoryCount
	, PreviousMonthCount
	, [CountVsPreviousCountKPI] = Case
		When InventoryCount > PreviousMonthCount Then 1
		When InventoryCount = PreviousMonthCount Then 0
		When InventoryCount < PreviousMonthCount Then -1
		End
From vProductInventoriesWithPreviousMonthCounts;
go
*/

-- Create a view vProductInventoriesWithPreviousMonthCountsWithKPIs with the above select statement  -- final code:

Create View vProductInventoriesWithPreviousMonthCountsWithKPIs
As
Select
	ProductName
	, InventoryDate
	, InventoryCount
	, PreviousMonthCount
	, [CountVsPreviousCountKPI] = Case
		When InventoryCount > PreviousMonthCount Then 1
		When InventoryCount = PreviousMonthCount Then 0
		When InventoryCount < PreviousMonthCount Then -1
		End
From vProductInventoriesWithPreviousMonthCounts;
go

-- Check that it works: 
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --

/*
-- A Select statement for the KPI = 1:

Select
	ProductName
	, InventoryDate
	, InventoryCount
	, PreviousMonthCount
	, CountVsPreviousCountKPI
From vProductInventoriesWithPreviousMonthCountsWithKPIs
Where CountVsPreviousCountKPI = 1

-- Order By ProductName and InventoryDate

Select
	ProductName
	, InventoryDate
	, InventoryCount
	, PreviousMonthCount
	, CountVsPreviousCountKPI
From vProductInventoriesWithPreviousMonthCountsWithKPIs
Where CountVsPreviousCountKPI = 1
Order By ProductName, DatePart(M, InventoryDate)

*/

-- Create Function fProductInventoriesWithPreviousMonthCountsWithKPIs, final code:

Create Function fProductInventoriesWithPreviousMonthCountsWithKPIs (@KPI Int)
Returns @TBL Table
	(ProductName Varchar (40)
	, InventoryDate Varchar (40)
	, InventoryCount Int
	, PreviousMonthCount Int
	, CountVsPreviousCountKPI Int)
As
Begin
	Insert Into @TBL
	Select
	ProductName
	, InventoryDate
	, InventoryCount
	, PreviousMonthCount
	, CountVsPreviousCountKPI
	From vProductInventoriesWithPreviousMonthCountsWithKPIs
	Where CountVsPreviousCountKPI = @KPI
Return
End

-- Check that it works:
/*
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
go
*/
/***************************************************************************************/