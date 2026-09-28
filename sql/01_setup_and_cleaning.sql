--Covid Project SQL Script 01: Setup and Cleaning
--*** Requires "CovidDeaths.csv" AND "CovidVaccinations.csv" ***

---Importing CovidDeaths table:
CREATE TABLE covid_deaths_raw (
iso_code TEXT, 
continent TEXT, 
location TEXT, 
date TEXT, 
total_cases TEXT, 
new_cases TEXT, 
new_cases_smoothed TEXT, 
total_deaths TEXT, 
new_deaths TEXT, 
new_deaths_smoothed TEXT, 
total_cases_per_million TEXT, 
new_cases_per_million TEXT, 
new_cases_smoothed_per_million TEXT, 
total_deaths_per_million TEXT, 
new_deaths_per_million TEXT, 
new_deaths_smoothed_per_million TEXT, 
reproduction_rate TEXT, 
icu_patients TEXT, 
icu_patients_per_million TEXT, 
hosp_patients TEXT, 
hosp_patients_per_million TEXT, 
weekly_icu_admissions TEXT, 
weekly_icu_admissions_per_million TEXT, 
weekly_hosp_admissions TEXT, 
weekly_hosp_admissions_per_million TEXT, 
new_tests TEXT, 
population TEXT, 
population_density TEXT, 
median_age TEXT, 
aged_65_older TEXT, 
aged_70_older TEXT, 
gdp_per_capita TEXT, 
extreme_poverty TEXT, 
cardiovasc_death_rate TEXT, 
diabetes_prevalence TEXT, 
female_smokers TEXT, 
male_smokers TEXT, 
handwashing_facilities TEXT, 
hospital_beds_per_thousand TEXT, 
life_expectancy TEXT, 
human_development_index TEXT
);

---Checking data:
SELECT *
FROM covid_deaths_raw
LIMIT 10; --Field names imported as record

----Deleting record:
DELETE FROM covid_deaths_raw 
WHERE population = 'population';

---Importing Covid Vaccines table:
CREATE TABLE covid_vaccines_raw (
iso_code TEXT, 
continent TEXT, 
location TEXT, 
date TEXT, 
new_tests TEXT, 
total_tests TEXT, 
total_tests_per_thousand TEXT, 
new_tests_per_thousand TEXT, 
new_tests_smoothed TEXT, 
new_tests_smoothed_per_thousand TEXT, 
positive_rate TEXT, 
tests_per_case TEXT, 
tests_units TEXT, 
total_vaccinations TEXT, 
people_vaccinated TEXT, 
people_fully_vaccinated TEXT, 
new_vaccinations TEXT, 
new_vaccinations_smoothed TEXT, 
total_vaccinations_per_hundred TEXT, 
people_vaccinated_per_hundred TEXT, 
people_fully_vaccinated_per_hundred TEXT, 
new_vaccinations_smoothed_per_million TEXT
);

---Checking data:
SELECT *
FROM covid_vaccines_raw
LIMIT 10; --Field names imported as record

----Deleting record:
DELETE FROM covid_vaccines_raw 
WHERE iso_code = 'iso_code';

---Creating clean covid deaths table for data analysis:
CREATE TABLE covid_deaths_clean AS
SELECT iso_code, 
location, 
continent,
population::BIGINT,
date::DATE, 
total_cases::NUMERIC, 
new_cases:: NUMERIC,  
total_deaths::NUMERIC,
new_deaths::NUMERIC
FROM covid_deaths_raw;

---Creating clean covid vaccines table for data analysis:
CREATE TABLE covid_vaccine_clean AS
SELECT iso_code, 
continent, 
location, 
date::DATE,
total_tests::NUMERIC,
positive_rate::NUMERIC,
total_vaccinations::NUMERIC, 
people_vaccinated::NUMERIC, 
people_fully_vaccinated::NUMERIC, 
new_vaccinations::NUMERIC
FROM covid_vaccines_raw;
