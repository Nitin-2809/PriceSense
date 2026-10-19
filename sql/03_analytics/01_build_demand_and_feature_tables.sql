-- PriceSense | Demand and feature engineering
-- Extracted from your existing SQL working document.
-- Review the notes before running; this is an organization pass, not a verified clean-room migration.
-- NOTE: Depends on analytics base tables such as analytics.sales, analytics.catalog, analytics.stores, analytics.price_history, analytics.discounts_history, and analytics.markdowns. Those base-table creation/loading steps are not fully represented in this extracted section, so verify prerequisites before execution.

CREATE TABLE analytics.daily_store_demand AS
SELECT
    date,
    store_id,
    SUM(quantity) AS total_quantity
FROM analytics.sales
GROUP BY
    date,
    store_id;


SELECT
    COUNT(*) AS row_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT store_id) AS unique_stores,
    MIN(total_quantity) AS min_total_quantity,
    MAX(total_quantity) AS max_total_quantity
FROM analytics.daily_store_demand;


CREATE TABLE analytics.store_history AS
SELECT
    date,
    store_id,
    total_quantity,
    AVG(total_quantity) OVER (
        PARTITION BY store_id
        ORDER BY date
        RANGE BETWEEN INTERVAL '28 days' PRECEDING
              AND INTERVAL '1 day' PRECEDING
    ) AS store_demand_avg_28d
FROM analytics.daily_store_demand;


SELECT
    COUNT(*) AS row_count,
    COUNT(*) FILTER (WHERE store_demand_avg_28d IS NULL) AS null_avg_rows,
    MIN(store_demand_avg_28d) AS min_avg,
    MAX(store_demand_avg_28d) AS max_avg
FROM analytics.store_history;


SELECT
    store_id,
    MIN(date) AS first_date,
    MIN(store_demand_avg_28d) AS first_available_avg
FROM analytics.store_history
GROUP BY store_id
ORDER BY store_id;


SELECT
    store_id,
    date,
    total_quantity,
    store_demand_avg_28d
FROM analytics.store_history
WHERE date = (
    SELECT MIN(sh2.date)
    FROM analytics.store_history sh2
    WHERE sh2.store_id = analytics.store_history.store_id
)
ORDER BY store_id;


SELECT
    store_id,
    date,
    total_quantity,
    store_demand_avg_28d
FROM analytics.store_history
WHERE store_id = 1
ORDER BY date
LIMIT 5;


CREATE TABLE analytics.price_history_enriched AS
SELECT
    source_row_id,
    date,
    item_id,
    price,
    code,
    store_id,
    LAG(price) OVER (
        PARTITION BY item_id, store_id
        ORDER BY date
    ) AS previous_price
FROM analytics.price_history;


SELECT
    item_id,
    store_id,
    date,
    price,
    previous_price
FROM analytics.price_history_enriched
WHERE previous_price IS NOT NULL
ORDER BY item_id, store_id, date
LIMIT 10;


SELECT
    COUNT(*) AS duplicate_date_rows,
    COUNT(DISTINCT (item_id, store_id, date)) AS unique_item_store_dates
FROM analytics.price_history;


CREATE TABLE analytics.sales_price_features AS
SELECT
    source_row_id,
    date,
    item_id,
    store_id,
    quantity,
    price_base AS price,
    sum_total,
    LAG(price_base) OVER (
        PARTITION BY item_id, store_id
        ORDER BY date
    ) AS previous_price
FROM analytics.sales;


CREATE TABLE analytics.sales_demand_features AS
SELECT
    *,
    LAG(quantity, 1) OVER (
        PARTITION BY item_id, store_id
        ORDER BY date
    ) AS quantity_lag_1,

    LAG(quantity, 7) OVER (
        PARTITION BY item_id, store_id
        ORDER BY date
    ) AS quantity_lag_7,

    LAG(quantity, 14) OVER (
        PARTITION BY item_id, store_id
        ORDER BY date
    ) AS quantity_lag_14,

    LAG(quantity, 28) OVER (
        PARTITION BY item_id, store_id
        ORDER BY date
    ) AS quantity_lag_28

FROM analytics.sales_price_features;


CREATE TABLE analytics.sales_rolling_features AS
SELECT
    *,
    
    AVG(quantity) OVER (
        PARTITION BY item_id, store_id
        ORDER BY date
        ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
    ) AS demand_avg_7d,

    AVG(quantity) OVER (
        PARTITION BY item_id, store_id
        ORDER BY date
        ROWS BETWEEN 28 PRECEDING AND 1 PRECEDING
    ) AS demand_avg_28d,

    STDDEV(quantity) OVER (
        PARTITION BY item_id, store_id
        ORDER BY date
        ROWS BETWEEN 28 PRECEDING AND 1 PRECEDING
    ) AS demand_volatility_28d,

    AVG(quantity) OVER (
        PARTITION BY item_id, store_id
        ORDER BY date
        ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
    )
    -
    AVG(quantity) OVER (
        PARTITION BY item_id, store_id
        ORDER BY date
        ROWS BETWEEN 28 PRECEDING AND 1 PRECEDING
    ) AS demand_trend_7d

FROM analytics.sales_demand_features;



CREATE TABLE analytics.sales_calendar_features AS
SELECT
    *,
    EXTRACT(YEAR FROM date)::INTEGER AS year,
    EXTRACT(MONTH FROM date)::INTEGER AS month,
    EXTRACT(WEEK FROM date)::INTEGER AS week,
    EXTRACT(ISODOW FROM date)::INTEGER AS day_of_week,
    CASE
        WHEN EXTRACT(ISODOW FROM date) IN (6, 7) THEN 1
        ELSE 0
    END AS is_weekend
FROM analytics.sales_rolling_features;



CREATE TABLE analytics.sales_product_features AS
SELECT
    s.*,
    c.dept_name,
    c.class_name,
    c.subclass_name,
    c.item_type,
    c.weight_volume,
    c.weight_netto,
    c.fatness
FROM analytics.sales_calendar_features s
LEFT JOIN analytics.catalog c
    ON s.item_id = c.item_id;


CREATE TABLE analytics.sales_store_features AS
SELECT
    s.*,
    st.division,
    st.format,
    st.city,
    st.area,
    sh.store_demand_avg_28d
FROM analytics.sales_product_features s
LEFT JOIN analytics.stores st
    ON s.store_id = st.store_id
LEFT JOIN analytics.store_history sh
    ON s.date = sh.date
   AND s.store_id = sh.store_id;



CREATE TABLE analytics.sales_promotion_features AS
SELECT
    s.*,
    CASE
        WHEN d.item_id IS NOT NULL THEN 1
        ELSE 0
    END AS promotion_flag,
    d.promo_type_code,
    d.time_promo,
    d.discount_pct
FROM analytics.sales_store_features s
LEFT JOIN (
    SELECT
        date,
        item_id,
        store_id,
        MAX(promo_type_code) AS promo_type_code,
        MAX(number_disc_day) AS time_promo,
        MAX(
            CASE
                WHEN sale_price_before_promo > 0
                THEN (
                    (sale_price_before_promo - sale_price_time_promo)
                    / sale_price_before_promo
                ) * 100
            END
        ) AS discount_pct
    FROM analytics.discounts_history
    GROUP BY
        date,
        item_id,
        store_id
) d
    ON s.date = d.date
   AND s.item_id = d.item_id
   AND s.store_id = d.store_id;


CREATE TABLE analytics.sales_markdown_features AS
SELECT
    s.*,
    CASE
        WHEN m.item_id IS NOT NULL THEN 1
        ELSE 0
    END AS markdown_flag,
    m.markdown_pct
FROM analytics.sales_promotion_features s
LEFT JOIN (
    SELECT
        date,
        item_id,
        store_id,
        MAX(
            CASE
                WHEN normal_price > 0
                THEN ((normal_price - price) / normal_price) * 100
            END
        ) AS markdown_pct
    FROM analytics.markdowns
    GROUP BY
        date,
        item_id,
        store_id
) m
    ON s.date = m.date
   AND s.item_id = m.item_id
   AND s.store_id = m.store_id;



CREATE TABLE analytics.sales_derived_features AS
SELECT
    *,
    
    CASE
        WHEN previous_price IS NOT NULL
             AND previous_price <> 0
        THEN ((price - previous_price) / previous_price) * 100
    END AS price_vs_previous_pct,

    CASE
        WHEN demand_avg_28d IS NOT NULL
             AND demand_avg_28d <> 0
        THEN demand_avg_7d / demand_avg_28d
    END AS demand_momentum_7d,

    CASE
        WHEN store_demand_avg_28d IS NOT NULL
             AND store_demand_avg_28d <> 0
        THEN quantity / store_demand_avg_28d
    END AS demand_vs_baseline,

    promotion_flag * COALESCE(discount_pct, 0)
        AS promo_discount_interaction,

    promotion_flag *
    COALESCE(
        CASE
            WHEN previous_price IS NOT NULL
                 AND previous_price <> 0
            THEN ((price - previous_price) / previous_price) * 100
        END,
        0
    ) AS promo_price_change_interaction

FROM analytics.sales_markdown_features;



SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT source_row_id) AS unique_source_rows,
    COUNT(DISTINCT (date, item_id, store_id)) AS unique_sales_grain,
    MIN(date) AS min_date,
    MAX(date) AS max_date
FROM analytics.sales_derived_features;


CREATE TABLE analytics.price_sense_features AS
SELECT
    source_row_id,
    date,
    item_id,
    store_id,
    quantity,
    price,
    sum_total,
    year,
    month,
    week,
    day_of_week,
    is_weekend,
    dept_name,
    class_name,
    subclass_name,
    item_type,
    weight_volume,
    weight_netto,
    fatness,
    division,
    format,
    city,
    area,
    store_demand_avg_28d,
    previous_price,
    promotion_flag,
    promo_type_code,
    time_promo,
    discount_pct,
    quantity_lag_1,
    quantity_lag_7,
    quantity_lag_14,
    quantity_lag_28,
    demand_avg_7d,
    demand_avg_28d,
    demand_volatility_28d,
    demand_trend_7d,
    price_vs_previous_pct,
    demand_momentum_7d,
    demand_vs_baseline,
    promo_discount_interaction,
    promo_price_change_interaction,
    markdown_flag,
    markdown_pct
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

