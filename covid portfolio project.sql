/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..CovidDeath
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
--arithmetic overflow in datatype int so use bigint

with popvsvac (continent , location , date , population , new_vaccinations , rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date)as rollingpeoplevaccinated
from portfolioproject..coviddeath dea
join portfolioproject..covidvac vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(rollingpeoplevaccinated/population)*100 as perrollvac
from popvsvac

--using temp table to perform calculation on partition by in previous query
--arithmetic overflow in datatype int so use bigint

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime ,
population numeric,
New_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select deat.continent,deat.location,deat.date,deat.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by deat.location order by deat.location , deat.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from portfolioproject..coviddeath deat
join portfolioproject..covidvac vac
    on deat.location=vac.location
	and deat.date=vac.date
--where dae.continent is not null
--order by 2,3


select *,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--creating view to store data for later visualisation
--arithmetic overflow in datatype int so use bigint


create view percentpeoplevaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as rollingpeoplevaccinated
from portfolioproject..coviddeath as dea
join portfolioproject..covidvac  as vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select*
from percentpeoplevaccinated