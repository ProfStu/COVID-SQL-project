--Covid Project SQL Script 02: Data Quality Checks
--*** Requires "01_setup_and_cleaning.sql" **

---Covid deaths table:
----Checking NULL values in continent field
SELECT *
FROM covid_deaths_clean
WHERE continent IS NULL; --the regions and territories have NULL values for continent.

----Checking MIN/MAX dates in table
SELECT MIN(date) AS earliest,
MAX(date) AS latest
FROM covid_deaths_clean; -- Earliest date in dataset is 01/01/2020
-- Latest date in dataset is 30/04/2021

----Checking data errors in new_deaths
SELECT COUNT(new_deaths) AS negative_deaths
FROM covid_deaths_clean
WHERE new_deaths < 0; -- 83 records have negative new deaths, could be capturing error.

SELECT DISTINCT(iso_code)
FROM covid_deaths_clean
WHERE new_deaths < 0; --44 locations have reported negative deaths

----Checking distinct locations
SELECT COUNT(DISTINCT(location))
FROM covid_deaths_clean; --219 unique locations in dataset, not all locations are countries, some are regions and territories

----Checking whether there are rows where total cases is greater than population 
SELECT population, total_cases
FROM covid_deaths_clean
WHERE total_cases > population; --There are no rows where total cases is greater than population

---Covid vaccines table:
----Checking NUll values in total_vaccinations
SELECT *
FROM covid_vaccine_clean
WHERE total_vaccinations IS NULL;

----Checking earliest date for vaccinations in data
SELECT MIN(date)
FROM covid_vaccine_clean
WHERE total_vaccinations IS NOT NULL; --the earliest date for vaccinations is 14/12/2020

----Are there rows where number of people fully vaccinated is greater than the number of people vaccinated?
SELECT *
FROM covid_vaccine_clean
WHERE people_fully_vaccinated > people_vaccinated; --There are no rows where number of people fully vaccinated is greater than the number of people vaccinated.

----Do covid deaths and covid vaccine tables have the same iso codes
SELECT COUNT(DISTINCT(iso_code))
FROM covid_vaccine_clean
WHERE iso_code like '%OWID_%';

SELECT COUNT(DISTINCT(iso_code))
FROM covid_deaths_clean
WHERE iso_code like '%OWID_%'; -- Both tables have 11

----Checking duplicate rows
SELECT location, date, COUNT(*) AS duplicate_count
FROM covid_vaccine_clean
GROUP BY location, date
HAVING COUNT(*)>1; --No duplicate rows for location and date.

----Checking if location values in both tables are the same
SELECT location
FROM covid_deaths_clean
EXCEPT
SELECT location 
FROM covid_vaccine_clean; --both tables have same values in location
