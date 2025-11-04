--Select*
--FROM Portfolio_Project..CovidDeaths
--order by 3,4

--Select*
--FROM Portfolio_Project..CovidVaccinations
--order by 3,4

-- Select Data to actually use

Select Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..CovidDeaths
order by 1,2

-- Total cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
Where location like '%Portugal%'
order by 1,2

-- Total cases vs Population
Select Location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
FROM Portfolio_Project..CovidDeaths
Where location like '%Portugal%'
order by 1,2

-- Comparing Highest Rates of Infection
Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as MaxDeathPercentage
FROM Portfolio_Project..CovidDeaths
--Where location like '%Portugal%'
Group by Location, Population
order by MaxDeathPercentage desc

-- Highest Death Count
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Highest Death Count by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCountcontinent
FROM Portfolio_Project..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCountcontinent desc

-- 
-- Total cases vs Total Deaths
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentageGlobal
FROM Portfolio_Project..CovidDeaths
Where continent is not null
Group By date
order by 1,2

--Using a cte
With PopvsVac( Continent, Location,Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated  
From Portfolio_Project..CovidDeaths as dea
Join Portfolio_Project..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated  
From Portfolio_Project..CovidDeaths as dea
Join Portfolio_Project..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View for later visualization
Create View PercenPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated  
From Portfolio_Project..CovidDeaths as dea
Join Portfolio_Project..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*
From PercenPopulationVaccinated
