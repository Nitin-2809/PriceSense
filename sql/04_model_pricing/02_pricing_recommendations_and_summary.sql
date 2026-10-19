-- PriceSense | Pricing recommendation table definitions
-- Extracted from your existing SQL working document.
-- Review the notes before running; this is an organization pass, not a verified clean-room migration.
-- NOTE: Defines output tables; this extract does not include the code that generated and inserted the recommendation rows.

CREATE TABLE analytics.pricing_recommendations (
    item_id TEXT NOT NULL,
    store_id INTEGER NOT NULL,
    date DATE NOT NULL,
    current_demand DOUBLE PRECISION,
    current_price DOUBLE PRECISION,
    elasticity DOUBLE PRECISION,
    price_change_pct DOUBLE PRECISION,
    simulated_price DOUBLE PRECISION,
    simulated_demand DOUBLE PRECISION,
    simulated_revenue DOUBLE PRECISION,
    revenue_change_pct DOUBLE PRECISION
);

CREATE TABLE analytics.pricing_summary (
    price_change_pct DOUBLE PRECISION NOT NULL,
    item_store_pairs BIGINT NOT NULL,
    avg_current_price DOUBLE PRECISION,
    avg_simulated_price DOUBLE PRECISION,
    avg_current_demand DOUBLE PRECISION,
    avg_simulated_demand DOUBLE PRECISION,
    total_simulated_revenue DOUBLE PRECISION,
    avg_revenue_change_pct DOUBLE PRECISION
);

