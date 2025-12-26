-- 05_fix_global_total.sql
-- Fix global totals by restricting to true external debt series

DROP TABLE IF EXISTS ids.pb_total_debt_by_year;

CREATE TABLE ids.pb_total_debt_by_year AS
SELECT
  year,
  SUM(debt_value)::double precision AS total_debt_usd
FROM ids.international_debt_long
WHERE series_code LIKE 'DT.DOD.%'
GROUP BY year
ORDER BY year;
