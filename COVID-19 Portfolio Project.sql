SELECT *
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--WHERE Continent IS NOT null
--ORDER BY 3,4

-- Selecting Data to Use

SELECT Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country 

SELECT Location, Date, Total_Cases, Total_Deaths, (Total_Deaths/Total_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'
AND Continent IS NOT null
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows the percentage of the population that has contracted COVID

SELECT Location, Date, Population, Total_Cases, (Total_Cases/Population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
--AND Continent IS NOT null
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
-- Shows the highest infection rate of each country compared to the percent of population that has contracted COVID

SELECT Location, Population, MAX(Total_Cases) AS HighestInfectionCount, MAX((Total_Cases/Population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
--AND Continent IS NOT null
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Looking at Countries with the Highest Death Count per Population
-- Shows the highest death count per country

SELECT Location, MAX(CAST(Total_Deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Break Down by Continent 
-- Showing continents with the highest death count per population

SELECT Location, MAX(CAST(Total_Deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

-- Global Numbers by Date

SELECT Date, SUM(New_Cases) AS Total_Cases, SUM(CAST(New_Deaths AS int)) AS Total_Deaths, SUM(CAST(New_Deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT null
GROUP BY Date
ORDER BY 1,2

-- Global Numbers in Total

SELECT SUM(New_Cases) AS Total_Cases, SUM(CAST(New_Deaths AS int)) AS Total_Deaths, SUM(CAST(New_Deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT null
--GROUP BY Date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

-- Using Covert
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, SUM(CONVERT(bigint,vac.New_Vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	AND dea.Date = vac.Date
WHERE dea.Continent IS NOT null
ORDER BY 2,3

--Using Cast
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, SUM(CAST(vac.New_Vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	AND dea.Date = vac.Date
WHERE dea.Continent IS NOT null
ORDER BY 2,3



-- Using CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, SUM(CONVERT(bigint,vac.New_Vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	AND dea.Date = vac.Date
WHERE dea.Continent IS NOT null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--Creating a Temp Table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, SUM(CONVERT(bigint,vac.New_Vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	AND dea.Date = vac.Date
WHERE dea.Continent IS NOT null
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to Store Data for Later Visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, SUM(CONVERT(bigint,vac.New_Vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	AND dea.Date = vac.Date
WHERE dea.Continent IS NOT null
--ORDER BY 2,3
