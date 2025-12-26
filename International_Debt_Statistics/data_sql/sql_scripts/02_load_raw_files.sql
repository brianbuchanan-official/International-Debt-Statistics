TRUNCATE TABLE ids.international_debt_raw_combined;

\copy ids.international_debt_raw_combined FROM 'C:/Users/sorad/OneDrive/Desktop/International_Debt_Statistics/data_raw/ids_debtor_A-D.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

\copy ids.international_debt_raw_combined FROM 'C:/Users/sorad/OneDrive/Desktop/International_Debt_Statistics/data_raw/ids_debtor_R-U.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');

SELECT COUNT(*) AS raw_rows_loaded
FROM ids.international_debt_raw_combined;
