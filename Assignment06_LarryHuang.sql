--*************************************************************************--
-- Title: Assignment06
-- Author: LHuang
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,LHuang,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_LHuang')
	 Begin 
	  Alter Database [Assignment06DB_LHuang] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_LHuang;
	 End
	Create Database Assignment06DB_LHuang;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_LHuang;

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
,[UnitPrice] [mOney] NOT NULL
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
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
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
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

GO
CREATE VIEW [dbo].[vCategories]
WITH SCHEMABINDING
AS
SELECT
    CategoryID
    ,CategoryName
FROM dbo.Categories;
GO

CREATE VIEW [dbo].[vProducts]
WITH SCHEMABINDING
AS
SELECT
    ProductID
    ,ProductName
    ,CategoryID
    ,UnitPrice
FROM dbo.Products;
GO

CREATE VIEW [dbo].[vEmployees]
WITH SCHEMABINDING
AS
SELECT
    EmployeeID
    ,EmployeeFirstName
    ,EmployeeLastName
    ,ManagerID
FROM dbo.Employees;
GO

CREATE VIEW [dbo].[vInventories]
WITH SCHEMABINDING
AS
SELECT
    InventoryID
    ,InventoryDate
    ,EmployeeID
    ,ProductID
    ,Count
FROM dbo.Inventories;
GO

/*
DROP VIEW [dbo].[vCategories]
DROP VIEW [dbo].[vProducts]
DROP VIEW [dbo].[vInventories]
DROP VIEW [dbo].[vEmployees]
*/

Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vEmployees]
Select * From [dbo].[vInventories]




-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Use Assignment06DB_LHuang
DENY SELECT ON Categories to PUBLIC
DENY SELECT ON Products to PUBLIC
DENY SELECT ON Inventories to PUBLIC
DENY SELECT ON Employees to PUBLIC

Use Assignment06DB_LHuang
GRANT SELECT ON vCategories to PUBLIC
GRANT SELECT ON vProducts to PUBLIC
GRANT SELECT ON vInventories to PUBLIC
GRANT SELECT ON vEmployees to PUBLIC




-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!


/*
CREATE VIEW vProductsByCategories
WITH SCHEMABINDING
AS
SELECT C.CategoryName, P.ProductName, P.UnitPrice
    FROM dbo.Categories AS C
    INNER JOIN dbo.Products AS P
    	ON C.CategoryID = P.CategoryID
GO
SELECT * FROM vProductsByCategories
ORDER BY CategoryName, ProductName;
GO
--DROP VIEW [dbo].[vProductsByCategories]
*/

GO
CREATE VIEW [dbo].[vProductsByCategories]
WITH SCHEMABINDING
AS
SELECT TOP 1000000
C.CategoryName, P.ProductName, P.UnitPrice
    FROM dbo.Categories AS C
    INNER JOIN dbo.Products AS P
    	ON C.CategoryID = P.CategoryID
ORDER BY CategoryName, ProductName
GO
Select * From [dbo].[vProductsByCategories]




-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

GO
CREATE VIEW [dbo].[vInventoriesByProductsByDates]
WITH SCHEMABINDING
AS
SELECT TOP 1000000
    ProductName, InventoryDate, Count
    FROM dbo.Inventories As I
    INNER JOIN dbo.Products AS P
        ON I.ProductID = P.ProductID
    ORDER BY P.ProductName, I.InventoryDate, I.Count
GO
Select * From [dbo].[vInventoriesByProductsByDates]
--DROP VIEW [dbo].[vInventoriesByProductsByDates]




-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

GO
CREATE VIEW [dbo].[vInventoriesByEmployeesByDates]
WITH SCHEMABINDING
AS
SELECT TOP 1000000
    I.InventoryDate, CONCAT (EmployeeFirstName, ' ', EmployeeLastName) AS EmployeeFullName
    FROM dbo.Inventories AS I
    INNER JOIN dbo.Employees AS E
    	ON I.EmployeeID = E.EmployeeID
    GROUP BY InventoryDate, EmployeeFirstName, EmployeeLastName
GO
Select * From [dbo].[vInventoriesByEmployeesByDates]
--DROP VIEW [dbo].[vInventoriesByEmployeesByDates]




-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

GO
CREATE VIEW [dbo].[vInventoriesByProductsByCategories]
WITH SCHEMABINDING
AS
SELECT TOP 1000000
    CategoryName, ProductName, InventoryDate, Count
    FROM dbo.Categories AS C
    INNER JOIN dbo.Products AS P
    	ON C.CategoryID = P.CategoryID
    INNER JOIN dbo.Inventories AS I
    	ON I.ProductID = P.ProductID
    ORDER BY CategoryName, ProductName, InventoryDate, Count
GO
SELECT * FROM [dbo].[vInventoriesByProductsByCategories]
--DROP VIEW [dbo].[vInventoriesByProductsByCategories]




-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

GO
CREATE VIEW [dbo].[vInventoriesByProductsByEmployees]
WITH SCHEMABINDING
AS
SELECT TOP 1000000
    CategoryName
    ,ProductName
    ,InventoryDate
    ,Count
    ,CONCAT (EmployeeFirstName, ' ', EmployeeLastName) AS EmployeeFullName
    FROM dbo.Categories AS C
    INNER JOIN dbo.Products AS P
        ON C.CategoryID = P.CategoryID
    INNER JOIN dbo.Inventories As I
        ON P.ProductID = I.ProductID
    INNER JOIN dbo.Employees AS E
     ON I.EmployeeID = E.EmployeeID
    ORDER BY InventoryDate, CategoryName, ProductName, EmployeeFullName
GO
SELECT * FROM [dbo].[vInventoriesByProductsByEmployees]
--DROP VIEW [dbo].[vInventoriesByProductsByEmployees]




-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

GO
CREATE VIEW [dbo].[vInventoriesForChaiAndChangByEmployees]
WITH SCHEMABINDING
AS
SELECT TOP 1000000
    C.CategoryName
    ,P.ProductName
    ,I.InventoryDate
    ,I.Count
    ,CONCAT (E.EmployeeFirstName, ' ', E.EmployeeLastName) AS EmployeeFullName
    FROM dbo.Categories AS C
    INNER JOIN dbo.Products AS P
    	ON C.CategoryID = P.CategoryID
    INNER JOIN dbo.Inventories As I
    	ON P.ProductID = I.ProductID
    INNER JOIN dbo.Employees AS E
    	ON I.EmployeeID = E.EmployeeID
        WHERE P.ProductID IN (
            SELECT ProductID
            FROM dbo.Products
            WHERE ProductName IN ('Chai', 'Chang')
        )
    ORDER BY InventoryDate, CategoryName, ProductName
GO
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
--DROP VIEW [dbo].[vInventoriesForChaiAndChangByEmployees]




-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

GO
CREATE VIEW [dbo].[vEmployeesByManager]
WITH SCHEMABINDING
AS
SELECT TOP 1000000
	CONCAT (Mgr.EmployeeFirstName, ' ', Mgr.EmployeeLastName) AS [Manager Full Name]
    ,CONCAT (Emp.EmployeeFirstName, ' ', Emp.EmployeeLastName) AS [Employee Full Name]
    FROM dbo.Employees AS Emp
	INNER JOIN dbo.Employees AS Mgr
        ON Emp.ManagerID = Mgr.EmployeeID
    ORDER BY [Manager Full Name], [Employee Full Name]
GO
SELECT * FROM [dbo].[vEmployeesByManager]
--DROP VIEW [dbo].[vEmployeesByManager]




-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

/*
TEMPLATE:
    CREATE VIEW [dbo].[vInventoriesByProductsByCategoriesByEmployees]
    WITH SCHEMABINDING
    AS
    SELECT TOP 1000000
    ***insert code here***
    SELECT * FROM [dbo].[vInventoriesByProductsByCategoriesByEmployees]
    --DROP VIEW [dbo].[vInventoriesByProductsByCategoriesByEmployees]

INSTRUCTIONS:
    -step #1: make sure 4 views already created - vCategories, vProducts, vInventories, vEmployees
    -step #2: join all 4 basic views into 1 superview
    -step #3: join vEmployeesByManager into the superview
    -step #4: order by CategoryName, ProductName, InventoryID, EmployeeName

First draft of code, for instruction steps #1-2, and 4:
SELECT
	VC.CategoryID
	,VC.CategoryName
	,VP.ProductID
	,VP.ProductName
	,VP.UnitPrice
	,VI.InventoryID
	,VI.InventoryDate
	,VI.Count
	,VE.EmployeeID
	,VE.EmployeeFirstName
	,VE.EmployeeFirstName
FROM vCategories AS VC
    INNER JOIN vProducts AS VP
    	ON VC.CategoryID = VP.CategoryID
    INNER JOIN vInventories As VI
    	ON VP.ProductID = VI.ProductID
    INNER JOIN vEmployees AS VE
    	ON VI.EmployeeID = VE.EmployeeID
ORDER BY VC.CategoryName, VP.ProductName, VI.InventoryID, VE.EmployeeFirstName
GO

Second draft of code, for instruction steps #3:
*/

GO
CREATE VIEW [dbo].[vInventoriesByProductsByCategoriesByEmployees]
WITH SCHEMABINDING
AS
SELECT TOP 1000000
	VC.CategoryID
	,VC.CategoryName
	,VP.ProductID
	,VP.ProductName
	,VP.UnitPrice
	,VI.InventoryID
	,VI.InventoryDate
	,VI.Count
    ,VE.EmployeeID
    ,CONCAT (VE.EmployeeFirstName, ' ', VE.EmployeeLastName) AS [Employee]
    ,CONCAT (VM.EmployeeFirstName, ' ', VM.EmployeeLastName) AS [Manager]
FROM dbo.vCategories AS VC
    INNER JOIN dbo.vProducts AS VP
    	ON VC.CategoryID = VP.CategoryID
    INNER JOIN dbo.vInventories As VI
    	ON VP.ProductID = VI.ProductID
    INNER JOIN dbo.vEmployees AS VE
        ON VI.EmployeeID = VE.EmployeeID
    LEFT JOIN dbo.vEmployees AS VM
        ON VE.ManagerID = VM.EmployeeID
ORDER BY
    VC.CategoryName 
    ,VP.ProductID
    ,VI.InventoryID
    ,[Employee]
GO
SELECT * FROM [dbo].[vInventoriesByProductsByCategoriesByEmployees]
--DROP VIEW [dbo].[vInventoriesByProductsByCategoriesByEmployees]]




-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/