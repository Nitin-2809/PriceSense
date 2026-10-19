-- PriceSense | Feature table validation
-- Extracted from your existing SQL working document.
-- Review the notes before running; this is an organization pass, not a verified clean-room migration.
-- NOTE: Read-only validation queries.

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT source_row_id) AS unique_source_rows,
    COUNT(DISTINCT (date, item_id, store_id)) AS unique_sales_grain,
    MIN(date) AS min_date,
    MAX(date) AS max_date
FROM analytics.sales_derived_features;


SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT source_row_id) AS unique_source_rows,
    COUNT(DISTINCT (date, item_id, store_id)) AS unique_sales_grain,
    COUNT(*) FILTER (WHERE price IS NULL) AS null_price,
    COUNT(*) FILTER (WHERE previous_price IS NULL) AS null_previous_price,
    COUNT(*) FILTER (WHERE quantity_lag_1 IS NULL) AS null_lag_1,
    COUNT(*) FILTER (WHERE quantity_lag_7 IS NULL) AS null_lag_7,
    COUNT(*) FILTER (WHERE quantity_lag_14 IS NULL) AS null_lag_14,
    COUNT(*) FILTER (WHERE quantity_lag_28 IS NULL) AS null_lag_28,
    COUNT(*) FILTER (WHERE promotion_flag = 1) AS promotion_rows,
    COUNT(*) FILTER (WHERE markdown_flag = 1) AS markdown_rows
FROM analytics.price_sense_features;

