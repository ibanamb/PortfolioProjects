--Portfolio Project to showcase SQL skills.
--I utilised COVID-19 dataset available at https://ourworldindata.org/covid-deaths (retrieved on 20-Feb-2024).

SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3, 4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3, 4;

--Select data we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY location, date;

--Looking at Total cases vs Total deaths
--Shows likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, population, ROUND((CAST(total_deaths AS numeric)/CAST(total_cases AS numeric))*100,2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Japan'
AND continent IS NOT NULL
ORDER BY location, date DESC;

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
SELECT location, date, population, CAST(total_cases AS numeric) AS total_cases, CAST(total_deaths AS numeric) AS total_deaths, ROUND((CAST(total_cases AS numeric)/CAST(population AS numeric))*100,2) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Japan'
AND continent IS NOT NULL
ORDER BY total_cases desc;

--Looking at Countries with highest infection rate compared to population
SELECT location, population, MAX(CAST(total_cases AS numeric)) AS total_cases, MAX((CAST(total_cases AS numeric)/CAST(population AS numeric))*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

--Showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc;


--Break things down by continent
SELECT location, MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount desc;


SELECT continent, MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- Showing continents with the highest death count per population 

SELECT continent, MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;


--Global numbers

SELECT SUM(CAST(new_cases AS int)) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1, 2;


--Looking at total population vs vaccinations

SELECT
	dea.continent, 
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations, -- new_vaccinations per day
	SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ AS dea
INNER JOIN PortfolioProject..CovidVaccinations$ AS vac -- JOIN will work as INNER JOIN
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

--Create CTE 

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(
SELECT
	dea.continent, 
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations, -- new_vaccinations per day
	SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ AS dea
INNER JOIN PortfolioProject..CovidVaccinations$ AS vac -- JOIN will work as INNER JOIN
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/CAST(population AS numeric))*100 AS PopvsVac
FROM PopvsVac
ORDER BY location, date

-- create Temp table
IF EXISTS(SELECT [name] FROM tempdb.sys.tables WHERE [name] like '#PercentPopulationVaccinated%') 
BEGIN
   DROP TABLE #PercentPopulationVaccinated;
END;
 
--DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT
	dea.continent, 
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations, -- new_vaccinations per day
	SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ AS dea
INNER JOIN PortfolioProject..CovidVaccinations$ AS vac -- JOIN will work as INNER JOIN
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS PopvsVac
FROM #PercentPopulationVaccinated
ORDER BY location, date

--Creating View to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT
	dea.continent, 
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations, -- new_vaccinations per day
	SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ AS dea
INNER JOIN PortfolioProject..CovidVaccinations$ AS vac -- JOIN will work as INNER JOIN
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
