-- PriceSense | Forecast table and validation
-- Extracted from your existing SQL working document.
-- Review the notes before running; this is an organization pass, not a verified clean-room migration.
-- NOTE: Machine-specific file path is commented out intentionally. Never assume a local file path works for another user or server.

CREATE TABLE analytics.model_forecast (
    date DATE NOT NULL,
    item_id TEXT NOT NULL,
    store_id INTEGER NOT NULL,
    actual_demand DOUBLE PRECISION,
    predicted_demand DOUBLE PRECISION
);

-- Original machine-specific COPY command was intentionally not made executable here:
-- COPY analytics.model_forecast FROM 'C:\Users\ADMIN\Desktop\PriceSense\notebooks\pricesense_forecast.csv' WITH (FORMAT CSV, HEADER TRUE);
-- Use a local psql \copy command with your own path, or pgAdmin Import/Export, after confirming the CSV columns.

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (date, item_id, store_id)) AS unique_grain,
    MIN(date) AS start_date,
    MAX(date) AS end_date,
    COUNT(*) FILTER (WHERE predicted_demand IS NULL) AS null_predictions
FROM analytics.model_forecast;

