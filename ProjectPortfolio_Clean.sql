SELECT *
FROM PortfolioProject..NashvilleHousing

--Standardize Date Format

Select CAST(SaleDate AS date)
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CAST(SaleDate AS date)

ALTER TABLE NashvilleHousing
ADD SaleConvertedDate Date

UPDATE NashvilleHousing
SET SaleConvertedDate = CAST(SaleDate AS date)

--Populate Property Address

Select *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.PropertyAddress, 
CASE WHEN a.PropertyAddress IS NOT NULL THEN a.PropertyAddress
ELSE b.PropertyAddress
END AS PropAddress
FROM PortfolioProject..NashvilleHousing as a
JOIN PortfolioProject..NashvilleHousing as b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] != b.[UniqueID ]

--OR

SELECT a.ParcelID, a.PropertyAddress, b.PropertyAddress, 
COALESCE(a.PropertyAddress, b.PropertyAddress) AS Prop as ProperAdd
FROM PortfolioProject..NashvilleHousing as a
JOIN PortfolioProject..NashvilleHousing as b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] != b.[UniqueID ]


 UPDATE a
 SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing as a
JOIN PortfolioProject..NashvilleHousing as b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] != b.[UniqueID ]

--Breaking out Address into individual column

SELECT PropertyAddress, 
       SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address_First_Part,
       TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))) 
FROM PortfolioProject..NashvilleHousing; 

ALTER TABLE PortfolioProject..NashvilleHousing
ADD Addr NVARCHAR(255) 

UPDATE PortfolioProject..NashvilleHousing
SET Addr = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 

ALTER TABLE PortfolioProject..NashvilleHousing
ADD Addr2 NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET Addr2 = TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)))


--
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255) 

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--
SELECT SoldAsVacant, 
Case When SoldAsVacant = 'Y' then 'Yes'
WHEN SoldAsVacant =  'N' Then 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD CorrectedSoldAsVacant NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET CorrectedSoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
WHEN SoldAsVacant =  'N' Then 'No'
ELSE SoldAsVacant
END

--Remove Duplicates


with RNcte as
(SELECT *,
	ROW_NUMBER()OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashvilleHousing)

SELECT *
FROM RNcte
WHERE row_num = 2

--Delete Unused Columns 

SELECT *
FROM PortfolioProject..NashvilleHousing
  
ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate