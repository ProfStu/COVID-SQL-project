# COVID-19 Global Trends Analysis (PostgreSQL)
An end-to-end SQL analysis of global COVID-19 cases, deaths, testing and vaccinations, built in PostgreSQL using the Our World in Data (OWID) dataset.

## Overview
This project takes the raw OWID COVID-19 dataset, cleans and validates it in PostgreSQL, and answers 12 analytical questions covering global trends, country and continent comparisons, testing, and vaccination rollout. It demonstrates data cleaning, data quality checks, joins, CTEs, window functions and conditional aggregation.

- **Data source:** [Our World in Data COVID-19 dataset](https://ourworldindata.org/covid-deaths) (`owid-covid-data.csv`)
- **Coverage:** 1 January 2020 to 30 April 2021, across 219 locations (countries, territories and regional aggregates)
- **Tools:** PostgreSQL, pgAdmin 4, Python

## Repository structure
```
├── README.md
├── data/
│   ├── CovidDeaths.csv
│   └── CovidVaccinations.csv
├── sql/
│   ├── 01_setup_and_cleaning.sql
│   ├── 02_data_quality_checks.sql
│   └── 03_analysis_queries.sql
├── outputs/
│   └── COVID_SQL_outputs.xlsx
└── charts/
│   ├── 01: South Africa's 7-day Average Cases
│   ├── 02: Ten Countries with Most Deaths
│   ├── 03: Ten Countries with the Highest Percentage of Fully Vaccinated People
│   └── 04: Before/after deaths per million for African countries
```

## Data preparation
1. **Raw import:** The CSV was split into two tables (deaths and vaccinations) and loaded as `TEXT` columns, so that no values were lost or mis-cast on import. Header rows imported as data were deleted.
2. **Clean tables:** `covid_deaths_clean` and `covid_vaccine_clean` were created by casting columns to their correct types (`DATE`, `NUMERIC`, `BIGINT`) and keeping only the fields used in the analysis.
3. **Aggregate rows:** OWID includes regional and income-group rows (iso codes beginning `OWID_`). These are excluded from country-level queries and used only for global and continent figures.

## Data quality checks
| Check | Result |
|-------|--------|
| Date range | 1 Jan 2020 to 30 Apr 2021 |
| Distinct locations | 219, including regions and territories |
| Continent NULLs | Occur on regional and aggregate rows only |
| Negative `new_deaths` | 83 rows across 44 locations, consistent with source data corrections. These were excluded from the before/after analysis (Q12) |
| Cases greater than population | None |
| Fully vaccinated greater than people vaccinated | None |
| Duplicate location/date rows | None in the vaccinations table [add result for deaths table] |
| Location consistency | Both tables contain the same set of locations |
| First vaccination recorded | 14 Dec 2020 |

## Analysis summary
| # | Question | SQL techniques | Key finding |
|---|----------|----------------|-------------|
| 1 | What are the latest global cases and deaths? | Filtering, `ORDER BY ... LIMIT` | About 151.4M confirmed cases and 3.18M deaths by 30 Apr 2021 |
| 2 | Which countries have the highest total deaths? | `GROUP BY`, `MAX` | US (576,232), Brazil (403,781), Mexico (216,907), India (211,853), UK (127,775) |
| 3 | What is the global death percentage? | Calculated fields | 2.1% of confirmed cases (case fatality rate, not infection fatality rate) |
| 4 | Which continent has the most deaths? | Filtering on aggregate rows | Europe (about 1.02M), North America (about 848k), South America (about 672k), Asia (about 520k), Africa (about 122k), Oceania (about 1k) |
| 5 | What does South Africa's new-case trend look like? | Window function (`LAG`) | Daily cases peaked at 21,980 on 8 Jan 2021 |
| 6 | What share of each population has been infected? | Scalar subquery, ratios | Andorra (17.1%), Montenegro (15.5%), Czechia (15.2%) highest; US 9.8%; South Africa 2.7% |
| 7 | Which country had the highest single-day deaths? | Filtering, sorting | US, 4,474 deaths on 12 Jan 2021 |
| 8 | What was each country's last recorded positive test rate? | CTE, self-join | Ecuador (39.8%) and Paraguay (36.6%) highest. A few countries' latest readings are months old |
| 9 | Which countries had the highest peak positive rate? | `MAX`, `GROUP BY` | Bosnia and Herzegovina (74.2%), Bolivia (63.6%), Senegal (57.1%) |
| 10 | What is the rolling vaccination total per country? | `JOIN`, `SUM() OVER (PARTITION BY)` | Cumulative doses tracked for 141 countries |
| 11 | What percentage of each population is fully vaccinated? | CTE, `ROW_NUMBER()`, join | Median 6.6% fully vaccinated. US 30.6%, UK 21.4%, South Africa 0.54% |
| 12 | How did daily deaths change in the 30 days before vs after first vaccination (Africa)? | CTEs, conditional `AVG(CASE WHEN)`, date arithmetic | Deaths per million fell in 23 of 32 countries, but mostly reflects wave timing |

## Key takeaways
- **The burden was uneven.** Large absolute death tolls were concentrated in the US, Brazil, Mexico, India and the UK, while confirmed infection rates were highest in small European countries.
- **Testing shaped what was visible.** Positive rates above 50% in several countries at their peak suggest that confirmed cases substantially undercounted infections.
- **Vaccination was highly unequal by April 2021.** The median country had 6.6% of its population fully vaccinated, while wealthier countries and small territories were far ahead. South Africa was at 0.54%.
- **A before/after comparison is not evidence of vaccine impact.** South Africa's death rate fell 68.5% in the 30 days after its first vaccination (6.32 to 1.99 deaths per million per day), yet under 1% of its population was fully vaccinated. The fall reflects the end of the January wave. Some countries, such as Botswana, Namibia and Cape Verde, saw deaths rise because their own waves were building.

## Limitations
- **Cut-off date:** The data ends on 30 April 2021, so all "latest" figures are as of that date.
- **Confirmed figures only:** Cases and deaths depend on each country's testing capacity and reporting practices. Cross-country comparisons should be read with this in mind.
- **Negative daily values:** 83 negative `new_deaths` rows reflect source corrections. They were excluded from the Q12 before/after windows.
- **Stale testing data:** Some countries stopped reporting testing data months before the cut-off, so Q8 is not a like-for-like snapshot. Dates are shown alongside each rate.
- **Vaccination denominators:** OWID uses a fixed population estimate, so small territories can exceed 100% (Gibraltar shows 111% with at least one dose, likely due to non-resident vaccinations).
- **Q12 is descriptive, not causal:** Windows are short (30 days), early vaccination coverage was very low, and the analysis doesn't control for epidemic wave timing or reporting delays. Only 35 African countries had a full 30-day post-rollout window, and three had no computable percentage change.
- **Continent totals** use OWID's pre-aggregated continent rows rather than summing countries.

## How to run
1. Download `owid-covid-data.csv` from [Our World in Data](https://ourworldindata.org/covid-deaths).
2. Create a PostgreSQL database and load the data into the raw tables using the setup script.
3. Run `sql/01_setup_and_cleaning.sql`, then `sql/02_data_quality_checks.sql`, then `sql/03_analysis_queries.sql`. Run the analysis queries one at a time to inspect each result.

## Author
Stuart Morrison | [LinkedIn](www.linkedin.com/in/stuart-morrison-184988190)
