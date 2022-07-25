/*
Covid 19 Data Exploration
About Dataset:- CSV File Downloaded from "ourworldindata.org/covid-deaths" which contains report of Covid-19
Skills used: Joins, Aggregate Functions, Creating Views, Converting Data Types, Filtering, Ordering, Grouping
*/

-- Viewing the Covid Table
SELECT * FROM portfolio.coviddeaths;

SELECT * FROM portfolio.covidvaccinations;

-- Selecting the Data to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio.coviddeaths
ORDER BY location, date;

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if covid spreds in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM portfolio.coviddeaths
ORDER BY location, date;

-- Top 10 Days when the Death Percentage was High
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM portfolio.coviddeaths
WHERE location like '%India%'
ORDER BY DeathPercentage DESC
LIMIT 10;

-- Countries having average death as per total cases is equal and more than 5
SELECT location, (SUM(total_deaths)/SUM(total_cases)) * 100 AS avg_death
FROM portfolio.coviddeaths
GROUP BY location
HAVING avg_death >= 5
ORDER BY avg_death DESC;

-- Looking at the Total Cases vs population
-- Shows Percentage of Population got Covid Affected
SELECT location, date, population, total_cases, (total_cases/population)*100 AS AffectedPercentage
FROM portfolio.coviddeaths
-- WHERE location = 'India'
ORDER BY location, date;

-- Countries with Highest Infection Rate Compared to Popolation
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS AffectedPercentage
FROM portfolio.coviddeaths
GROUP BY population, location
ORDER BY AffectedPercentage desc;

-- Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS DOUBLE)) AS TotalDeathCount
FROM portfolio.coviddeaths
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Let's Break things down by Continent

SELECT continent, MAX(CAST(total_deaths AS DOUBLE)) AS TotalDeathCount
FROM portfolio.coviddeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Showing the Location of each Continents having maximum Death Ratio
SELECT continent, location, MAX(CAST(total_deaths AS DOUBLE)) AS TotalDeathCount, MAX(CAST(total_cases AS DOUBLE)) AS TotalCaseCount,
	ROUND(MAX(CAST(total_deaths AS DOUBLE))/MAX(CAST(total_cases AS DOUBLE)),3) AS DeathRatio
FROM portfolio.coviddeaths
GROUP BY continent
ORDER BY DeathRatio DESC;

-- Global Numbers
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS DOUBLE)) AS TotalDeaths, SUM(CAST(new_deaths AS DOUBLE))/SUM(New_Cases)*100 As DeathPercent
FROM portfolio.coviddeaths
WHERE continent IS NOT NULL;

-- Day-by-Day Cases, Deaths and Death Percentage
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS DOUBLE)) AS TotalDeaths, SUM(CAST(new_deaths AS DOUBLE))/SUM(New_Cases)*100 As DeathPercent
FROM portfolio.coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- JOINS

SELECT *
FROM portfolio.coviddeaths dea
JOIN portfolio.covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date;

-- Total Average Cases VS Total Average Vaccinations By Countries
SELECT dea.location, AVG(dea.total_cases) AS avg_cases, AVG(vac.total_vaccinations) AS avg_vaccinations
FROM portfolio.coviddeaths dea
JOIN portfolio.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
GROUP BY dea.location
HAVING avg_cases > 0 and avg_vaccinations > 0;
ORDER BY avg_vaccinations DESC;

-- Number of People Fully Vaccinated By Countries
SELECT dea.location, SUM(people_fully_vaccinated) AS fully_vaccinated
FROM portfolio.coviddeaths dea
JOIN portfolio.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
GROUP BY location
--ORDER BY fully-cvaccinated DESC;

-- Positive Rate VS Death rate
SELECT dea.location, ROUND(AVG(vac.positive_rate),3) AS avg_positive_rate, ROUND(AVG(dea.total_deaths/dea.total_cases),3) AS avg_deaths
FROM portfolio.coviddeaths dea
JOIN portfolio.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
GROUP BY location
HAVING avg_positive_rate > 0;
