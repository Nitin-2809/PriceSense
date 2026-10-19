-- PriceSense | Staging quality checks
-- Extracted from your existing SQL working document.
-- Review the notes before running; this is an organization pass, not a verified clean-room migration.
-- NOTE: Read-only checks, except none of these statements modify data.

SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores
FROM staging.sales;


SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE quantity < 0) AS negative_quantity,
    COUNT(*) FILTER (WHERE quantity = 0) AS zero_quantity,
    COUNT(*) FILTER (WHERE quantity > 0) AS positive_quantity,
    MIN(quantity) AS min_quantity,
    MAX(quantity) AS max_quantity,
    ROUND(AVG(quantity)::numeric, 6) AS mean_quantity
FROM staging.sales;


SELECT
    COUNT(*) AS suspicious_rows,
    COUNT(*) FILTER (WHERE price_base = 0.01) AS price_001_rows,
    COUNT(*) FILTER (
        WHERE price_base = 0.01
          AND quantity >= 100
    ) AS extreme_quantity_rows
FROM staging.sales;


SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE ABS(sum_total - (quantity * price_base)) > 0.01
    ) AS inconsistent_rows,
    MAX(ABS(sum_total - (quantity * price_base))) AS max_difference
FROM staging.sales;


SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (date, item_id, store_id)) AS unique_item_date_store,
    COUNT(*) - COUNT(DISTINCT (date, item_id, store_id)) AS duplicate_rows
FROM staging.sales;


SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(*) FILTER (WHERE item_type IS NULL) AS item_type_nulls,
    COUNT(*) FILTER (WHERE weight_volume IS NULL) AS weight_volume_nulls,
    COUNT(*) FILTER (WHERE weight_netto IS NULL) AS weight_netto_nulls,
    COUNT(*) FILTER (WHERE fatness IS NULL) AS fatness_nulls
FROM staging.catalog;


SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT store_id) AS unique_stores
FROM staging.stores;


SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores
FROM staging.price_history;


SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores
FROM staging.markdowns;


SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores
FROM staging.online;


SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores
FROM staging.actual_matrix;


SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores,
    COUNT(*) FILTER (WHERE promo_type_code IS NULL) AS promo_type_code_nulls
FROM staging.discounts_history;


SELECT
    table_name,
    COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_schema = 'staging'
GROUP BY table_name
ORDER BY table_name;


SELECT
    table_name
FROM information_schema.tables
WHERE table_schema = 'analytics'
ORDER BY table_name;

