SELECT * FROM HousingData


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CAST(SaleDate AS DATE) AS SaleDateConverted
FROM HousingData

--UPDATE HousingData
--SET SaleDate =  CONVERT(DATE, SaleDate)     (NOT WORKING)

ALTER TABLE HousingData
ADD SalesDateConverted DATE

UPDATE HousingData
SET SalesDateConverted = CONVERT(DATE, SaleDate)

--------------------------------------------------------------------------------------------------------------------------


-- Populate NULL Property Address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM   [dbo].[HousingData] AS a
JOIN   [dbo].[HousingData] AS b
ON     a.ParcelID = b.ParcelID 
AND    a.[UniqueID] <> b.[UniqueID]
WHERE  a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM   [dbo].[HousingData] AS a
JOIN   [dbo].[HousingData] AS b
ON     a.ParcelID = b.ParcelID 
AND    a.[UniqueID] <> b.[UniqueID]
WHERE  a.PropertyAddress IS NULL


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress, 1)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress, 1)+1, LEN(PropertyAddress)) AS Address
FROM HousingData

ALTER TABLE HousingData
ADD PropertySplitAddress NVARCHAR(255)

ALTER TABLE HousingData
ADD PropertySplitCity NVARCHAR(255)

UPDATE HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress, 1)-1)

UPDATE HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress, 1)+1, LEN(PropertyAddress))


SELECT * FROM HousingData


SELECT OwnerAddress, 
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM HousingData

ALTER TABLE HousingData
ADD OwnerSplitAddress NVARCHAR(255)

ALTER TABLE HousingData
ADD OwnerSplitCity NVARCHAR(255)

ALTER TABLE HousingData
ADD OwnerSplitState NVARCHAR(255)

UPDATE HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * FROM [dbo].[HousingData]


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [dbo].[HousingData]
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant) DESC


SELECT SoldAsVacant, 
       CASE
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
      END
FROM [dbo].[HousingData]


UPDATE [dbo].[HousingData]
SET SoldAsVacant = CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
				   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumberCTE
AS
(
SELECT *,
      ROW_NUMBER() OVER 
	  (PARTITION BY ParcelID,
					PropertyAddress,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID) AS RowNumber
FROM [dbo].[HousingData]
)

--SELECT * FROM RowNumberCTE
--Where RowNumber > 1

DELETE FROM RowNumberCTE
WHERE RowNumber > 1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT * FROM [dbo].[HousingData]

ALTER TABLE [dbo].[HousingData]
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict
