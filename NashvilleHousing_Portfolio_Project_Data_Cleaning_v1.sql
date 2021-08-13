SELECT*
FROM PortfolioProject..NashvilleHousing


--Standardize Data Format
SELECT SaleDate, CONVERT(date, SaleDate)
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date;

------

--Populate Property Address data
SELECT*
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL;
ORDER BY ParcelID


/*Since the same parcelID will always has same property address, it can helps to find out the property address for those which is null value based on available parcelID*/
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a, PortfolioProject..NashvilleHousing b --Self Join
WHERE 
	a.ParcelID = b.ParcelID AND
	a.[UniqueID ] <> b.[UniqueID ] AND
	a.PropertyAddress IS NULL;

/*Update the null value in property address with correct address based on parcelID*/
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a, PortfolioProject..NashvilleHousing b 
WHERE 
	a.ParcelID = b.ParcelID AND
	a.[UniqueID ] <> b.[UniqueID ] AND
	a.PropertyAddress IS NULL;

------

--Breaking out Address into individual column (Address, City, State) by using "SUBSTRING"
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing;


--Adding splited address and city into the table
ALTER TABLE NashvilleHousing
ADD property_splited_address NVARCHAR(255);

UPDATE NashvilleHousing
SET property_splited_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD property_splited_city NVARCHAR(255);

UPDATE NashvilleHousing
SET property_splited_city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

SELECT*
FROM PortfolioProject..NashvilleHousing


--Breaking out owner's address by using "PARSENAME" and "Replace"
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) AS owner_address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) AS owner_city,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) AS owner_state
FROM PortfolioProject..NashvilleHousing


--Adding splited address, city, state from owner into table
ALTER TABLE NashvilleHousing
ADD owner_address NVARCHAR (255),
	owner_city NVARCHAR(255),
	owner_state NVARCHAR(255)

UPDATE NashvilleHousing
SET owner_address = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
	owner_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
	owner_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT*
FROM PortfolioProject..NashvilleHousing

------

--Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) AS count
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

------

--Remove Duplicates
WITH RowNumCTE AS --use CTE to find out the data which is duplicated and numbered it
(SELECT*,
ROW_NUMBER() OVER 
	(PARTITION BY 
		ParcelID,
		PropertyAddress,
		SaleDate,
		SalePrice,
		LegalReference
		ORDER BY UniqueID) AS row#
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)

SELECT * --these are the duplicated data (104 rows), you can use "DELETE" statement to remove duplication
FROM RowNumCTE
WHERE row#>1 

------

--Delete Unused Columns
SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN TaxDistrict;