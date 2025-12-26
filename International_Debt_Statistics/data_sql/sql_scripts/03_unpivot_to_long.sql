-- 03_unpivot_to_long.sql
-- Convert wide raw table to long format staging table

-- Start fresh (safe)
TRUNCATE TABLE ids.international_debt_long;

INSERT INTO ids.international_debt_long (
  country_code,
  country_name,
  counterpart_area_code,
  counterpart_area_name,
  series_code,
  series_name,
  year,
  debt_value
)
SELECT
  r.country_code,
  r.country_name,
  r.counterpart_area_code,
  r.counterpart_area_name,
  r.series_code,
  r.series_name,
  v.year::SMALLINT AS year,
  v.debt_value
FROM ids.international_debt_raw_combined r
CROSS JOIN LATERAL (
  VALUES
    (1970, r.y1970), (1971, r.y1971), (1972, r.y1972), (1973, r.y1973), (1974, r.y1974),
    (1975, r.y1975), (1976, r.y1976), (1977, r.y1977), (1978, r.y1978), (1979, r.y1979),
    (1980, r.y1980), (1981, r.y1981), (1982, r.y1982), (1983, r.y1983), (1984, r.y1984),
    (1985, r.y1985), (1986, r.y1986), (1987, r.y1987), (1988, r.y1988), (1989, r.y1989),
    (1990, r.y1990), (1991, r.y1991), (1992, r.y1992), (1993, r.y1993), (1994, r.y1994),
    (1995, r.y1995), (1996, r.y1996), (1997, r.y1997), (1998, r.y1998), (1999, r.y1999),
    (2000, r.y2000), (2001, r.y2001), (2002, r.y2002), (2003, r.y2003), (2004, r.y2004),
    (2005, r.y2005), (2006, r.y2006), (2007, r.y2007), (2008, r.y2008), (2009, r.y2009),
    (2010, r.y2010), (2011, r.y2011), (2012, r.y2012), (2013, r.y2013), (2014, r.y2014),
    (2015, r.y2015), (2016, r.y2016), (2017, r.y2017), (2018, r.y2018), (2019, r.y2019),
    (2020, r.y2020), (2021, r.y2021), (2022, r.y2022), (2023, r.y2023), (2024, r.y2024),
    (2025, r.y2025), (2026, r.y2026), (2027, r.y2027), (2028, r.y2028), (2029, r.y2029),
    (2030, r.y2030), (2031, r.y2031), (2032, r.y2032)
) AS v(year, debt_value)
WHERE v.debt_value IS NOT NULL;

-- QC checks
SELECT COUNT(*) AS long_rows_loaded
FROM ids.international_debt_long;

SELECT
  MIN(year) AS min_year,
  MAX(year) AS max_year,
  COUNT(DISTINCT country_code) AS countries,
  COUNT(DISTINCT series_code) AS series_codes
FROM ids.international_debt_long;
