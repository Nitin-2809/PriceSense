-- PriceSense | Pricing scenario simulation
-- Extracted from your existing SQL working document.
-- Review the notes before running; this is an organization pass, not a verified clean-room migration.
-- NOTE: The INSERT expands each recommendation across five price-change scenarios. Review whether scenarios are already populated before rerunning to avoid duplicate rows.

CREATE TABLE analytics.pricing_scenarios (
    item_id TEXT NOT NULL,
    store_id INTEGER NOT NULL,
    date DATE NOT NULL,
    current_demand DOUBLE PRECISION,
    current_price DOUBLE PRECISION,
    elasticity DOUBLE PRECISION,
    price_change_pct DOUBLE PRECISION NOT NULL,
    simulated_price DOUBLE PRECISION,
    simulated_demand DOUBLE PRECISION,
    simulated_revenue DOUBLE PRECISION
);



INSERT INTO analytics.pricing_scenarios (
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
)
SELECT
    p.item_id,
    p.store_id,
    p.date,
    p.current_demand,
    p.current_price,
    p.elasticity,
    s.price_change_pct,
    p.current_price * (1 + s.price_change_pct / 100.0) AS simulated_price,
    p.current_demand *
        POWER(
            (1 + s.price_change_pct / 100.0),
            p.elasticity
        ) AS simulated_demand,
    (
        p.current_price * (1 + s.price_change_pct / 100.0)
    ) *
    (
        p.current_demand *
        POWER(
            (1 + s.price_change_pct / 100.0),
            p.elasticity
        )
    ) AS simulated_revenue
FROM analytics.pricing_recommendations p
CROSS JOIN (
    VALUES
        (-10.0),
        (-5.0),
        (0.0),
        (5.0),
        (10.0)
) AS s(price_change_pct);





SELECT
    price_change_pct,
    COUNT(*) AS rows,
    ROUND(AVG(simulated_price)::numeric, 4) AS avg_price,
    ROUND(AVG(simulated_demand)::numeric, 4) AS avg_demand,
    ROUND(SUM(simulated_revenue)::numeric, 2) AS total_simulated_revenue,
    ROUND(AVG(simulated_revenue)::numeric, 4) AS avg_revenue
FROM analytics.pricing_scenarios
GROUP BY price_change_pct
ORDER BY price_change_pct;

