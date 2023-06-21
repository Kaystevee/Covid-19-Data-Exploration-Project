/*

Data Cleaning in SQL Queries

*/

SELECT *
FROM PortfolioProject..NashvilleHousing;


--Standardize Date Format


ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date;


SELECT SaleDate
FROM PortfolioProject..NashvilleHousing;


--Populate Property Address Data



SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL
--There are still property where the Addresses are null, if we have a reference point we would restore the addresses back.


SELECT*
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID; /* So in a case where the parceID is the same, the address is also the same. The ParceID will be used as ref point to the NULL addresses,
					that is to say populating the the PropertyAddress with the parceID */


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B --Performing a self JOIN
	ON A.ParcelID = B.ParcelID
	AND a.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B --/* Performing a self JOIN
	ON A.ParcelID = B.ParcelID
	AND a.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;


--Breaking out Address into Individual Colums (Address, city, State)


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address;


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);



ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));



SELECT *
FROM PortfolioProject..NashvilleHousing;



SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing;


SELECT
PARSENAME(REPLACE (OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE (OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE (OwnerAddress, ',', '.') ,1)
FROM PortfolioProject..NashvilleHousing;


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);


SELECT *
FROM PortfolioProject..NashvilleHousing;


--Change Y and N to Yes and No in "sold as vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;



SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProject..NashvilleHousing;


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END;


--Removing Duplicates


WITH RowNumCTE AS(
SELECT *,	
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num

FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;


SELECT *
FROM PortfolioProject..NashvilleHousing;


--Delete unused columns


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate;
--I deleted the columns that wasn't used for anything

SELECT *
FROM PortfolioProject..NashvilleHousing;

