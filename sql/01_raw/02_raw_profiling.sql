-- PriceSense | Raw profiling checks
-- Extracted from your existing SQL working document.
-- Review the notes before running; this is an organization pass, not a verified clean-room migration.
-- NOTE: Read-only checks; safe to run after the raw tables exist.

SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores
FROM raw.sales;


SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(*) FILTER (WHERE item_type IS NULL) AS item_type_nulls,
    COUNT(*) FILTER (WHERE weight_volume IS NULL) AS weight_volume_nulls,
    COUNT(*) FILTER (WHERE weight_netto IS NULL) AS weight_netto_nulls,
    COUNT(*) FILTER (WHERE fatness IS NULL) AS fatness_nulls
FROM raw.catalog;


SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores,
    COUNT(*) FILTER (WHERE promo_type_code IS NULL) AS promo_type_code_nulls
FROM raw.discounts_history;


SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores,
    COUNT(DISTINCT price) AS unique_prices
FROM raw.price_history;


SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores
FROM raw.markdowns;


SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores
FROM raw.online;


SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores
FROM raw.actual_matrix;


SELECT
    table_name,
    (xpath('/row/count/text()', query_to_xml(
        format('SELECT COUNT(*) AS count FROM raw.%I', table_name),
        false,
        true,
        ''
    )))[1]::text::bigint AS row_count
FROM information_schema.tables
WHERE table_schema = 'raw'
ORDER BY table_name;


SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'raw'
  AND table_name = 'sales'
ORDER BY ordinal_position;

