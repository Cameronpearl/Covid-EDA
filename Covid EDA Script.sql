-- Death cases vs total cases by country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as mortality_percentage
from CovidDeaths$
order by 1, 2


-- Total cases vs population by country
select location, date, total_cases, population, (total_cases/population) * 100 as contracted_percentage
from CovidDeaths$
order by 1, 2


-- Countries with highest infection rate by population
select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population)*100) as max_population_infected_percentage
from CovidDeaths$
group by location, population
order by 4 desc

-- Countries with highest death count per population
select location, Max(total_deaths) as highest_death_count
from CovidDeaths$
where continent is not null
group by location
order by 2 desc

-- 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_vac_count
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null AND vac.new_vaccinations is not null
order by 1,2,3

--use cte

with popvsvac (Continent, location,date, population,new_vaccinations, rolling_vac_count)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_vac_count
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null

)
select *, (rolling_vac_count/population) *100 as percent_vac
from popvsvac


--temp table

drop table if exists #percentpopvaccinated
create table #percentpopvaccinated
(
continent nvarchar(255), 
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvaccount numeric
)

insert into #percentpopvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_vac_count
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null

select *, (rollingvaccount/population) *100 as percent_vac
from #percentpopvaccinated


-- creating view for visualizations later

Create View PercentPopVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_vac_count
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null