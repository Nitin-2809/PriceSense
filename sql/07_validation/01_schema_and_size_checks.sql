-- PriceSense | Schema inventory and size checks
-- Extracted from your existing SQL working document.
-- Review the notes before running; this is an organization pass, not a verified clean-room migration.
-- NOTE: Read-only inventory and data-quality queries. Some checks rely on tables/views created in earlier stages.

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


SELECT
    schemaname,
    tablename
FROM pg_tables
WHERE schemaname IN ('raw', 'staging', 'analytics')
ORDER BY schemaname, tablename;


SELECT
    tablename,
    pg_size_pretty(
        pg_total_relation_size(
            format('%I.%I', schemaname, tablename)
        )
    ) AS total_size
FROM pg_tables
WHERE schemaname IN ('raw', 'staging', 'analytics')
ORDER BY
    CASE schemaname
        WHEN 'raw' THEN 1
        WHEN 'staging' THEN 2
        WHEN 'analytics' THEN 3
    END,
    tablename;



SELECT
    schemaname,
    tablename
FROM pg_tables
WHERE schemaname = 'analytics'
  AND tablename IN (
      'model_comparison',
      'pricing_recommendations',
      'pricing_summary'
  )
ORDER BY tablename;


SELECT
    table_schema,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'analytics'
  AND table_name IN (
      'price_sense_features',
      'pricing_recommendations',
      'pricing_summary',
      'model_comparison'
  )
ORDER BY
    table_name,
    ordinal_position;


SELECT
    'catalog' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT item_id) AS unique_keys
FROM analytics.catalog

UNION ALL

SELECT
    'stores' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT store_id) AS unique_keys
FROM analytics.stores;


SELECT
    'price_sense_features' AS table_name,
    COUNT(*) AS rows,
    MIN(date) AS min_date,
    MAX(date) AS max_date
FROM analytics.price_sense_features

UNION ALL

SELECT
    'pricing_recommendations',
    COUNT(*),
    MIN(date),
    MAX(date)
FROM analytics.pricing_recommendations;



SELECT
    'missing_products' AS check_name,
    COUNT(*) AS missing_rows
FROM analytics.price_sense_features f
LEFT JOIN analytics.catalog c
    ON f.item_id = c.item_id
WHERE c.item_id IS NULL

UNION ALL

SELECT
    'missing_stores',
    COUNT(*)
FROM analytics.price_sense_features f
LEFT JOIN analytics.stores s
    ON f.store_id = s.store_id
WHERE s.store_id IS NULL;


SELECT
    COUNT(*) AS missing_fact_rows,
    COUNT(DISTINCT f.item_id) AS missing_unique_items,
    MIN(f.date) AS first_date,
    MAX(f.date) AS last_date
FROM analytics.price_sense_features f
LEFT JOIN analytics.catalog c
    ON f.item_id = c.item_id
WHERE c.item_id IS NULL;


SELECT
    'missing_products' AS check_name,
    COUNT(*) AS missing_rows
FROM analytics.pricing_recommendations p
LEFT JOIN analytics.catalog c
    ON p.item_id = c.item_id
WHERE c.item_id IS NULL

UNION ALL

SELECT
    'missing_stores',
    COUNT(*)
FROM analytics.pricing_recommendations p
LEFT JOIN analytics.stores s
    ON p.store_id = s.store_id
WHERE s.store_id IS NULL;


SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (date, item_id, store_id)) AS unique_sales_grain
FROM analytics.vw_powerbi_demand;


SELECT
    COUNT(*) AS catalog_rows,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(*) FILTER (WHERE item_id IS NULL) AS null_item_ids
FROM analytics.catalog;

SELECT
    store_id,
    division,
    format,
    city,
    area
FROM analytics.stores
ORDER BY store_id;


SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT item_id) AS unique_item_ids,
    COUNT(*) FILTER (WHERE item_id = 'UNKNOWN') AS unknown_rows
FROM analytics.vw_powerbi_product;

CREATE OR REPLACE VIEW analytics.vw_powerbi_store AS
SELECT
    store_id,
    division,
    format,
    city,
    area
FROM analytics.stores;


SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT store_id) AS unique_store_ids,
    COUNT(*) FILTER (WHERE store_id IS NULL) AS null_store_ids
FROM analytics.vw_powerbi_store;

