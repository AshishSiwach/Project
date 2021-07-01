-- Cleaning Data in Nashville Housing Data
select * from Nashville_Housing

-- Standardizing Date Format
SELECT SaleDate, Convert(date, SaleDate)
FROM NASHVILLE_HOUSING

ALTER TABLE Nashville_Housing
ADD SALEDATECONVERTED DATE;

UPDATE Nashville_Housing
SET SALEDATECONVERTED = CONVERT(DATE, SALEDATE)
SELECT * FROM NASHVILLE_HOUSING

-- Fill null values in Property Address
select * from Nashville_Housing
where PropertyAddress is null
order by ParcelID
-- so we can see same parcel id has same address. so we can try to use it to fill nulls.
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
isnull(a.PropertyAddress, b.PropertyAddress)
from Nashville_Housing a
join Nashville_Housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
and a.PropertyAddress is null

update a
set
PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from Nashville_Housing a
join Nashville_Housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
and a.PropertyAddress is null

-- Breaking out PropertyAddress into individual columns(Address, City, State)

select substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) Address,
substring(PropertyAddress,charindex(',', PropertyAddress)+1,len(PropertyAddress)) City
from Nashville_Housing

alter table Nashville_housing
add PropertySplitAddress nvarchar(255)

update Nashville_Housing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

alter table Nashville_housing
add PropertySplitCity nvarchar(255)

update Nashville_Housing
set PropertySplitCity = substring(PropertyAddress,charindex(',', PropertyAddress)+1,len(PropertyAddress)) 

-- Breaking out Owner's address into address, city and state

select
parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
from Nashville_Housing

alter table Nashville_housing
add OwnerSplitAddress nvarchar(255)

update Nashville_Housing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table Nashville_housing
add OwnerSplitCity nvarchar(255)

update Nashville_Housing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2) 

alter table Nashville_housing
add OwnerSplitState nvarchar(255)

update Nashville_Housing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1) 

-- Checking Distinct values of SoldAsVacant
select distinct SoldAsVacant, count(SoldAsVacant)
from Nashville_Housing
group by SoldAsVacant
order by 2

-- Standardize values in the feature as Yes and No by replacing Y : Yes and N : No
select SoldAsVacant,
case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from Nashville_Housing
update Nashville_Housing
set SoldAsVacant = 
case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

-- Deleting Duplicate Values

with RowNumCTE as
(
select *, 
ROW_NUMBER() over(partition by
                  ParcelID,
				  PropertyAddress,
				  SaleDate,
				  SalePrice
				  order by UniqueID) row_num
from Nashville_Housing
)
delete 
from RowNumCTE
where row_num > 1







