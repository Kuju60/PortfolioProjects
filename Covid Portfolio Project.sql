SELECT *
FROM PortfolioProject_New..CovidDeath1
order by 3,4

SELECT *
FROM PortfolioProject_New..CovidVaccination1
order by 3,4

--Select data that we are going to be using

SELECT location, date, total_cases,total_deaths, population
FROM PortfolioProject_New..CovidDeath1
order by 1,2

--looking at total cases vs total deaths
--shows the likelihood of dying if one contract covid in ones country.
SELECT location, date, CAST(total_cases as int) as Total_cases,CAST(total_deaths as int)as Total_deaths, (CAST(total_deaths as int)/CAST(total_cases as int))*100 as DeathPercentage
FROM PortfolioProject_New..CovidDeath1
Where location like '%states%'
order by 1,2


--looking at the total cases vs population
--shows what percentage of population got covid

SELECT location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject_New..CovidDeath1
--Where location like '%Nigeria%'
order by 1,2

--looking at countries with the highest infection rate compared to population
SELECT location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject_New..CovidDeath1
--Where location like '%Nigeria%'
Group by location, population
order by PercentPopulationInfected desc

--showing countries with the highest death count per population
SELECT location,  max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject_New..CovidDeath1
--Where location like '%Nigeria%'
where continent is not null
Group by location
order by TotalDeathCount desc

--Breaking things down by continent
SELECT continent,  max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject_New..CovidDeath1
--Where location like '%Nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--showing continent with the highest death count per population
SELECT continent,  max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject_New..CovidDeath1
--Where location like '%Nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers

SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject_New..CovidDeath1
Where continent is not null
Group by date
order by 1,2


SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject_New..CovidDeath1
Where continent is not null
--Group by date
order by 1,2

--looking at total population vs vaccination

Select dea.continent,dea.location, dea.date,  dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject_New..CovidDeath1 dea
join PortfolioProject_New..CovidVaccination1 vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
order by 2,3
 

--use cte
with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location, dea.date,  dea.population, vac.new_vaccinations 
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject_New..CovidDeath1 dea
join PortfolioProject_New..CovidVaccination1 vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--Temp Table


DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date,  dea.population, vac.new_vaccinations 
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject_New..CovidDeath1 dea
join PortfolioProject_New..CovidVaccination1 vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualisations

CREATE View PercentPopulationVaccinated as
select dea.continent,dea.location, dea.date,  dea.population, vac.new_vaccinations 
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject_New..CovidDeath1 dea
join PortfolioProject_New..CovidVaccination1 vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated