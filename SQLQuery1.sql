select * from sql_testing..['owid-covid-data$']
where continent is not null
order by 3,4


--select * from sql_testing..['covid-vaccination$']
--order by 3,4

--select specific data from table

select location, date, total_cases, new_cases, total_deaths, population
from sql_testing..['owid-covid-data$']
order by 1,2

--looking for total_cases vs total_deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from sql_testing..['owid-covid-data$']
where location like '%india%'
order by 1,2

--looking at total_cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as total_population_percentage
from sql_testing..['owid-covid-data$']
where location like '%india%'
order by 1,2

--looking for highest no of infection compared to population

select location, population, max(total_cases) as infectioncount, max(total_cases/population)*100 as population_percentage
from sql_testing..['owid-covid-data$']
--where location like '%india%'
group by location, population
order by population_percentage desc


--countries  with hightest death rate per population

select location, max(cast(total_deaths as int)) as deathcount
from sql_testing..['owid-covid-data$']
--where location like '%india%'
where continent is not null
group by location
order by deathcount desc

--continent which has hightest death rate per population

select continent, max(cast(total_deaths as int)) as deathcount
from sql_testing..['owid-covid-data$']
--where location like '%india%'
where continent is not null
group by continent
order by deathcount desc


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from sql_testing..['owid-covid-data$']
where continent is not null
--group by date 
order by  1,2

--joining two tables 
--getting vaccinated nos based location 

With temp (continent, location, date, population, new_vaccinations, peoplevaccinated)
as
(
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dth.location order by dth.location, dth.date) as peoplevaccinated
from sql_testing..['owid-covid-data$'] dth
join sql_testing..['covid-vaccination$'] vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
--order by 2,3
)
select *, (peoplevaccinated/population*100) as vaccinatedperpopulation
from temp
--group by location 
--order by location desc


drop table if exists percentagepopulationvaccinated
create table percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
peoplevaccinated numeric
)

insert into percentagepopulationvaccinated
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dth.location order by dth.location, dth.date) as peoplevaccinated
from sql_testing..['owid-covid-data$'] dth
join sql_testing..['covid-vaccination$'] vac
	on dth.location = vac.location
	and dth.date = vac.date

select *, (peoplevaccinated/population*100) as vaccinatedperpopulation
from percentagepopulationvaccinated


--view for visvalisation

create view ppv as
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dth.location order by dth.location, dth.date) as peoplevaccinated
from sql_testing..['owid-covid-data$'] dth
join sql_testing..['covid-vaccination$'] vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
drop view ppv