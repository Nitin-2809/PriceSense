-- PriceSense | Staging table creation
-- Extracted from your existing SQL working document.
-- Review the notes before running; this is an organization pass, not a verified clean-room migration.
-- NOTE: Creates staging tables from raw tables. CREATE TABLE statements will fail if the target tables already exist; do not rerun blindly.

CREATE TABLE staging.sales AS
SELECT
    source_row_id,
    date,
    item_id,
    quantity,
    price_base,
    sum_total,
    store_id
FROM raw.sales;


CREATE TABLE staging.catalog AS
SELECT
    source_row_id,
    item_id,
    dept_name,
    class_name,
    subclass_name,
    item_type,
    weight_volume,
    weight_netto,
    fatness
FROM raw.catalog;


CREATE TABLE staging.stores AS
SELECT
    source_row_id,
    store_id,
    division,
    format,
    city,
    area
FROM raw.stores;


CREATE TABLE staging.price_history AS
SELECT
    source_row_id,
    date,
    item_id,
    price,
    code,
    store_id
FROM raw.price_history;


CREATE TABLE staging.markdowns AS
SELECT
    source_row_id,
    date,
    item_id,
    normal_price,
    price,
    quantity,
    store_id
FROM raw.markdowns;


CREATE TABLE staging.online AS
SELECT
    source_row_id,
    date,
    item_id,
    quantity,
    price_base,
    sum_total,
    store_id
FROM raw.online;


CREATE TABLE staging.actual_matrix AS
SELECT
    source_row_id,
    item_id,
    date,
    store_id
FROM raw.actual_matrix;


CREATE TABLE staging.discounts_history AS
SELECT
    source_row_id,
    date,
    item_id,
    sale_price_before_promo,
    sale_price_time_promo,
    promo_type_code,
    doc_id,
    number_disc_day,
    store_id
FROM raw.discounts_history;

