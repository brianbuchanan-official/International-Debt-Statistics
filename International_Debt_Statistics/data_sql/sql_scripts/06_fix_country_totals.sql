-- 06_fix_country_totals.sql
-- Restrict country totals to external debt stock series only

DROP TABLE IF EXISTS ids.pb_country_debt_by_year;

CREATE TABLE ids.pb_country_debt_by_year AS
SELECT
  country_code,
  country_name,
  year,
  SUM(debt_value)::double precision AS country_debt_usd
FROM ids.international_debt_long
WHERE series_code LIKE 'DT.DOD.%'
GROUP BY country_code, country_name, year
ORDER BY country_name, year;

-- Rebuild dependent tables
DROP TABLE IF EXISTS ids.pb_country_debt_share;
CREATE TABLE ids.pb_country_debt_share AS
SELECT
  c.country_code,
  c.country_name,
  c.year,
  c.country_debt_usd,
  t.total_debt_usd,
  CASE WHEN t.total_debt_usd IS NULL OR t.total_debt_usd = 0 THEN NULL
       ELSE (c.country_debt_usd / t.total_debt_usd)
  END AS debt_share
FROM ids.pb_country_debt_by_year c
JOIN ids.pb_total_debt_by_year t
  ON c.year = t.year;

DROP TABLE IF EXISTS ids.pb_country_yoy_growth;
CREATE TABLE ids.pb_country_yoy_growth AS
WITH base AS (
  SELECT
    country_code,
    country_name,
    year,
    country_debt_usd,
    LAG(country_debt_usd) OVER (PARTITION BY country_code ORDER BY year) AS prev_debt
  FROM ids.pb_country_debt_by_year
)
SELECT
  country_code,
  country_name,
  year,
  country_debt_usd,
  (country_debt_usd - prev_debt) AS abs_growth_usd,
  CASE WHEN prev_debt IS NULL OR prev_debt = 0 THEN NULL
       ELSE (country_debt_usd / prev_debt - 1)
  END AS yoy_growth_pct
FROM base;

DROP TABLE IF EXISTS ids.pb_country_rank_by_year;
CREATE TABLE ids.pb_country_rank_by_year AS
SELECT
  country_code,
  country_name,
  year,
  country_debt_usd,
  RANK() OVER (PARTITION BY year ORDER BY country_debt_usd DESC) AS debt_rank
FROM ids.pb_country_debt_by_year;
