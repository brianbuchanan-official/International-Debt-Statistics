-- 01_create_tables.sql
-- International Debt Statistics (World Bank IDS)
-- Option B: One combined raw table for both Excel files

-- Create a dedicated schema (optional but clean)
CREATE SCHEMA IF NOT EXISTS ids;

-- 1) Combined raw import table (wide format, years as columns)
-- We store all year columns as NUMERIC so we can handle large USD values + decimals + NULLs safely.
DROP TABLE IF EXISTS ids.international_debt_raw_combined;

CREATE TABLE ids.international_debt_raw_combined (
    country_code            TEXT,
    country_name            TEXT,
    counterpart_area_name   TEXT,
    counterpart_area_code   TEXT,
    series_name             TEXT,
    series_code             TEXT,

    y1970 NUMERIC, y1971 NUMERIC, y1972 NUMERIC, y1973 NUMERIC, y1974 NUMERIC,
    y1975 NUMERIC, y1976 NUMERIC, y1977 NUMERIC, y1978 NUMERIC, y1979 NUMERIC,
    y1980 NUMERIC, y1981 NUMERIC, y1982 NUMERIC, y1983 NUMERIC, y1984 NUMERIC,
    y1985 NUMERIC, y1986 NUMERIC, y1987 NUMERIC, y1988 NUMERIC, y1989 NUMERIC,
    y1990 NUMERIC, y1991 NUMERIC, y1992 NUMERIC, y1993 NUMERIC, y1994 NUMERIC,
    y1995 NUMERIC, y1996 NUMERIC, y1997 NUMERIC, y1998 NUMERIC, y1999 NUMERIC,
    y2000 NUMERIC, y2001 NUMERIC, y2002 NUMERIC, y2003 NUMERIC, y2004 NUMERIC,
    y2005 NUMERIC, y2006 NUMERIC, y2007 NUMERIC, y2008 NUMERIC, y2009 NUMERIC,
    y2010 NUMERIC, y2011 NUMERIC, y2012 NUMERIC, y2013 NUMERIC, y2014 NUMERIC,
    y2015 NUMERIC, y2016 NUMERIC, y2017 NUMERIC, y2018 NUMERIC, y2019 NUMERIC,
    y2020 NUMERIC, y2021 NUMERIC, y2022 NUMERIC, y2023 NUMERIC, y2024 NUMERIC,
    y2025 NUMERIC, y2026 NUMERIC, y2027 NUMERIC, y2028 NUMERIC, y2029 NUMERIC,
    y2030 NUMERIC, y2031 NUMERIC, y2032 NUMERIC
);

-- Helpful indexes for filtering later (Power BI + aggregations)
CREATE INDEX IF NOT EXISTS idx_ids_raw_country_code
ON ids.international_debt_raw_combined (country_code);

CREATE INDEX IF NOT EXISTS idx_ids_raw_series_code
ON ids.international_debt_raw_combined (series_code);

-- 2) Final long-format staging table (single source of truth for Power BI)
DROP TABLE IF EXISTS ids.international_debt_long;

CREATE TABLE ids.international_debt_long (
    country_code           TEXT NOT NULL,
    country_name           TEXT NOT NULL,
    counterpart_area_code  TEXT,
    counterpart_area_name  TEXT,
    series_code            TEXT NOT NULL,
    series_name            TEXT,
    year                   SMALLINT NOT NULL CHECK (year BETWEEN 1970 AND 2032),
    debt_value             NUMERIC,

    -- Prevent duplicate rows after we load/unpivot multiple files
    CONSTRAINT uq_ids_long UNIQUE (
        country_code,
        counterpart_area_code,
        series_code,
        year
    )
);

CREATE INDEX IF NOT EXISTS idx_ids_long_year
ON ids.international_debt_long (year);

CREATE INDEX IF NOT EXISTS idx_ids_long_country_year
ON ids.international_debt_long (country_code, year);

CREATE INDEX IF NOT EXISTS idx_ids_long_series_year
ON ids.international_debt_long (series_code, year);

