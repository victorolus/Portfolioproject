-- 1.

Select SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths, 
    SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
	From covid_vacc
	where continent is not null 
	order by 1,2;


-- 2.

Select location, 
	SUM(cast(new_deaths as int)) as TotalDeathCount 
    From covid_vacc 
    Where continent is not null and location in ('North America', 'Asia', 'Africa', 'South America', 'Europe', 'Oceania') 
    Group by location 
    order by TotalDeathCount desc;


-- 3.

Select Location, 
	Population, 
    max(cast(total_cases as int)) as HighestInfectionCount, 
    Max((total_cases/population))*100 as PercentPopulationInfected 
    From covid_vacc 
    Group by Location, Population 
    order by PercentPopulationInfected desc;


-- 4.


Select Location, 
	Population, date, 
	max(cast(total_cases as int)) as HighestInfectionCount, 
    Max((total_cases/population))*100 as PercentPopulationInfected 
    From covid_vacc
	Group by Location, Population, date
	order by PercentPopulationInfected desc;