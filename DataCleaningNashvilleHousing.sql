--Cleaning Data with SQL queries

Select * from PortfolioProject.dbo.NashvilleHousing

--Standardise Date Format

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted DATE;

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

Select SaleDateConverted from PortfolioProject.dbo.NashvilleHousing

--Populate property address data
Select * from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress) 
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
 
Update a
Set a.PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
 
Select PropertyAddress from PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null

--Breaking out address into individual columns [ProperyAddress]

Select PropertyAddress from PortfolioProject.dbo.NashvilleHousing

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS AddressLine1,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS AddressLine2
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertyAddressLine1 NVARCHAR(255) 

Update PortfolioProject.dbo.NashvilleHousing
SET PropertyAddressLine1 = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
PropertyAddressLine2 NVARCHAR(255)

Update PortfolioProject.dbo.NashvilleHousing
SET PropertyAddressLine2 = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT PropertyAddressLine1,PropertyAddressLine2 
FROM PortfolioProject.dbo.NashvilleHousing

--Breaking out address into individual columns [OwnerAddress]
SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
	PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
	PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerAddressLine1 NVARCHAR(255) 

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerAddressLine1 = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerAddressLine2 NVARCHAR(255)

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerAddressLine2 = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerAddressLine3 NVARCHAR(255)

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerAddressLine3 = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT OwnerAddressLine1,OwnerAddressLine2,OwnerAddressLine3 
FROM PortfolioProject.dbo.NashvilleHousing

--Change Y and No as Yes and No in SoldAsVacant field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
	CASE 
		When SoldAsVacant = 'Y' THEN 'Yes'
	    WHEN SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE 
		When SoldAsVacant = 'Y' THEN 'Yes'
	    WHEN SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
	END


--Remove Duplicates
With RowNumCTE AS(
Select *,
		ROW_NUMBER() OVER (
			PARTITION BY ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY
							UniqueID)row_num
from PortfolioProject.dbo.NashvilleHousing
)

DELETE from RowNumCTE 
where row_num > 1

--Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

Select * from PortfolioProject.dbo.NashvilleHousing