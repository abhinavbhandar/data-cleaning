select *
from Project1..datacleaning
order by 1

-- Standardize the date format

alter table Project1..datacleaning
add SaleDate2 date

update Project1..datacleaning
set SaleDate2 = convert(date,SaleDate)

select SaleDate2, convert(date,SaleDate)
from Project1..datacleaning



-- Populate property address

select *
from Project1..datacleaning
where PropertyAddress is null

select a.PropertyAddress, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from Project1..datacleaning a
join Project1..datacleaning b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from Project1..datacleaning a
join Project1..datacleaning b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out  Property Address into Individual Columns (Address, City, State)

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as address1,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as address2

from Project1..datacleaning

alter table Project1..datacleaning
add PropertySplitAddress nvarchar(255)

update Project1..datacleaning
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)


alter table Project1..datacleaning
add PropertySplitCity nvarchar(255)

update Project1..datacleaning
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))



-- Owner Address into Individual Columns (Address, City, State)

select
PARSENAME(replace(OwnerAddress,',','.'),1),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),3)
from Project1..datacleaning

alter table Project1..datacleaning
add OwnerSplitAddress nvarchar(255)

alter table Project1..datacleaning
add OwnerSplitCity nvarchar(255)

alter table Project1..datacleaning
add OwnerSplitState nvarchar(255)

update Project1..datacleaning
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

update Project1..datacleaning
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

update Project1..datacleaning
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)



-- Change Y and N to Yes and No in 'SoldAsVacant' field

select distinct(SoldAsVacant), count(SoldAsVacant)
from Project1..datacleaning
group by SoldAsVacant
order by 2

select SoldAsVacant,
case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from Project1..datacleaning

update Project1..datacleaning
set SoldAsVacant = case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

-- Remove Duplicates
with RowNumCTE as (
select *,
	row_number() over(
	partition by ParcelID,
				PropertySplitAddress,
				SaleDate2,
				SalePrice,
				LegalReference
				order by UniqueID
				) row_num
from Project1..datacleaning
)
select *
from RowNumCTE
where row_num > 1
order by PropertySplitAddress

-- Delete Unused Columns

alter table Project1..datacleaning
drop column SaleDate, OwnerAddress, PropertyAddress

alter table Project1..datacleaning
drop column TaxDistrict


