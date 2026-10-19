-- PriceSense | Power BI views
-- Extracted from your existing SQL working document.
-- Review the notes before running; this is an organization pass, not a verified clean-room migration.
-- NOTE: Contains two definitions of vw_powerbi_demand. The later definition replaces the earlier one; review and retain only the intended final definition before treating this as a polished deployment script.

CREATE OR REPLACE VIEW analytics.vw_powerbi_demand AS
SELECT
    date,
    item_id,
    store_id,
    quantity,
    price,
    sum_total AS revenue,

    -- Historical demand context
    store_demand_avg_28d,
    demand_avg_7d,
    demand_avg_28d,
    demand_volatility_28d,
    demand_trend_7d,
    demand_momentum_7d,

    -- Price analysis
    previous_price,
    price_vs_previous_pct,

    -- Promotion analysis
    promotion_flag,
    promo_type_code,
    time_promo,
    discount_pct,

    -- Markdown analysis
    markdown_flag,
    markdown_pct

FROM analytics.price_sense_features;


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



CREATE OR REPLACE VIEW analytics.vw_powerbi_product AS

SELECT
    item_id,
    dept_name,
    class_name,
    subclass_name,
    item_type,
    weight_volume,
    weight_netto,
    fatness
FROM analytics.catalog

UNION ALL

SELECT
    'UNKNOWN' AS item_id,
    'Unknown' AS dept_name,
    'Unknown' AS class_name,
    'Unknown' AS subclass_name,
    'Unknown' AS item_type,
    NULL::DOUBLE PRECISION AS weight_volume,
    NULL::DOUBLE PRECISION AS weight_netto,
    NULL::DOUBLE PRECISION AS fatness;


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


CREATE OR REPLACE VIEW analytics.vw_powerbi_demand AS
SELECT
    f.date,
    CASE
        WHEN c.item_id IS NULL THEN 'UNKNOWN'
        ELSE f.item_id
    END AS item_id,
    f.store_id,
    f.quantity,
    f.price,
    f.sum_total AS revenue,

    f.store_demand_avg_28d,
    f.demand_avg_7d,
    f.demand_avg_28d,
    f.demand_volatility_28d,
    f.demand_trend_7d,
    f.demand_momentum_7d,

    f.previous_price,
    f.price_vs_previous_pct,

    f.promotion_flag,
    f.promo_type_code,
    f.time_promo,
    f.discount_pct,

    f.markdown_flag,
    f.markdown_pct

FROM analytics.price_sense_features f
LEFT JOIN analytics.catalog c
    ON f.item_id = c.item_id;


CREATE OR REPLACE VIEW analytics.vw_powerbi_forecast AS
SELECT
    f.date,
    CASE
        WHEN p.item_id IS NULL THEN 'UNKNOWN'
        ELSE f.item_id
    END AS item_id,
    f.store_id,
    f.actual_demand,
    f.predicted_demand
FROM analytics.model_forecast f
LEFT JOIN analytics.catalog p
    ON f.item_id = p.item_id;


CREATE OR REPLACE VIEW analytics.vw_powerbi_pricing_scenario AS
SELECT
    item_id,
    store_id,
    date,
    current_demand,
    current_price,
    elasticity,
    price_change_pct,
    simulated_price,
    simulated_demand,
    simulated_revenue
FROM analytics.pricing_scenarios;

