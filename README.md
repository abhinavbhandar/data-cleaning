# Housing Data Cleaning Project

This project aims to clean and standardize a housing dataset by applying several SQL transformations. The cleaning process includes standardizing date formats, populating missing address information, splitting address columns, and removing duplicates. Below are the key steps and SQL queries used in the data cleaning process.

## Steps and SQL Queries

### 1. Standardize Date Format
A new column, `SaleDate2`, is added to store standardized dates.

```sql
ALTER TABLE Project1..datacleaning ADD SaleDate2 DATE;
UPDATE Project1..datacleaning SET SaleDate2 = CONVERT(DATE, SaleDate);
```

### 2. Populate Missing Property Addresses
Missing `PropertyAddress` values are populated based on matching `ParcelID` values.

```sql
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project1..datacleaning a
JOIN Project1..datacleaning b
ON a.ParcelID = b.ParcelID AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;
```

### 3. Split Property Address into Separate Columns
The `PropertyAddress` column is divided into `PropertySplitAddress` (street address) and `PropertySplitCity` (city name).

```sql
ALTER TABLE Project1..datacleaning ADD PropertySplitAddress NVARCHAR(255), PropertySplitCity NVARCHAR(255);

UPDATE Project1..datacleaning
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
    PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));
```

### 4. Split Owner Address into Separate Columns
The `OwnerAddress` column is parsed to create `OwnerSplitAddress`, `OwnerSplitCity`, and `OwnerSplitState` columns.

```sql
ALTER TABLE Project1..datacleaning ADD OwnerSplitAddress NVARCHAR(255), OwnerSplitCity NVARCHAR(255), OwnerSplitState NVARCHAR(255);

UPDATE Project1..datacleaning
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);
```

### 5. Update 'SoldAsVacant' Field
Convert values in the `SoldAsVacant` field from "Y"/"N" to "Yes"/"No".

```sql
UPDATE Project1..datacleaning
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;
```

### 6. Remove Duplicates
Remove duplicate records by identifying rows with the same `ParcelID`, `PropertySplitAddress`, `SaleDate2`, `SalePrice`, and `LegalReference` values, retaining only the first occurrence.

```sql
WITH RowNumCTE AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertySplitAddress, SaleDate2, SalePrice, LegalReference 
        ORDER BY UniqueID) AS row_num
    FROM Project1..datacleaning
)
DELETE FROM Project1..datacleaning
WHERE UniqueID IN (SELECT UniqueID FROM RowNumCTE WHERE row_num > 1);
```

### 7. Remove Unused Columns
Drop unnecessary columns from the dataset, such as `SaleDate`, `OwnerAddress`, `PropertyAddress`, and `TaxDistrict`.

```sql
ALTER TABLE Project1..datacleaning
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, TaxDistrict;
```

## Final Output
After cleaning, the dataset in `Project1..datacleaning` is standardized, de-duplicated, and ready for analysis.
