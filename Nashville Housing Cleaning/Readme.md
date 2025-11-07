# Nashville Housing Data Cleaning (SQL Project)

This project focuses on cleaning and preparing the **Nashville Housing dataset** using SQL in Microsoft SQL Server.

## Main SQL Operations Used

- **SELECT, UPDATE, ALTER TABLE, DROP COLUMN** – for exploring, updating, and modifying the dataset structure.  
- **CONVERT()** – to standardize the `SaleDate` format to a proper `Date` type.  
- **ISNULL()** – to fill missing `PropertyAddress` values using matching `ParcelID` entries.  
- **SUBSTRING() & CHARINDEX()** – to split `PropertyAddress` into separate `Address` and `City` columns.  
- **PARSENAME() & REPLACE()** – to split the `OwnerAddress` field into `Address`, `City`, and `State`.  
- **CASE WHEN** – to standardize the `SoldAsVacant` values (`Y/N` → `YES/NO`).  
- **ROW_NUMBER() OVER (PARTITION BY ...)** – to identify and remove duplicate rows.  
- **CTE (Common Table Expression)** – used for managing duplicates in a clear and efficient way.
