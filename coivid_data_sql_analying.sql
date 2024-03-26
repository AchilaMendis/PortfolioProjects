SELECT * 
FROM portfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4 

--SELECT * 
--FROM portfolioProject..CovidVaccinations
--ORDER BY 3,4 

--Selcet the Data that we are going to be use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioProject..CovidDeaths
ORDER BY 1,2
	
--Looking at total cases vs total Deaths
--shows likelihood of dying if you contract covid in your country 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
FROM portfolioProject..CovidDeaths
where location like '%lanka%'
ORDER BY 1,2

--Looking at total cases vs populaiton 
--shows what precentage of population 
SELECT location, date, population, total_cases, (total_cases/population)*100 as InflationRate
FROM portfolioProject..CovidDeaths
--where location like '%lanka%'
ORDER BY 1,2

--looking at countries with highest inflation rate compared to the population 
SELECT location, population, MAX(total_cases), MAX((total_cases/population)*100) as PrecentPopulaitonInfected
FROM portfolioProject..CovidDeaths
--where location like '%lanka%'
GROUP BY location, population
ORDER BY PrecentPopulaitonInfected DESC


--countries with highest death count per pracentage 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfolioProject..CovidDeaths
WHERE continent is not null
--where location like '%lanka%'
GROUP BY location
ORDER BY TotalDeathCount desc


--Let's look this thing by continent 
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfolioProject..CovidDeaths
WHERE continent is not null
--where location like '%lanka%'
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global Numbers
SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_eath , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPrecentage
FROM portfolioProject..CovidDeaths
WHERE continent is not null
--where location like '%lanka%'
--GROUP BY date
ORDER BY 1,2

--looking at total population vs total vacination 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
FROM portfolioProject..CovidDeaths dea
JOIN portfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 1,2,3

--Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
FROM portfolioProject..CovidDeaths dea
JOIN portfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 1,2,3 
)
SELECT *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table 
DROP Table if exists #PresentPopulationVaccinated
CREATE TABLE #PresentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date DateTime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
 
Insert Into #PresentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
FROM portfolioProject..CovidDeaths dea
JOIN portfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 1,2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
From #PresentPopulationVaccinated


--creating view to store data for latter visualizatation 

Create View PresentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
FROM portfolioProject..CovidDeaths dea
JOIN portfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 1,2,3

