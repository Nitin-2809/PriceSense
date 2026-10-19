-- PriceSense | Model performance results
-- Extracted from your existing SQL working document.
-- Review the notes before running; this is an organization pass, not a verified clean-room migration.
-- NOTE: Contains hard-coded validation/test metrics. Keep aligned with actual model evaluation outputs.

CREATE TABLE analytics.model_performance (
    model TEXT NOT NULL,
    dataset TEXT NOT NULL,
    mae DOUBLE PRECISION NOT NULL,
    rmse DOUBLE PRECISION NOT NULL,
    r2 DOUBLE PRECISION NOT NULL
);



INSERT INTO analytics.model_performance (
    model,
    dataset,
    mae,
    rmse,
    r2
)
VALUES
    ('Ridge', 'Validation', 2.397499, 7.728365, 0.916595),
    ('HistGradientBoosting', 'Validation', 2.245066, 9.097360, 0.884429),
    ('XGBoost', 'Validation', 2.220282, 8.943184, 0.888313),
    ('Random Forest', 'Validation', 2.217598, 7.132158, 0.928967),
    ('Random Forest', 'Test', 2.145074, 9.701083, 0.911318);



SELECT
    model,
    dataset,
    mae,
    rmse,
    r2
FROM analytics.model_performance
ORDER BY
    CASE
        WHEN model = 'Random Forest' AND dataset = 'Test' THEN 1
        WHEN model = 'Random Forest' AND dataset = 'Validation' THEN 2
        ELSE 3
    END,
    model;

