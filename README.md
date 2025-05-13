# Data-Exploration-in-SQL

## Table of Contents 
- [Project Overview](#project-overview)
- [Data Source](#data-source)
- [Tools](#tools)
- [Data Cleaning/Preparation](#datacleaning-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Exploration](#data-exploration)
- [Results](#results)

### Project Overview
The Covid '19 dataset was explored using SQL Server. Key insights on total cases vs. total deaths, countries with highest death count per population, total population vs. vaccination and mortality across different continents was uncovered.

### Data Source
The dataset explored is the "covid_19, csv" file, containing population, total cases, total deaths, total vaccinations.

### Tools
- Excel - Extraction & Cleaning
- SQL Server - Exploration

### Data Cleaning/Exploration
In the initial data preparationn phase, the following tasks was performed;
1. Data extraction, loading, inspection and cleaning
2. Splitting a dataset into two; Deaths & Vaccinations
3. Data formatting

### Exploratory Data Analysis
EDA involved exploring the Covid deaths & vaccination data to answer these questions;
1. What is the numer of total cases vs. deaths?
2. Which country has the highest death count per Population?
3. Total Population vs Vaccinations?

### Data Exploration

` Total cases vs. Total deaths`

````Select Location,population, Max(total_cases) as HighestPopulationInfected, Max(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not Null
Group By  Location,population
Order By PercentagePopulationInfected Desc ````


````Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not Null
Group By  Location
Order By TotalDeathCount Desc````

`Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths Dea
Join PortfolioProject.dbo.CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
 Where dea.continent is not null
 Order By 2,3`


### Results
