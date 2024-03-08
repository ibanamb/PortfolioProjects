
--Cleaning Data in SQL Queries

SELECT *
FROM PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------
--Standardise Date format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate) -- it didn't work!

ALTER TABLE NashvilleHousing -- create a new column
Add SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM PortfolioProject..NashvilleHousing;

--------------------------------------------------------------------------------------
--Populate Property Address data

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--Sometimes Property Address is NULL when one parcel ID contains more than one row.
--Thus, we will populate the PropertyAddress Data in NULL cells

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject..NashvilleHousing AS a
INNER JOIN PortfolioProject..NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]	
--WHERE PropertyAddress IS NULL
ORDER BY a.PropertyAddress

SELECT
	a.ParcelID, 
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
INNER JOIN PortfolioProject..NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]	
--WHERE PropertyAddress IS NULL
ORDER BY a.PropertyAddress

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
INNER JOIN PortfolioProject..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]	
WHERE a.PropertyAddress IS NULL


--------------------------------------------------------------------------------------
--Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
FROM PortfolioProject..NashvilleHousing

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing -- create a new column
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing -- create a new column
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM PortfolioProject..NashvilleHousing;


--For Owner Address
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),--PARSNAME looks for periods. 
TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)), --TRIM removes spaces
TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)) 
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing -- create a new column
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing -- create a new column
Add OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2))

ALTER TABLE NashvilleHousing -- create a new column
Add OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)) 


--------------------------------------------------------------------------------------
--Change Y and N to Yes and No in SoldAsVacant field

Select DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant END


--------------------------------------------------------------------------------------
--Remove Duplicates

WITH cte AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashvilleHousing
)

SELECT *
FROM cte
WHERE row_num > 1
ORDER BY PropertyAddress

--Now delete duplicates from cte

WITH cte AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashvilleHousing
)

DELETE 
FROM cte
WHERE row_num > 1

WITH cte AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashvilleHousing
)

SELECT *
FROM cte
WHERE row_num > 1
ORDER BY PropertyAddress

--------------------------------------------------------------------------------------
--Delete unused columns

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, Address, TaxDistrict

--------------------------------------------------------------------------------------
