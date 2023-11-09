
/*
Covid 19 Data Exploration 

Skills used: CTE, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Create table covid_vacc(iso_code text, continent text, location text, date DATE , population_density decimal, total_cases real, new_cases decimal, new_cases_smoothed decimal, total_deaths real, new_deaths decimal, new_deaths_smoothed decimal, total_cases_per_million decimal, new_cases_per_million decimal, new_cases_smoothed_per_million decimal, total_deaths_per_million decimal, new_deaths_per_million decimal, new_deaths_smoothed_per_million decimal, reproduction_rate decimal, icu_patients decimal, icu_patients_per_million decimal, hosp_patients decimal, hosp_patients_per_million decimal, weekly_icu_admissions decimal, weekly_icu_admissions_per_million decimal, weekly_hosp_admissions decimal, weekly_hosp_admissions_per_million decimal, total_tests decimal, new_tests decimal,total_tests_per_thousand decimal,new_tests_per_thousand decimal,new_tests_smoothed decimal,new_tests_smoothed_per_thousand decimal,positive_rate decimal,tests_per_case decimal,tests_units decimal,total_vaccinations decimal,people_vaccinated decimal,people_fully_vaccinated decimal,total_boosters decimal,new_vaccinations decimal,new_vaccinations_smoothed decimal,total_vaccinations_per_hundred decimal,people_vaccinated_per_hundred decimal,people_fully_vaccinated_per_hundred decimal,total_boosters_per_hundred decimal,new_vaccinations_smoothed_per_million decimal,new_people_vaccinated_smoothed decimal,new_people_vaccinated_smoothed_per_hundred decimal,stringency_index,median_age decimal,aged_65_older real,aged_70_older real,gdp_per_capita decimal,extreme_poverty decimal,cardiovasc_death_rate decimal,diabetes_prevalence decimal,female_smokers real,male_smokers real,handwashing_facilities decimal,hospital_beds_per_thousand decimal,life_expectancy decimal,human_development_index decimal,population real,excess_mortality_cumulative_absolute decimal,excess_mortality_cumulative decimal,excess_mortality decimal,excess_mortality_cumulative_per_million decimal);


-- Importing data and checking

.mode csv
.import /Users/Documents/covidvaccinations.csv covid_vacc; 
select * from covid_vacc limit 5;



-- Total Cases vs Total Deaths


Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage From covidvacc WHERE DeathPercentage > 1;



-- Looking at the Total cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, ROUND(total_deaths / total_cases, 20) AS death_percentage
FROM covid_vacc
LIMIT 200;



-- For Residents of the United Kingdom
-- Shows the likelihood of dying if covid is contracted in the UK.


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covid_vacc
where location like '%Kingdom%'
order by 1,2
LIMIT 300;



-- Looking at total cases vs population

SELECT location, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM covid_vacc
where location like '%Kingdom%'
order by 1,2
LIMIT 100;



-- Looking at countries with highest infection rates compared to the population.

SELECT location, population, max(cast(total_cases as INTEGER)) as HighestInfectionCount, total_deaths, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM covid_vacc
Group by location, population
order by PercentPopulationInfected desc;



-- Showing countries with the highest death count per population

Select Location, MAX(cast(Total_deaths as INTEGER)) as TotalDeathcount 
From covid_vacc
where continent is not null
Group by Location 
order by TotalDeathCount desc;



-- BREAKING THINGS DOWN BY CONTINENT
﻿﻿-- Showing continents with the highest death count per population

Select continent, MAX(cast (Total_deaths as INTEGER)) as TotalDeathcount From covid_vacc
Where continent is not null
Group by continent
order by TotalDeathCount desc;



-- Global numbers

Select date, SUM(new_cases)
as total_cases, SUM(cast(new_deaths as INTEGER)) as total_deaths, SUM(cast
(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covid_vacc
where continent is not null
Group By date 
order by 1,2;




-- Total Cases and total deaths a cross the world

Select SUM (new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast
(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covid_vacc
where continent is not null
order by 1,2;



-- looking at total population vs vaccinations

SELECT
  continent,
  location,
  date,
  population,
  new_vaccinations,
  SUM(CAST(new_vaccinations AS INTEGER)) OVER (PARTITION BY location ORDER BY location, date) AS cumulative_vaccinations
FROM covid_vacc
WHERE continent IS NOT NULL
ORDER BY location, date;



-- percentage of population that have been vaccinated. using TEMP TABLE

drop Table if exists PopvsVac
Create Table PopvsVac
Continent nvarchar (255), Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric


Insert into PopvsVac
SELECT
  continent,
  location,
  date,
  population,
  new_vaccinations,
  SUM(CAST(new_vaccinations AS INTEGER)) OVER (PARTITION BY location ORDER BY location, date) AS cumulative_vaccinations
FROM covid_vacc
WHERE continent IS NOT NULL
ORDER BY location, date;

Select *,
(cumulative_vaccinations/Population) *100
From PopvsVac;



-- percentage of population that have been vaccinated. using CTE 

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, cumulative_vaccinations) AS
(
  SELECT
    continent,
    location,
    date,
    population,
    new_vaccinations,
    SUM(CAST(new_vaccinations as INTEGER)) OVER (PARTITION BY Location ORDER BY Location, Date) as cumulative_vaccinations
  FROM covid_Vacc 
  WHERE continent IS NOT NULL
)
  
SELECT
  Continent,
  Location,
  Date,
  Population,
  New_Vaccinations,
  cumulative_vaccinations,
  (cumulative_vaccinations / Population) * 100 as VaccinationPercentage
FROM PopvsVac;



-- creating views to store data for later visualization

create view PercentPopulationVaccinated as 
SELECT continent, location, date, population, new_vaccinations,
SUM(CAST(new_vaccinations AS INTEGER)) OVER (PARTITION BY location ORDER BY location, date) AS cumulative_vaccinations
FROM covid_vacc
WHERE continent IS NOT NULL
ORDER BY location, date;
