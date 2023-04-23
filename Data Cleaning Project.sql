-- The database we will be working on:

select * from Portfolio_Project..NashvilleHousing

-- Standardize Date Format

select saledateConverted,convert(date,saledate)
from Portfolio_Project..NashvilleHousing

alter table NashvilleHousing
Add SaleDateConverted Date

update Portfolio_Project..NashvilleHousing
set saledateConverted=convert(date,saledate)

-------------------------------------------------------------------------------------------

-- Populate Property Adress Data

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, Isnull(a.propertyAddress,b.propertyAddress)
from Portfolio_Project..NashvilleHousing as a
join Portfolio_Project..NashvilleHousing as b
on a.ParcelID=b.ParcelID and a.[uniqueID] <> b.[uniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress = Isnull(a.propertyAddress,b.propertyAddress)
from Portfolio_Project..NashvilleHousing as a
join Portfolio_Project..NashvilleHousing as b
on a.ParcelID=b.ParcelID and a.[uniqueID] <> b.[uniqueID]
where a.PropertyAddress is null 


-- Breaking out Address into Individual columns (Address,City,State)

select substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) as City
from Portfolio_Project..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress=substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity=substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))

----------------------------------------------------------------------------------------------------------------

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),3)

----------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

update NashvilleHousing
set SoldAsVacant = Case when soldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from Portfolio_Project.dbo.NashvilleHousing

----------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE as
(
select *,
Row_Number() over ( partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by uniqueID ) row_num
from Portfolio_Project.dbo.NashvilleHousing
)

Delete
from RowNumCTE 
where row_num>1

---------------------------------------------------------------------------------------------------

-- Delete unused columns

Alter Table Portfolio_Project.dbo.NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress


Alter Table Portfolio_Project.dbo.NashvilleHousing
drop column SaleDate


