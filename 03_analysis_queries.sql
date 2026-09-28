--Covid Project SQL Script 03: Analysis
--*** Requires "01_setup_and_cleaning.sql" AND "02_data_quality_checks.sql" ***

---Q1: What are the most recent total global cases and total global deaths?
SELECT date, total_cases, total_deaths
FROM covid_deaths_clean
WHERE iso_code = 'OWID_WRL'
ORDER BY date DESC
LIMIT 1;

---Q2: Which countries have the highest total death count?
SELECT location, MAX(total_deaths) AS highest_total_deaths
FROM covid_deaths_clean
WHERE iso_code NOT LIKE '%OWID_%' AND total_deaths IS NOT NULL
GROUP BY location
ORDER BY highest_total_deaths DESC
LIMIT 10;

---Q3: What is the global death percentage overall?
SELECT total_cases, total_deaths,
ROUND((total_deaths/total_cases)*100, 2) AS global_death_percentage
FROM covid_deaths_clean
WHERE iso_code = 'OWID_WRL'
ORDER BY date DESC
LIMIT 1;

---Q4: Which continent has had the most total deaths?
SELECT location, MAX(total_deaths) AS total_deaths
FROM covid_deaths_clean
WHERE location IN ('Africa','Asia','Europe','North America','South America','Oceania')
GROUP BY location
ORDER BY total_deaths DESC;

---Q5: For South Africa, what does the trend in new_cases look like over time?
SELECT location, date, new_cases, 
LAG(new_cases) OVER (ORDER BY date) AS prev_day_new_cases,
new_cases - LAG(new_cases) OVER (ORDER BY date) AS change
FROM covid_deaths_clean
WHERE location = 'South Africa' AND 
new_cases IS NOT NULL;

---Q6: For each country, what percentage of the population has been infected at least once?
SELECT iso_code, location, date, population, total_cases, 
ROUND((total_cases/population)*100, 2) AS infection_rate
FROM covid_deaths_clean
WHERE date = (SELECT MAX(date) FROM covid_deaths_clean) AND
total_cases IS NOT NULL AND iso_code NOT LIKE '%OWID_%'
ORDER BY infection_rate DESC;

---Q7: Which country had the single highest daily new death count, and on what date?
SELECT iso_code, location, date, new_deaths
FROM covid_deaths_clean
WHERE new_deaths IS NOT NULL AND iso_code NOT LIKE '%OWID_%'
ORDER BY new_deaths DESC
LIMIT 1;

---Q8: What was the last recorded positive test rate for each country?
WITH latest_rate_date AS (
SELECT location, MAX(date) AS latest_date
FROM covid_vaccine_clean
WHERE positive_rate IS NOT NULL
GROUP By location
)
SELECT v.location, v.date, v.positive_rate
FROM covid_vaccine_clean AS v
JOIN latest_rate_date AS l
  ON v.location = l.location AND v.date = l.latest_date
WHERE v.iso_code NOT LIKE '%OWID_%'
ORDER BY v.positive_rate DESC;

---Q9: Which 10 countries had the highest positive rate at its peak?
SELECT location, ROUND(MAX(positive_rate) * 100, 2) AS peak_positive_rate
FROM covid_vaccine_clean
WHERE positive_rate IS NOT NULL AND iso_code NOT LIKE '%OWID_%'
GROUP BY location
ORDER BY peak_positive_rate DESC
LIMIT 10;

---Q10: Using a JOIN between covid_deaths and covid_vaccinations on location and date, calculate a rolling total of vaccinations per country over time.
--CREATE TABLE rolling_vaccines_clean AS
WITH rolling_vaccines AS (
SELECT d.location, d.date, d.new_deaths,
d.population,
v.new_vaccinations, 
SUM(v.new_vaccinations) OVER 
(PARTITION BY d.location ORDER by d.date) AS 
rolling_total
FROM covid_deaths_clean AS d
LEFT JOIN covid_vaccine_clean AS v
ON d.location = v.location AND d.date = v.date
WHERE d.iso_code NOT LIKE '%OWID_%'
)
SELECT *, ROUND((rolling_total/population)*100, 2) AS pct_population_vaccinated
FROM rolling_vaccines
WHERE rolling_total IS NOT NULL;

---Q11: Percentage of each country's population is fully vaccinated
WITH ranked AS (
    SELECT v.location,
           v.date,
           v.people_vaccinated,
           v.people_fully_vaccinated,
           d.population,
           ROW_NUMBER() OVER (PARTITION BY v.location ORDER BY v.date DESC) AS rn
    FROM covid_vaccine_clean AS v
    JOIN covid_deaths_clean AS d
      ON v.location = d.location AND v.date = d.date
    WHERE v.people_fully_vaccinated IS NOT NULL
      AND v.iso_code NOT LIKE '%OWID_%'
)
SELECT location,
       date AS latest_date,
       ROUND(people_fully_vaccinated / population * 100, 2) AS pct_fully_vaccinated,
       ROUND(people_vaccinated / population * 100, 2)       AS pct_at_least_one_dose
FROM ranked
WHERE rn = 1
ORDER BY pct_fully_vaccinated DESC;

---Q12: Compare death percentage trends before vs. after vaccination rollout began in Africa
WITH first_vaccine_date AS (
      SELECT location, MIN(date) AS vax_start_date
      FROM covid_vaccine_clean
      WHERE total_vaccinations IS NOT NULL
      GROUP BY location
  ),
before_after AS (
    SELECT d.location,
           d.continent,
           d.population,
           f.vax_start_date,
           AVG(CASE WHEN d.date >= f.vax_start_date - 30
                     AND d.date <  f.vax_start_date
                     AND d.new_deaths >= 0
                    THEN d.new_deaths END) AS avg_deaths_before,
           AVG(CASE WHEN d.date >= f.vax_start_date
                     AND d.date <  f.vax_start_date + 30
                     AND d.new_deaths >= 0
                    THEN d.new_deaths END) AS avg_deaths_after
    FROM covid_deaths_clean AS d
    JOIN first_vaccine_date AS f ON d.location = f.location
    WHERE d.continent = 'Africa'
      AND f.vax_start_date + 30 <= (SELECT MAX(date) FROM covid_deaths_clean)
    GROUP BY d.location, d.continent, d.population, f.vax_start_date
)
SELECT location,
       continent,
       vax_start_date,
       ROUND(avg_deaths_before / population * 1000000, 2) AS before_deaths_per_million,
       ROUND(avg_deaths_after  / population * 1000000, 2) AS after_deaths_per_million,
       ROUND((avg_deaths_after - avg_deaths_before)
             / NULLIF(avg_deaths_before, 0) * 100, 1)     AS pct_change
FROM before_after
ORDER BY pct_change;