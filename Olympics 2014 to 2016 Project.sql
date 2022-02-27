/*
Cleaning Data in SQL Queries
*/

USE PortfolioProject
SELECT *
FROM Olympics2014to2016 

-- Fixing the Team Column. There are typos for some of the countries listed in the Team column. Here, the typos will be fixed and then inserted as a new column: TeamFixed.

USE PortfolioProject
SELECT *
FROM Olympics2014to2016 
WHERE NOC = 'LAT' AND Team <> 'Latvia'
OR NOC = 'NED' AND Team <> 'Netherlands'
OR NOC = 'POL' AND Team <> 'Poland'
OR NOC = 'ROU' AND Team <> 'Romania'
OR NOC = 'SVK' AND Team <> 'Slovakia'
OR NOC = 'UKR' AND Team <> 'Ukraine'

USE PortfolioProject
SELECT *, 
CASE
	WHEN NOC = 'LAT' THEN 'Latvia'
	WHEN NOC = 'NED' THEN 'Netherlands'
	WHEN NOC = 'POL' THEN 'Poland'
	WHEN NOC = 'ROU' THEN 'Romania'
	WHEN NOC = 'SVK' THEN 'Slovakia'
	WHEN NOC = 'UKR' THEN 'Ukraine'
	Else Team
	END AS TeamFixed
FROM Olympics2014to2016 
ORDER BY NOC

USE PortfolioProject
ALTER TABLE Olympics2014to2016 
ADD TeamFixed NVARCHAR(100);

USE PortfolioProject
UPDATE Olympics2014to2016
SET TeamFixed = CASE WHEN NOC = 'LAT' THEN 'Latvia'
	WHEN NOC = 'NED' THEN 'Netherlands'
	WHEN NOC = 'POL' THEN 'Poland'
	WHEN NOC = 'ROU' THEN 'Romania'
	WHEN NOC = 'SVK' THEN 'Slovakia'
	WHEN NOC = 'UKR' THEN 'Ukraine'
	Else Team
	END

-------------------------------------------------------------------------------------------------------------------------------------------
-- Fixing the Sex Column. The Sex colum has some NULL values. This will be fixed by performing a Self Join and updating the table's information.

USE PortfolioProject
SELECT *
FROM Olympics2014to2016 
WHERE Sex IS NULL

USE PortfolioProject
SELECT Olympics1.ID, Olympics1.Sex, Olympics2.ID, Olympics2.Sex, ISNULL(Olympics1.Sex,Olympics2.Sex)
FROM Olympics2014to2016 Olympics1
JOIN Olympics2014to2016 Olympics2
	ON Olympics1.ID = Olympics2.ID
	AND Olympics1.Row <> Olympics2.Row
WHERE Olympics1.Sex IS NULL

UPDATE Olympics1
SET Sex = ISNULL(Olympics1.Sex,Olympics2.Sex)
FROM Olympics2014to2016 Olympics1
JOIN Olympics2014to2016 Olympics2
	ON Olympics1.ID = Olympics2.ID
	AND Olympics1.Row <> Olympics2.Row
WHERE Olympics1.Sex IS NULL

-------------------------------------------------------------------------------------------------------------------------------------------
-- Splitting the Games Column. The year and season are both included in the Games column. This data is being split into two new columns: Year and Season.

USE PortfolioProject
SELECT *, (SUBSTRING(Games, 1, 4)) AS Year
FROM Olympics2014to2016 

USE PortfolioProject
ALTER TABLE Olympics2014to2016 
ADD Year INT;

USE PortfolioProject
UPDATE Olympics2014to2016
SET Year = SUBSTRING(Games, 1, 4)

USE PortfolioProject
SELECT *, (SUBSTRING(Games, 5, 10)) AS Season
FROM Olympics2014to2016 

USE PortfolioProject
ALTER TABLE Olympics2014to2016 
ADD Season NVARCHAR(10);

USE PortfolioProject
UPDATE Olympics2014to2016
SET Season = SUBSTRING(Games, 5, 10)

-------------------------------------------------------------------------------------------------------------------------------------------
-- Fixing the City Column. Some of the cities listed have typos. Here, the typos will be fixed and then inserted into a new column: CityFixed.

USE PortfolioProject
SELECT *
FROM Olympics2014to2016 
WHERE City <> 'Sochi'
AND City <> 'Rio de Janeiro'

USE PortfolioProject
SELECT *, 
CASE
	WHEN City = 'Sochii' THEN 'Sochi'
	Else City
	END AS CityFixed
FROM Olympics2014to2016 

USE PortfolioProject
ALTER TABLE Olympics2014to2016 
ADD CityFixed NVARCHAR(100);

USE PortfolioProject
UPDATE Olympics2014to2016
SET CityFixed = CASE WHEN City = 'Sochii' THEN 'Sochi'
	Else City
	END