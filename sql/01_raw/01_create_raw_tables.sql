-- PriceSense | Raw table definitions
-- Extracted from your existing SQL working document.
-- Review the notes before running; this is an organization pass, not a verified clean-room migration.
-- NOTE: Contains CREATE TABLE definitions only. Data import commands are not included here; raw table schemas should be checked against the actual imported CSVs.

CREATE TABLE raw.sales (
    source_row_id BIGINT,
    date DATE,
    item_id TEXT,
    quantity DOUBLE PRECISION,
    price_base DOUBLE PRECISION,
    sum_total DOUBLE PRECISION,
    store_id INTEGER
);

SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores
FROM raw.sales;


CREATE TABLE raw.catalog (
    source_row_id BIGINT,
    item_id TEXT,
    dept_name TEXT,
    class_name TEXT,
    subclass_name TEXT,
    item_type TEXT,
    weight_volume DOUBLE PRECISION,
    weight_netto DOUBLE PRECISION,
    fatness DOUBLE PRECISION
);


SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(*) FILTER (WHERE item_type IS NULL) AS item_type_nulls,
    COUNT(*) FILTER (WHERE weight_volume IS NULL) AS weight_volume_nulls,
    COUNT(*) FILTER (WHERE weight_netto IS NULL) AS weight_netto_nulls,
    COUNT(*) FILTER (WHERE fatness IS NULL) AS fatness_nulls
FROM raw.catalog;


CREATE TABLE raw.discounts_history (
    source_row_id BIGINT,
    date DATE,
    item_id TEXT,
    sale_price_before_promo DOUBLE PRECISION,
    sale_price_time_promo DOUBLE PRECISION,
    promo_type_code DOUBLE PRECISION,
    doc_id TEXT,
    number_disc_day DOUBLE PRECISION,
    store_id INTEGER
);


SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores,
    COUNT(*) FILTER (WHERE promo_type_code IS NULL) AS promo_type_code_nulls
FROM raw.discounts_history;


CREATE TABLE raw.price_history (
    source_row_id BIGINT,
    date DATE,
    item_id TEXT,
    price DOUBLE PRECISION,
    code BIGINT,
    store_id INTEGER
);


SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores,
    COUNT(DISTINCT price) AS unique_prices
FROM raw.price_history;


CREATE TABLE raw.markdowns (
    source_row_id BIGINT,
    date DATE,
    item_id TEXT,
    normal_price DOUBLE PRECISION,
    price DOUBLE PRECISION,
    quantity DOUBLE PRECISION,
    store_id INTEGER
);


SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores
FROM raw.markdowns;


CREATE TABLE raw.online (
    source_row_id BIGINT,
    date DATE,
    item_id TEXT,
    quantity DOUBLE PRECISION,
    price_base DOUBLE PRECISION,
    sum_total DOUBLE PRECISION,
    store_id INTEGER
);


SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores
FROM raw.online;


CREATE TABLE raw.actual_matrix (
    source_row_id BIGINT,
    item_id TEXT,
    date DATE,
    store_id INTEGER
);


SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(DISTINCT store_id) AS unique_stores
FROM raw.actual_matrix;


CREATE TABLE raw.stores (
    source_row_id BIGINT,
    store_id INTEGER,
    division TEXT,
    format TEXT,
    city TEXT,
    area INTEGER
);

