
/*
Cleaning Data 
*/

Select *
From Portfolio_Project.dbo.NashvilleHousing

-- Standardize Date format
Select SaleDateConverted, Convert(Date, SaleDate)
From Portfolio_Project.dbo.NashvilleHousing

UPDATE Portfolio_Project.dbo.NashvilleHousing
 SET SaleDate= CONVERT(Date,SaleDate)
 --Por algum motivo este não fez nada eñtão aplicasse o seguinte
  Alter TABLE  Portfolio_Project.dbo.NashvilleHousing
  Add SaleDateConverted Date;

  Update  Portfolio_Project.dbo.NashvilleHousing
  Set SaleDateConverted = Convert(Date, SaleDate)

  -- Tive de usar Portfolio_Project.dbo. antes do nome da table apesar de já ter visto casos onde não é necessario

  
/*
Populate Property Adress data
*/

Select *
From Portfolio_Project.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

--Para cada ParcelID parece haver um propertAdress unico e portanto podemos preencher
--os nulls da property adress se soubermos que esse parcel ID já tem parcelid noutra entrada

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b. PropertyAddress)
From Portfolio_Project.dbo.NashvilleHousing AS a
JOIN Portfolio_Project.dbo.NashvilleHousing AS b
 ON a.ParcelID= b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null -- Depois de executar a query debaixo esta não devolve nda como seria de espectar

 Update a
 Set PropertyAddress = ISNULL(a.PropertyAddress, b. PropertyAddress)
 From Portfolio_Project.dbo.NashvilleHousing AS a
JOIN Portfolio_Project.dbo.NashvilleHousing AS b
 ON a.ParcelID= b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]

 -- Breaking out Adress into Individual Columns(Adress,City,State)
 Select PropertyAddress
From Portfolio_Project.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) AS Address, --CHARINDEX(',',PropertyAddress) isto é um numero como é obivo "-1" é para retirar a virgula
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM Portfolio_Project.dbo.NashvilleHousing



ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE Portfolio_Project.dbo.NashvilleHousing 
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE Portfolio_Project.dbo.NashvilleHousing 
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--Confirmar
Select *
From Portfolio_Project.dbo.NashvilleHousing

--PARECIDO MAS COM OUTRO METODO PARA O OwnerAddress

Select OwnerAddress
From Portfolio_Project.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From Portfolio_Project.dbo.NashvilleHousing
--mais facil, ter atenção à ordem
--Agora quero Adicionar estas colunas no Dataset
ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE Portfolio_Project.dbo.NashvilleHousing 
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE Portfolio_Project.dbo.NashvilleHousing 
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE Portfolio_Project.dbo.NashvilleHousing 
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)
--tenho de primeiro correr o alter table e só depois o update

Select *
From Portfolio_Project.dbo.NashvilleHousing

--Mudar  Y and N para Yes and NO no "Sold as Vacant" field

Select Distinct(SoldasVacant)
FROM Portfolio_Project.dbo.NashvilleHousing --tenho alguns "N", "Y","NO","YES", não quero assim

Select Distinct(SoldasVacant),Count(SoldAsVacant)
FROM Portfolio_Project.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldasVacant
,Case When SoldAsVacant = 'Y' THEN 'YES'
      WHEN SoldasVacant ='N' THEN 'No'
      Else SoldasVacant
      END
From Portfolio_Project.dbo.NashvilleHousing

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'YES'
      WHEN SoldasVacant ='N' THEN 'No'
      Else SoldasVacant
      END

---REMOVER DUPLICADOS(normalmente é melhor remover os duplicados noutra base que não a original de trbaalho)
 With RowNumCTE AS (
 SELECT *,
  ROW_NUMBER() OVER (
  Partition BY ParcelID,
               PropertyAddress,
               SalePrice,
               SaleDate,
               LegalReference
               Order BY
                UniqueID
                ) row_num
 FROM Portfolio_Project.dbo.NashvilleHousing
 --order by ParcelID
)
Select*
--DELETE - tive de usar isto para eliminar os duplicado, depois usei sleect para ve-los
FROM RowNumCTE
Where row_num>1

Select*
 FROM Portfolio_Project.dbo.NashvilleHousing

 ---APAGAR UNUSED COLUMNS(novamente é boa pratica NÃOO fazer isto na raw data)

 ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
 DROP Column OwnerAddress, TaxDistrict,PropertyAddress
 ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
 DROP Column SaleDate