-- PriceSense | Pricing output checks
-- Extracted from your existing SQL working document.
-- Review the notes before running; this is an organization pass, not a verified clean-room migration.
-- NOTE: Read-only summary checks for recommendation and scenario outputs.

FROM analytics.pricing_recommendations
GROUP BY price_change_pct
ORDER BY price_change_pct;



SELECT
    price_change_pct,
    COUNT(*) AS row_count
FROM analytics.pricing_scenarios
GROUP BY price_change_pct
ORDER BY price_change_pct;


SELECT
    price_change_pct,
    COUNT(*) AS row_count,
    AVG(current_price) AS avg_current_price,
    AVG(simulated_price) AS avg_simulated_price
FROM analytics.pricing_recommendations
GROUP BY price_change_pct
ORDER BY price_change_pct;



SELECT
    r.price_change_pct,
    COUNT(*) AS row_count,
    SUM(r.simulated_revenue) AS recommendation_revenue,
    SUM(s.simulated_revenue) AS scenario_revenue
FROM analytics.pricing_recommendations r
JOIN analytics.pricing_scenarios s
    ON r.item_id = s.item_id
   AND r.store_id = s.store_id
   AND r.date = s.date
   AND r.price_change_pct = s.price_change_pct
GROUP BY r.price_change_pct

