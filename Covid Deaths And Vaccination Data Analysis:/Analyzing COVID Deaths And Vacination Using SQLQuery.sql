SELECT * FROM CovidDeaths
ORDER BY 3,4

--SELECT * FROM COVIDVACCINATIONS
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population from CovidDeaths
ORDER BY 1,2

--Looking at total_cases vs total_deaths
--Shows liklihood of dying if contracted covid in India

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
from CovidDeaths
Where location like '%India%'
ORDER BY 1,2


--Looking at total_cases vs population
--Shows percentage of people contrcted covid in India

SELECT location, date, total_cases, [population], (total_cases/[population])*100 AS PercentageCases
from CovidDeaths
Where location like '%India%'
ORDER BY 1,2


--Looking at countries with highest infection rates

SELECT location, [population], MAX(total_cases) AS Max_total_cases, max((total_cases/[population]))*100 AS PercentagePopulationInfected
from CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC


--Showing countries with highest death count per population

SELECT location, [population], MAX(total_deaths) AS Max_total_deaths, max((total_deaths/[population]))*100 AS PercentagePopulationDead
from CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopulationDead DESC


--Showing continent with highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
from CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Using View 

CREATE VIEW vWDeathCountPerPopulation
AS
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
from CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent


SELECT * FROM vWDeathCountPerPopulation
ORDER BY TotalDeathCount DESC

--Gobal death percentage

SELECT SUM(new_cases) AS TotalCases, sum(CAST(new_deaths AS int)) AS TotalDeaths, 
		(sum(CAST(new_deaths AS int))/sum(new_cases))*100 AS GobalDeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL


-- Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(cast(new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VacRunningTotal
FROM CovidDeaths dea
INNER Join CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- Percentage of population vaccinated
--Using CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, VacRunningTotal)
AS
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(cast(new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VacRunningTotal
FROM CovidDeaths dea
INNER Join CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

)

SELECT *, (VacRunningTotal/population)*100 AS PercentageVaccinated FROM PopvsVac
ORDER BY 2, 3


-- Percentage of population vaccinated
--Using CTE

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
VacRunningTotal numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(cast(new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VacRunningTotal
FROM CovidDeaths dea
INNER Join CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (VacRunningTotal/population)*100  AS PercentageVaccinated FROM #PercentPopulationVaccinated
ORDER BY 2, 3


-- Percentage of population vaccinated
--Using Views


CREATE VIEW vWPercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(cast(new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VacRunningTotal
FROM CovidDeaths dea
INNER Join CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (VacRunningTotal/population)*100  AS PercentageVaccinated FROM vWPercentPopulationVaccinated
ORDER BY 2, 3