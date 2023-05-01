/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select * from Portfolio_Project..CovidDeaths$
where continent is not null
order by 3,4

-- Select Data that we are going to be starting with

select Location,date,total_cases,new_cases,total_deaths,population
from Portfolio_Project..CovidDeaths$
order by 1,2

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(Total_deaths/total_cases)*100  as DeathPrecentage
from Portfolio_Project..CovidDeaths$
where location like '%Israel%'
order by DeathPrecentage DESC


-- Looking at total cases vs Population
-- Shows what precentage of population got covid
 
create view InfPrecntage as
(
select location,date,population,total_cases,(total_cases/Population)*100  as InfectionPrecentage
from Portfolio_Project..CovidDeaths$
where location like '%Israel%'
)
-- Shows the first time time where the infection precentage exceeded 1%

select top(1) * from InfPrecntage
where InfectionPrecentage>=1
order by 1,2,5

-- countries with highest infection rate compared to poluation

select location,population,max(total_cases) as 'highest infection count',
max((total_cases/Population)*100)  as InfectionPrecentage
from Portfolio_Project..CovidDeaths$
group by Location,Population
order by 4 desc

-- Showing the continents with the highest death count

select continent,max(cast(total_deaths as int)) as 'total death count'
from Portfolio_Project..CovidDeaths$
where continent is not null
group by continent
order by 'total death count' desc

-- GLOBAL NUMBERS

select sum(new_cases) 'total cases',
sum(cast(new_deaths as int)) 'total deaths',
(sum(cast(new_deaths as int))/sum(new_cases))*100 'Death Precentage'
from Portfolio_Project..CovidDeaths$
where continent is not null
order by 1,2

-- Total population vs vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as 'RollingPeopleVaccinated'
from Portfolio_Project..CovidDeaths$ dea join Portfolio_Project..CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with PopVsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as 'RollingPeopleVaccinated'
from Portfolio_Project..CovidDeaths$ dea join Portfolio_Project..CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
)

select *,(RollingPeopleVaccinated/Population)*100 from PopVsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Portfolio_Project..CovidDeaths$ dea join Portfolio_Project..CovidVaccinations$ vac
On dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store date for later visualizations
create view PopVsVacView as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as 'RollingPeopleVaccinated'
from Portfolio_Project..CovidDeaths$ dea join Portfolio_Project..CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
)

select *,(RollingPeopleVaccinated/Population)*100 from PopVsVacView

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
Covid SQL queries used for Tableau Project
*/


-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths$
where continent is not null 
order by 1,2


-- 2. 

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths$
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
