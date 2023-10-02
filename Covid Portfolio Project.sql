select*
from portfolioProject..['covid death$']
where continent is not null
order by 3,4

select*
from portfolioProject..['covid vaccinations$']
order by 3,4

-- select Data that we are going to be using 
select location,date,total_cases,total_deaths,population
from portfolioProject..['covid death$']
where continent is not null
order by 1,2


--Total deaths vs Total cases
select location,cast(total_cases as int) updatedcases,cast(total_deaths as int)updateddeaths
from portfolioproject..['covid death$']
where location like '%states%' and continent is not null
order by 1,2

with newone(location,updatedcases,updateddeaths)
as 
(
select location,cast(total_cases as int) updatedcases,cast(total_deaths as int)updateddeaths
from portfolioproject..['covid death$']
where location like '%states%' and continent is not null
)
select*,(updateddeaths/updatedcases)*100
from newone


--total cases vs total population
select location,date,population,total_cases,(total_cases/population)*100 as percentpopulationinfected
from portfolioProject..['covid death$']
where location like '%states%'and continent is not null
order by 1,2


--looking at countries with highest Infection rate compared to population

select location,population,max(total_cases)as highestinfectioncount,max((total_cases/population))*100 as percentpopulationinfected
from portfolioproject..['covid death$']
--where location like '%states%'
where continent is not null
group by location,population
order by percentpopulationinfected desc

-- Showing the countries with highest death count with

select location,max(total_deaths)as totaldeathcount
from portfolioproject..['covid death$']
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc


--Breaking things by continent
select continent,max(total_deaths)as totaldeathcount
from portfolioproject..['covid death$']
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc

--GLOBAL NUMBERS
select date,sum(new_cases) as total_cases,SUM(cast(new_deaths as int))
from portfolioProject..['covid death$']
where continent is not null 
group by date
order by 1,2
 
--use cte 

with globalnumbers(new_cases,new_deaths)
as
(
select sum(new_cases),SUM(cast(new_deaths as int))
from portfolioProject..['covid death$']
where continent is not null 
)
select*,(new_cases/new_deaths)*100
from globalnumbers


--Looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint))over (partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
from portfolioproject..['covid death$'] dea
join portfolioproject..['covid vaccinations$'] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3



 ---Identify locations where the reproduction rate is above 1.0:

 
SELECT location,[date],CAST(reproduction_rate AS FLOAT) AS reproduction_rate
FROM [dbo].['covid death$']
WHERE CAST(reproduction_rate AS FLOAT) > 1.0



--USE CTE
with popvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint))over (partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
from portfolioproject..['covid death$'] dea
join portfolioproject..['covid vaccinations$'] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select*,(RollingPeopleVaccinated/population)*100
from popvsVac


--Temp table
drop table if exists #PercentpopulationVaccinated1

create table #PercentpopulationVaccinated1
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations bigint,
RollingPeopleVaccinated numeric
)

 insert into #PercentpopulationVaccinated1
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint))over (partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
from portfolioproject..['covid death$'] dea
join portfolioproject..['covid vaccinations$'] vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
select*,(RollingPeopleVaccinated/population)*100
from #PercentpopulationVaccinated1



--Creating view to store data for later visualizations

create view PercentpopulationVaccinated1 as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint))over (partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
from portfolioproject..['covid death$'] dea
join portfolioproject..['covid vaccinations$'] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select*
from PercentpopulationVaccinated1
