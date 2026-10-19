-- PriceSense | Model comparison results
-- Extracted from your existing SQL working document.
-- Review the notes before running; this is an organization pass, not a verified clean-room migration.
-- NOTE: Contains hard-coded experiment results from your working document. Keep values aligned with the actual notebook results.

CREATE TABLE analytics.model_comparison (
    model TEXT NOT NULL,
    features TEXT NOT NULL,
    training_rows BIGINT NOT NULL,
    validation_mae DOUBLE PRECISION NOT NULL,
    validation_rmse DOUBLE PRECISION NOT NULL,
    validation_r2 DOUBLE PRECISION NOT NULL
);


INSERT INTO analytics.model_comparison (
    model,
    features,
    training_rows,
    validation_mae,
    validation_rmse,
    validation_r2
)
VALUES
    (
        'Ridge',
        '30 numeric + 2,084 one-hot',
        3807606,
        2.397499,
        7.728365,
        0.916595
    ),
    (
        'HistGradientBoosting',
        '30 numeric',
        500000,
        2.245066,
        9.097360,
        0.884429
    ),
    (
        'XGBoost',
        '30 numeric',
        500000,
        2.220282,
        8.943184,
        0.888313
    ),
    (
        'Random Forest',
        '30 numeric',
        3807606,
        2.217598,
        7.132158,
        0.928967
    );

