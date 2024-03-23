-- Look into the data
SELECT *
FROM PortfolioProject..[age_std_suicide_rates_1990-2022]

SELECT *
FROM PortfolioProject..[suicide_rates_1990-2022]

----------------------------------------------------------------------------------------------
-- Look into the important variables - Suicide Count on each generation.
-- Find the rows that contains NULL value on SuicideCount to see how to deal with it.

SELECT *
FROM PortfolioProject..[suicide_rates_1990-2022]
WHERE SuicideCount IS NULL
ORDER BY CountryCode, Year, Sex, AgeGroup

----------------------------------------------------------------------------------------------
--Fix CountryName with ? mark
SELECT DISTINCT CountryName
FROM [suicide_rates_1990-2022]
WHERE CountryName LIKE '%?%'

SELECT DISTINCT CountryName
FROM [age_std_suicide_rates_1990-2022]
WHERE CountryName LIKE '%?%'

--R?union = Réunion (e fada), a French teritory. T?rkiye = Türkiye (u with two dots), Turkey in English.

SELECT
	CountryName,
	CASE WHEN CountryName = 'R?union' THEN 'Réunion'
	WHEN CountryName = 'T?rkiye' THEN 'Türkiye'
	ELSE CountryName END AS CountryNameUpdated
FROM [suicide_rates_1990-2022]

SELECT
	CountryName,
	CASE WHEN CountryName = 'R?union' THEN 'Réunion'
	WHEN CountryName = 'T?rkiye' THEN 'Türkiye'
	ELSE CountryName END AS CountryNameUpdated
FROM [age_std_suicide_rates_1990-2022]
--WHERE CountryName LIKE '%?%'

-- Create a new column CountryNameUpdated on each table
ALTER TABLE [suicide_rates_1990-2022] -- create a new column
Add CountryNameUpdated nvarchar(255);

UPDATE [suicide_rates_1990-2022]
SET CountryNameUpdated = CASE WHEN CountryName = 'R?union' THEN 'Réunion'
	WHEN CountryName = 'T?rkiye' THEN 'Türkiye'
	ELSE CountryName END

ALTER TABLE [age_std_suicide_rates_1990-2022] -- create a new column
Add CountryNameUpdated nvarchar(255);

UPDATE [age_std_suicide_rates_1990-2022]
SET CountryNameUpdated = CASE WHEN CountryName = 'R?union' THEN 'Réunion'
	WHEN CountryName = 'T?rkiye' THEN 'Türkiye'
	ELSE CountryName END

SELECT DISTINCT CountryName, CountryNameUpdated
FROM [age_std_suicide_rates_1990-2022]
WHERE CountryName LIKE '%?%'

----------------------------------------------------------------------------------------------
-- Deal with duplicate rows in sucide_rates table

SELECT *
FROM PortfolioProject..[suicide_rates_1990-2022]
WHERE CountryCode = 'JPN'
ORDER BY CountryCode, Year, AgeGroup -- most of the time the same agegroup has multiple rows, which need to be consolidated

--Compare the two datasets
SELECT SUM(SuicideCount)
FROM PortfolioProject..[suicide_rates_1990-2022]
WHERE CountryCode = 'JPN' AND Year = '2020'
--ORDER BY CountryCode, Year, AgeGroup

SELECT SUM(SuicideCount)
FROM PortfolioProject..[age_std_suicide_rates_1990-2022]
WHERE CountryCode = 'JPN' AND Year = '2020'

-- Add up SuicideCount for each country, year, sex, AgeGroup (remove duplicate rows) and name it as SumSuicideCount

SELECT RegionName, CountryCode, CountryNameUpdated, Year, Sex, AgeGroup, SUM(SuicideCount) AS SumSuicideCount, Population, GDP, GDPPerCapita, GrossNationalIncome, GNIPerCapita, InflationRate, EmploymentPopulationRatio
FROM PortfolioProject..[suicide_rates_1990-2022]
--WHERE CountryCode = 'JPN'
GROUP BY RegionName, CountryCode, CountryNameUpdated, Year, Sex, AgeGroup, Population, GDP, GDPPerCapita, GrossNationalIncome, GNIPerCapita, InflationRate, EmploymentPopulationRatio
ORDER BY RegionName, CountryNameUpdated, Year, AgeGroup

-- Create a new table with the above query

DROP TABLE IF EXISTS [#age_grp_suicide_rates_1990-2022]
CREATE TABLE [#age_grp_suicide_rates_1990-2022]
(
RegionName nvarchar(255), 
CountryCode nvarchar(255), 
CountryNameUpdated nvarchar(255), 
Year float, 
Sex nvarchar(255), 
AgeGroup nvarchar(255), 
Generation nvarchar(255), 
SumSuicideCount float, 
Population float, 
GDP float, 
GDPPerCapita float, 
GrossNationalIncome float, 
GNIPerCapita float, 
InflationRate float, 
EmploymentPopulationRatio float
)

INSERT INTO [#age_grp_suicide_rates_1990-2022]
SELECT RegionName, CountryCode, CountryNameUpdated, Year, Sex, AgeGroup, Generation, SUM(SuicideCount) AS SumSuicideCount, Population, GDP, GDPPerCapita, GrossNationalIncome, GNIPerCapita, InflationRate, EmploymentPopulationRatio
FROM PortfolioProject..[suicide_rates_1990-2022]
GROUP BY RegionName, CountryCode, CountryNameUpdated, Year, Sex, AgeGroup, Generation, Population, GDP, GDPPerCapita, GrossNationalIncome, GNIPerCapita, InflationRate, EmploymentPopulationRatio;

SELECT *
FROM [#age_grp_suicide_rates_1990-2022]
--WHERE CountryCode = 'JPN'
--ORDER BY RegionName, CountryNameUpdated, Year, AgeGroup


----------------------------------------------------------------------------------------------
-- Extract two tables for Tableau visualisation

SELECT *
FROM PortfolioProject..[age_std_suicide_rates_1990-2022]

SELECT *
FROM PortfolioProject..[#age_grp_suicide_rates_1990-2022]