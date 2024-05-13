select * from [Portfolio-Project].dbo.nashvillehousing


--SaleDate cleaning 
--select saledate,CONVERT(date,saledate) as 'SaleDate' from [Portfolio-Project].dbo.nashvillehousing
--(UPDATE dont change data type but alter can do it)
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE

-- Populate Property Address data
-- using substring and charindex
Select *
From [Portfolio-Project].dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
From [Portfolio-Project].dbo.NashvilleHousing a
JOIN [Portfolio-Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

update b
set PropertyAddress=  ISNULL(a.PropertyAddress,b.PropertyAddress) 
From [Portfolio-Project].dbo.NashvilleHousing a
JOIN [Portfolio-Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
 
 ---- Breaking out Address into Individual Columns (Address, City, State)
 select propertyaddress from [Portfolio-Project]..nashvillehousing
--coz of -ve indexing i have used case 
 SELECT
    CASE WHEN CHARINDEX(',', PropertyAddress) > 0 
         THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 
         ELSE PropertyAddress 
    END AS Address,
    CASE WHEN CHARINDEX(',', PropertyAddress) > 0 
         THEN SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)) 
         ELSE NULL 
    END AS RestOfAddress
FROM [Portfolio-Project].dbo.NashvilleHousing;

ALTER TABLE [portfolio-project].dbo.nashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update [Portfolio-Project].dbo.nashvilleHousing
set PropertySplitAddress= CASE WHEN CHARINDEX(',', PropertyAddress) > 0 
         THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 
         ELSE propertyAddress
    END 

alter table [Portfolio-Project].dbo.NashvilleHousing
add PropertySplitCity nvarchar(255);

update [Portfolio-Project].dbo.nashvilleHousing
set PropertySplitCity= CASE WHEN CHARINDEX(',', PropertyAddress) > 0 
         THEN SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))
		 else null
         end
select * from [Portfolio-Project].dbo.nashvilleHousing


--using parsename

select PARSENAME(replace(owneraddress,',','.'),3) 
, PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1) from [Portfolio-Project].dbo.nashvillehousing

ALTER TABLE [portfolio-project].dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update [portfolio-project].dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [portfolio-project].dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update [portfolio-project].dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE [portfolio-project].dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update [Portfolio-Project].dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From [Portfolio-Project].dbo.NashvilleHousing

--changing y to yes and n to no

select soldasvacant,COUNT(soldasvacant) from [Portfolio-Project].dbo.NashvilleHousing
group by soldasvacant
order by 2

select soldasvacant ,
case when soldasvacant = 'y' then 'yes'
when soldasvacant = 'n' then 'no'
else soldasvacant
end
from
[Portfolio-Project].dbo.NashvilleHousing

update [Portfolio-Project].dbo.NashvilleHousing
set soldasvacant=case when soldasvacant = 'y' then 'yes'
when soldasvacant = 'n' then 'no'
else soldasvacant
end

select  * from [Portfolio-Project].dbo.NashvilleHousing


--removing duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [Portfolio-Project].dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--remove unused column 
ALTER TABLE [Portfolio-Project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


select * from [Portfolio-Project].dbo.nashvillehousing