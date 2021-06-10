SELECT * 
FROM PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT * FROM PorfolioProject..CovidVaccinations
--ORDER BY 3, 4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PorfolioProject..CovidDeaths
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid around the world

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths in New Zealand
-- Shows likelihood of dying if you contract covid in New Zealand

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
WHERE location like '%Zealand%'
ORDER BY 1, 2

-- Looking at Total Cases vs Population in New Zealand
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases,  (total_cases/population)*100 AS PopulationPercentage
FROM PorfolioProject..CovidDeaths
WHERE location like '%Zealand%'
ORDER BY 1, 2


-- Looking at Countries with the Highest Infection rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PopulationPercentage
FROM PorfolioProject..CovidDeaths
GROUP BY population, location
ORDER BY PopulationPercentage DESC

-- Showing Countries with the Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount  
FROM PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing Continents with the Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount  
FROM PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- Global Numbers (Total Deaths of Total Cases Percentage)

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1, 2


-- Looking at Total Population vs Vaccinations

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
FROM PorfolioProject..CovidDeaths cd
Join PorfolioProject..CovidVaccinations cv
	ON cd.location = cv.location 
	and cd.date = cv.date 
WHERE cd.continent IS NOT NULL 
ORDER BY 1, 2, 3

-- Looking at Total Population vs Vaccination in New Zealand

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
FROM PorfolioProject..CovidDeaths cd
Join PorfolioProject..CovidVaccinations cv
	ON cd.location = cv.location 
	and cd.date = cv.date 
WHERE cd.continent IS NOT NULL and cd.location like '%Zealand%'
ORDER BY 1, 2, 3

-- Looking at New Vaccinations per Day and Total Vaccinations Administered

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition By cd.location ORDER BY cv.location, cd.date) AS TotalVaccinationsAdministered
	FROM PorfolioProject..CovidDeaths cd
Join PorfolioProject..CovidVaccinations cv
	ON cd.location = cv.location 
	and cd.date = cv.date 
WHERE cd.continent IS NOT NULL 
ORDER BY 2, 3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, TotalVaccinationsAdministered) 
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition By cd.location ORDER BY cd.location, cd.date) AS TotalVaccinationsAdministered
--, (TotalVaccinationsAdministered/population)*100
FROM PorfolioProject..CovidDeaths cd
Join PorfolioProject..CovidVaccinations cv
	ON cd.location = cv.location 
	and cd.date = cv.date 
WHERE cd.continent IS NOT NULL 
-- ORDER BY 2, 3
)
SELECT *, (TotalVaccinationsAdministered/population)*100 FROM PopvsVac



-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVaccinationsAdministered numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition By cd.location ORDER BY cd.location, cd.date) AS TotalVaccinationsAdministered
--, (TotalVaccinationsAdministered/population)*100
FROM PorfolioProject..CovidDeaths cd
Join PorfolioProject..CovidVaccinations cv
	ON cd.location = cv.location 
	and cd.date = cv.date 
WHERE cd.continent IS NOT NULL 
--ORDER BY 2, 3

SELECT *, (TotalVaccinationsAdministered/population)*100 FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition By cd.location ORDER BY cd.location, cd.date) AS TotalVaccinationsAdministered
--, (TotalVaccinationsAdministered/population)*100
FROM PorfolioProject..CovidDeaths cd
Join PorfolioProject..CovidVaccinations cv
	ON cd.location = cv.location 
	and cd.date = cv.date 
WHERE cd.continent IS NOT NULL 
--ORDER BY 2, 3

CREATE VIEW VaccinatedNewZealanders AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
FROM PorfolioProject..CovidDeaths cd
Join PorfolioProject..CovidVaccinations cv
	ON cd.location = cv.location 
	and cd.date = cv.date 
WHERE cd.continent IS NOT NULL and cd.location like '%Zealand%'
--ORDER BY 1, 2, 3

CREATE VIEW HighestDeathCount AS
SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount  
FROM PorfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
--ORDER BY TotalDeathCount DESC

Create VIEW TotalDeathsInNZ AS 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
WHERE location like '%Zealand%'
--ORDER BY 1, 2

Create VIEW TotalCasesPercentage AS
SELECT Location, date, population, total_cases,  (total_cases/population)*100 AS PopulationPercentage
FROM PorfolioProject..CovidDeaths
WHERE location like '%Zealand%'
--ORDER BY 1, 2