-- 04_aggregations_for_powerbi.sql
-- Power BI–ready aggregate tables

-- 1) Total global debt by year
DROP TABLE IF EXISTS ids.pb_total_debt_by_year;
CREATE TABLE ids.pb_total_debt_by_year AS
SELECT
  year,
  SUM(debt_value) AS total_debt_usd
FROM ids.international_debt_long
GROUP BY year;

-- 2) Total debt by country & year
DROP TABLE IF EXISTS ids.pb_country_debt_by_year;
CREATE TABLE ids.pb_country_debt_by_year AS
SELECT
  country_code,
  country_name,
  year,
  SUM(debt_value) AS country_debt_usd
FROM ids.international_debt_long
GROUP BY country_code, country_name, year;

-- 3) Debt share (% of global) by country & year
DROP TABLE IF EXISTS ids.pb_country_debt_share;
CREATE TABLE ids.pb_country_debt_share AS
SELECT
  c.country_code,
  c.country_name,
  c.year,
  c.country_debt_usd,
  t.total_debt_usd,
  (c.country_debt_usd / NULLIF(t.total_debt_usd, 0)) AS debt_share
FROM ids.pb_country_debt_by_year c
JOIN ids.pb_total_debt_by_year t
  ON c.year = t.year;

-- 4) YoY growth by country
DROP TABLE IF EXISTS ids.pb_country_yoy_growth;
CREATE TABLE ids.pb_country_yoy_growth AS
SELECT
  country_code,
  country_name,
  year,
  country_debt_usd,
  country_debt_usd
    - LAG(country_debt_usd) OVER (PARTITION BY country_code ORDER BY year)
      AS abs_growth_usd,
  (country_debt_usd
    / NULLIF(LAG(country_debt_usd) OVER (PARTITION BY country_code ORDER BY year), 0) - 1)
      AS yoy_growth_pct
FROM ids.pb_country_debt_by_year;

-- 5) Ranking by debt each year
DROP TABLE IF EXISTS ids.pb_country_rank_by_year;
CREATE TABLE ids.pb_country_rank_by_year AS
SELECT
  country_code,
  country_name,
  year,
  country_debt_usd,
  RANK() OVER (PARTITION BY year ORDER BY country_debt_usd DESC) AS debt_rank
FROM ids.pb_country_debt_by_year;
