# Housing Data Cleaning Project

## Project Overview
This project focuses on data cleaning and preprocessing of a housing dataset. The goal is to standardize formats, fill missing values, split address fields into component parts, and remove duplicate records to create a clean and reliable dataset. This clean data will be prepared for downstream analysis or reporting tasks.

## Dataset Information
### Original Columns
The dataset contains the following columns:
- **UniqueID**: Unique identifier for each record
- **ParcelID**: Parcel identifier for properties
- **LandUse**: Type of land use for the property
- **PropertyAddress**: Address of the property
- **SaleDate**: Date of the property sale
- **SalePrice**: Price at which the property was sold
- **LegalReference**: Legal reference for the property
- **SoldAsVacant**: Indicates if the property was sold as vacant
- **OwnerName**: Name of the property owner
- **OwnerAddress**: Address of the property owner
- **Acreage**: Size of the property in acres
- **TaxDistrict**: Tax district information
- **LandValue**: Value of the land
- **BuildingValue**: Value of the building
- **TotalValue**: Total property value
- **YearBuilt**: Year the property was built
- **Bedrooms**: Number of bedrooms in the property
- **FullBath**: Number of full bathrooms
- **HalfBath**: Number of half bathrooms

## SQL Queries for Data Cleaning

### 1. Standardize Date Format
- A new column, `SaleDate2`, was created to store `SaleDate` values in a standardized date format.
- **SQL Code**:
  ```sql
  ALTER TABLE Project1..datacleaning
  ADD SaleDate2 DATE;

  UPDATE Project1..datacleaning
  SET SaleDate2 = CONVERT(DATE, SaleDate);
  ```

### 2. Fill Missing Property Address
- Missing `PropertyAddress` values were filled based on matching `ParcelID` values from other rows.
- **SQL Code**:
  ```sql
  UPDATE a
  SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
  FROM Project1..datacleaning a
  JOIN Project1..datacleaning b
  ON a.ParcelID = b.ParcelID AND a.[UniqueID] <> b.[UniqueID]
  WHERE a.PropertyAddress IS NULL;
  ```

### 3. Split `PropertyAddress` into Address Components
- `PropertyAddress` was split into individual columns for address (`PropertySplitAddress`) and city (`PropertySplitCity`).
- **SQL Code**:
  ```sql
  ALTER TABLE Project1..datacleaning
  ADD PropertySplitAddress NVARCHAR(255),
      PropertySplitCity NVARCHAR(255);

  UPDATE Project1..datacleaning
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
      PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));
  ```

### 4. Split `OwnerAddress` into Address Components
- `OwnerAddress` was split into individual columns for address, city, and state (`OwnerSplitAddress`, `OwnerSplitCity`, `OwnerSplitState`).
- **SQL Code**:
  ```sql
  ALTER TABLE Project1..datacleaning
  ADD OwnerSplitAddress NVARCHAR(255),
      OwnerSplitCity NVARCHAR(255),
      OwnerSplitState NVARCHAR(255);

  UPDATE Project1..datacleaning
  SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
      OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
      OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);
  ```

### 5. Standardize `SoldAsVacant` Values
- Converted values in `SoldAsVacant` from "Y" and "N" to "Yes" and "No" for clarity.
- **SQL Code**:
  ```sql
  UPDATE Project1..datacleaning
  SET SoldAsVacant = CASE 
      WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
      ELSE SoldAsVacant
      END;
  ```

### 6. Remove Duplicate Records
- Duplicate records were identified based on `ParcelID`, `PropertySplitAddress`, `SaleDate2`, `SalePrice`, and `LegalReference`. Duplicate entries were removed, keeping the first instance.
- **SQL Code**:
  ```sql
  WITH RowNumCTE AS (
      SELECT *,
          ROW_NUMBER() OVER (
              PARTITION BY ParcelID, PropertySplitAddress, SaleDate2, SalePrice, LegalReference 
              ORDER BY UniqueID
          ) AS row_num
      FROM Project1..datacleaning
  )
  DELETE FROM RowNumCTE
  WHERE row_num > 1;
  ```

### 7. Delete Unused Columns
- Removed `SaleDate`, `OwnerAddress`, `PropertyAddress`, and `TaxDistrict` columns, as they were no longer needed.
- **SQL Code**:
  ```sql
  ALTER TABLE Project1..datacleaning
  DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, TaxDistrict;
  ```

## Summary of Changes
This data cleaning process standardizes date formats, fills missing values, splits address components for easier analysis, standardizes boolean fields, and removes duplicates. Unnecessary columns are also dropped to streamline the dataset.

## Future Work
This cleaned data can now be used for various analyses, including housing market trends, property valuation assessments, and regional analysis based on location data.
