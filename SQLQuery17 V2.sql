SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4




--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4



SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2



SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1, 2


SELECT location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1, 2


SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as
PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentofPopulationInfected DESC


SELECT location, population, MAX(cast(total_cases as int)) as HighestInfectionCount, MAX((CAST(total_cases as int)/population)) * 100 as
PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentofPopulationInfected DESC



SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null and location not like ('%income%') and location not like ('%world%') and location not like ('%union%')
GROUP BY location
ORDER BY TotalDeathCount DESC



--Showing continents with highest death counts

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC




-- Global numbers


 
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/NULLIF(SUM(new_cases), 0) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2


-- Looking at Total Population vs Vccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/popilation) * 100 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2, 3



-- USE CTE



WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/popilation) * 100 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



-- Temp table

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population) * 100 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--order by 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population) * 100 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2, 3


SELECT *
FROM PercentPopulationVaccinated