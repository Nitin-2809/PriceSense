# PriceSense — Demand Forecasting & Dynamic Pricing Decision Engine

PriceSense is an end-to-end retail analytics project that combines SQL-based data preparation, demand forecasting, price-elasticity analysis, pricing simulation, and Power BI reporting. The goal is to turn historical retail data into a structured workflow for understanding demand and evaluating data-driven pricing decisions.

The project follows the analytics process from raw source data through preparation and feature engineering to model outputs, pricing scenarios, and an interactive business dashboard. PostgreSQL is used for the database and analytical transformations, Python/Jupyter notebooks are used for model-related work, and Power BI is used to present the results.

> **Important interpretation note:** PriceSense produces model-based forecasts and simulated pricing outcomes. Simulated revenue uplift is an estimate under the model assumptions, not proof of realized business impact. The current pricing recommendation outputs cover **1 July 2024 to 26 September 2024**; they should not be interpreted as recommendations for the entire historical dataset.


---

## Contents

- [Project at a glance](#project-at-a-glance)
- [Business problem](#business-problem)
- [Project objectives](#project-objectives)
- [Dataset](#dataset)
- [Technology stack](#technology-stack)
- [End-to-end workflow](#end-to-end-workflow)
- [Database architecture](#database-architecture)
- [Feature engineering](#feature-engineering)
- [Demand forecasting](#demand-forecasting)
- [Price elasticity and pricing simulation](#price-elasticity-and-pricing-simulation)
- [Pricing recommendations](#pricing-recommendations)
- [Model results](#model-results)
- [Power BI dashboard](#power-bi-dashboard)
- [Repository structure](#repository-structure)
- [How to reproduce the project](#how-to-reproduce-the-project)
- [Data and repository considerations](#data-and-repository-considerations)
- [Limitations and responsible interpretation](#limitations-and-responsible-interpretation)
- [Future improvements](#future-improvements)
- [Author](#author)

---

## Project at a glance

| Item | Description |
|---|---|
| Project | PriceSense — Demand Forecasting & Dynamic Pricing Decision Engine |
| Domain | Retail analytics, demand forecasting, pricing analytics |
| Database | PostgreSQL |
| Analysis and modelling | Python, Pandas, Jupyter Notebook, scikit-learn |
| Business intelligence | Power BI, DAX |
| Main analytical grain | Date + item + store, where supported by the source data |
| Historical price data | 28 August 2022 – 26 September 2024 |
| Stores | 4 |
| Main forecasting model | Random Forest |
| Main outputs | Forecasts, model comparison/performance, price-elasticity analysis, pricing recommendations, pricing scenarios, Power BI dashboard |

## Business problem

Retail businesses need to understand how much demand they may receive and how pricing decisions could affect sales and revenue. Historical sales alone are not enough: demand may also vary with product, store, date, promotions, markdowns, and other factors. Pricing decisions therefore need to be evaluated in context rather than treated as isolated percentage changes.

PriceSense brings these tasks into one analytical workflow. It prepares retail data for analysis, engineers demand-related features, evaluates forecasting performance, uses price elasticity to simulate alternative prices, and presents the resulting information in a Power BI dashboard.

The project is a portfolio and decision-support exercise. It demonstrates an analytical approach; it does not claim that simulated pricing outcomes have been deployed or verified in a live retail environment.

## Project objectives

1. **Prepare and validate retail data** using a layered PostgreSQL workflow.
2. **Understand the data** through profiling, quality checks, and analytical queries.
3. **Build demand-related features** using sales history, calendar information, product and store attributes, prices, promotions, and markdowns where available.
4. **Forecast demand** and compare model performance using appropriate evaluation metrics.
5. **Analyse price elasticity** to estimate how demand could respond to a change in price.
6. **Simulate pricing alternatives** and compare their estimated demand and revenue.
7. **Generate pricing recommendations** from the modelled scenarios.
8. **Communicate results** through a multi-page Power BI dashboard.

---

## Dataset

The project uses the **Svizor Retail Sales Forecasting Data** dataset downloaded from Kaggle. The source files cover four stores and approximately 25 months of retail history.

The original files used in the project are:

- `sales.csv`
- `catalog.csv`
- `stores.csv`
- `price_history.csv`
- `discounts_history.csv`
- `markdowns.csv`
- `online.csv`
- `actual_matrix.csv`

The source data includes retail sales and quantity information, item/catalog attributes, store information, price history, discounts, markdowns, and online-related data. The files differ in size and grain, so they need to be joined and aggregated carefully rather than treated as if every row represented the same type of observation.

The main analytical grain used for demand modelling is **date + item ID + store ID**, where the source tables support that level of detail.

### Data scale and profiling

The `sales.csv` source contains approximately **7.43 million rows**. The wider source files range from small reference tables to multi-million-row history tables. Profiling also identified substantial missingness in some product attributes and promotion/discount fields. Missing values therefore need to be interpreted according to the meaning of each field rather than automatically replaced with zero.

The recorded price-history date range is **28 August 2022 to 26 September 2024**. Preserve this source coverage when reproducing the analysis; do not assume that every derived table or model output spans the entire period.

### Obtaining the data

The raw CSV files are not included in this repository because of their size and to avoid unnecessary duplication of the original dataset. Obtain the dataset from its original Kaggle source and place the files in a local data directory before running the relevant import and preparation steps.

---

## Technology stack

- **PostgreSQL** — relational database, schema organization, SQL transformations, profiling, analytical features, validation, and reporting tables.
- **SQL** — table creation, data preparation, joins, aggregations, feature construction, quality checks, and output validation.
- **Python** — modelling workflow and supporting data analysis.
- **Pandas** — data handling and analysis in notebooks.
- **Jupyter Notebook** — exploratory work, model comparison, and model-related analysis.
- **scikit-learn** — demand forecasting with a Random Forest model and evaluation using standard regression metrics.
- **Power BI** — interactive reporting and decision-support dashboard.
- **DAX** — measures, KPIs, period comparisons, and dashboard calculations.
- **Git and GitHub** — version control and project documentation.

---

## End-to-end workflow

```text
Kaggle retail data
        ↓
Raw CSV files
        ↓
PostgreSQL: raw schema
        ↓
Profiling and data-quality checks
        ↓
PostgreSQL: staging schema
        ↓
Cleaning, standardisation, and validation
        ↓
PostgreSQL: analytics schema
        ↓
Demand, calendar, product, store, price,
promotion, markdown, and rolling features
        ↓
Python / Jupyter model development
        ↓
Demand forecasts and model evaluation
        ↓
Price elasticity analysis
        ↓
Pricing scenario simulation
        ↓
Pricing recommendations and summary outputs
        ↓
Power BI semantic model, DAX measures, and dashboard
        ↓
Business interpretation and limitations
```

The database is layered to separate source data from prepared data and analytical outputs. The exact execution order of individual scripts should be confirmed against their dependencies before rerunning the workflow on a fresh database.

---

## Database architecture

The PostgreSQL database is named `pricesense`. The main schemas are `raw`, `staging`, and `analytics`; a default `public` schema is also present in PostgreSQL.

### 1. `raw` schema

The `raw` schema holds the imported source tables:

- `actual_matrix`
- `catalog`
- `discounts_history`
- `markdowns`
- `online`
- `price_history`
- `sales`
- `stores`

This layer preserves the source-oriented representation of the imported files. It is useful for tracing downstream calculations back to the original data.

### 2. `staging` schema

The `staging` schema contains corresponding tables for the eight source datasets. This layer is intended for prepared and validated data used in subsequent transformations.

The existence of tables with matching names in `raw` and `staging` does not, by itself, prove that their contents or structures differ in every respect. The SQL transformations and validation checks determine what was changed between layers.

### 3. `analytics` schema

The `analytics` schema contains source-like/reference tables, enriched tables, engineered features, model outputs, and pricing outputs. The current database inventory includes the following 28 tables.

**Source and reference data**
- `actual_matrix`
- `catalog`
- `discounts_history`
- `markdowns`
- `online`
- `price_history`
- `sales`
- `stores`
- `product_class_translation`
- `store_history`

**Demand and feature engineering**
- `daily_store_demand`
- `sales_calendar_features`
- `sales_demand_features`
- `sales_derived_features`
- `sales_markdown_features`
- `sales_price_features`
- `sales_product_features`
- `sales_promotion_features`
- `sales_rolling_features`
- `sales_store_features`
- `price_history_enriched`
- `price_sense_features`

**Model and pricing outputs**
- `model_comparison`
- `model_forecast`
- `model_performance`
- `pricing_recommendations`
- `pricing_scenarios`
- `pricing_summary`

This inventory reflects the database as inspected during project development. Table names alone do not define the full dependency order; consult the SQL scripts and notebook workflow before rebuilding the database.

---

## Feature engineering

Demand forecasting depends on more than a single sales quantity column. PriceSense constructs analytical tables to bring demand history together with relevant time, product, store, price, promotion, and markdown information.

The known feature-engineering areas include:

- **Demand features:** historical demand and related derived values.
- **Calendar features:** date-related attributes for time-aware analysis.
- **Rolling features:** rolling demand summaries that capture recent history.
- **Lag features:** prior demand values, including lag periods such as 1, 7, 14, and 28 days where applicable.
- **Price features:** price-history enrichment and price-related fields.
- **Promotion and markdown features:** fields describing promotional or markdown context where available.
- **Product features:** catalog and product-level attributes.
- **Store features:** store-level information.
- **Derived features:** combined or transformed variables prepared for modelling.

The project uses the date-item-store grain for core demand analysis where supported by the data. When building lag and rolling features, rows must be correctly ordered within the relevant item/store series; feature generation must not accidentally use future observations to predict the past. Missing values near the beginning of a series are expected for some lag windows and should be handled deliberately.

---

## Demand forecasting

The demand-forecasting component uses a **Random Forest regression model** to estimate demand from engineered historical features.

The modelling workflow includes:

1. Preparing the modelling dataset from the engineered features.
2. Splitting observations into training, validation, and test sets according to the notebook workflow.
3. Fitting and comparing model candidates.
4. Evaluating forecasts with regression metrics.
5. Saving or exposing forecast and model-performance results for downstream analysis.

### Evaluation metrics

- **MAE (Mean Absolute Error):** the average absolute difference between predicted and actual demand. Lower is better.
- **RMSE (Root Mean Squared Error):** penalises larger errors more heavily than MAE. Lower is better.
- **R² (Coefficient of Determination):** indicates how much of the variation in the target is explained by the model relative to a baseline. Higher is generally better, but it should be interpreted alongside error metrics and the evaluation setup.

The recorded metrics for the current Random Forest workflow are documented in the [Model results](#model-results) section. These scores describe performance on the evaluated data splits; they do not guarantee the same performance in a future deployment.

---

## Price elasticity and pricing simulation

PriceSense includes a price-elasticity component to estimate how demand may respond to a simulated price change.

In the simulation, demand is adjusted using the current demand estimate, the ratio between simulated and current price, and the estimated elasticity:

$$
Q_{\mathrm{sim}} = Q_{\mathrm{current}}
\left(\frac{P_{\mathrm{sim}}}{P_{\mathrm{current}}}\right)^{\varepsilon}
$$

Where:

- $Q_{\mathrm{sim}}$ is simulated demand.
- $Q_{\mathrm{current}}$ is the demand estimate used as the baseline.
- $P_{\mathrm{sim}}$ is the proposed simulated price.
- $P_{\mathrm{current}}$ is the current price.
- $\varepsilon$ is the price-elasticity estimate.

Simulated revenue is then calculated as:

$$
R_{\mathrm{sim}} = P_{\mathrm{sim}} \times Q_{\mathrm{sim}}
$$

This approach enables comparison of candidate prices under the elasticity assumptions. The output is a scenario estimate, not a causal experiment. Its usefulness depends on the quality and stability of the elasticity estimates, the suitability of the baseline demand, and the validity of the assumptions for the product/store/time being evaluated.

---

## Pricing recommendations

The pricing component evaluates alternative prices and produces recommendation and summary outputs. The current database includes:

- `pricing_recommendations` — recommendation-level outputs.
- `pricing_scenarios` — alternative simulated price scenarios.
- `pricing_summary` — summary outputs used for analysis and reporting.

The recorded recommendation output includes price increases and price decreases of **10%**. The current recommendation table contains recommendations for the period **1 July 2024 to 26 September 2024**. The recorded counts are:

| Recommendation action | Rows |
|---|---:|
| Price decrease (-10%) | 2,988 |
| Price increase (+10%) | 2,841 |

These are counts in the recorded output table, not counts of unique products unless the table grain establishes that equivalence. The recorded `pricing_recommendations` output did not include a “No Change” recommendation category.

The scenario table has approximately **29,145 rows**, with five scenarios per recommendation combination in the recorded workflow. Verify the exact keys and scenario definitions in SQL before interpreting these as independent recommendations.

---

## Model results

The recorded Random Forest evaluation metrics are:

| Evaluation split | MAE | RMSE | R² |
|---|---:|---:|---:|
| Test | 2.145074 | 9.701083 | 0.911318 |
| Validation | 2.217598 | 7.132158 | 0.928967 |

These values are included to document the current recorded run. For a formal model comparison, the train/validation/test split strategy, target definition, feature set, and metric calculation should be kept consistent across models. The metrics should not be compared directly with scores from a different split or target definition without accounting for those differences.

The database also contains `model_comparison`, `model_forecast`, and `model_performance` outputs to support inspection of candidate models, forecast values, and evaluation results.

---

## Power BI dashboard

The Power BI report presents the analysis through four pages. It is designed to let a viewer move from an overall business summary to demand behaviour, pricing analysis, and model/recommendation detail.

### 1. Executive Overview

Provides a high-level view of business and pricing indicators. The planned six KPI cards are:

- Total Revenue
- Net Units Sold
- Active Products
- Average Selling Price
- Recommended Price Change %
- Recommended Revenue Change %

The page also includes trend indicators and supporting visuals. Historical sales KPIs and model-generated recommendation KPIs have different coverage: recommendation measures should be interpreted within the available July–September 2024 recommendation period.

### 2. Demand Analysis

Explores demand patterns using sales history and engineered demand features. It is intended to help users examine how demand varies over time and across the available product/store dimensions.

### 3. Pricing & Elasticity

Focuses on price history, price changes, and estimated price elasticity. It helps communicate how simulated demand and revenue can change under alternative price assumptions.

### 4. Pricing Recommendations & Model Performance

Brings together the model results and pricing outputs, including recommendation actions, simulated scenarios, and forecast/model-performance information.

### Dashboard design

The dashboard uses a pale blue-white background with navy and teal accents, white visual cards, and restrained gridlines. The design prioritises readability and business interpretation over decorative visuals. KPI trend colours and indicators are used to distinguish positive, negative, and neutral/undefined changes.

---

## Repository structure

The repository is intended to keep the project understandable without committing large raw datasets or database exports.

```text
PriceSense/
├── README.md
├── requirements.txt
│
├── sql/
│   ├── 01_raw/
│   ├── 02_staging/
│   ├── 03_analytics/
│   ├── 04_model_pricing/
│   ├── 05_powerbi_views/
│   ├── 06_reference_translation/
│   └── 07_validation/
│
├── notebooks/
│   ├── 01_Data_Profiling.ipynb
│   └── 02_Model_Comparison.ipynb
│
├── powerbi/
│   ├── powerbi link/
│   │   └── Power BI report link
│   └── screenshots/
│       ├── 01 Executive Overview.png
│       ├── 02 Demand Analysis.png
│       ├── 03 Pricing & Elasticity.png
│       └── 04 Pricing Recommendations & Model Performance.png
│
└── report/
    └── PriceSense_report.pdf
```

The SQL directories group scripts by purpose. The exact scripts should be reviewed for completeness, dependency order, and safe re-execution before treating the repository as a one-click rebuild. Notebook and report folders may contain only the artifacts that are actually available and ready to publish.

---

## How to reproduce the project

The workflow below describes the intended process. The exact SQL execution sequence and Python paths must be confirmed from the checked-in scripts and notebooks before running them on a new machine.

1. **Obtain the source dataset.** Download the original CSV files from the dataset's Kaggle source and review its terms of use.
2. **Set up PostgreSQL.** Create a database named `pricesense` and the required schemas (`raw`, `staging`, and `analytics`) if they do not already exist.
3. **Configure local file paths.** Update any `COPY`, import, or notebook paths to match the local machine. Do not commit machine-specific paths or credentials.
4. **Load raw tables.** Import the source CSV files into the `raw` schema using the appropriate column definitions and data types.
5. **Prepare staging tables.** Run the staging transformations and validate row counts, nulls, duplicates, date ranges, and key fields.
6. **Build analytical features.** Execute the required analytics transformations in dependency order and validate their output grain and row counts.
7. **Run the modelling workflow.** Open the relevant notebooks, configure input/output paths, run the model comparison and forecasting workflow, and confirm the recorded metrics.
8. **Build pricing outputs.** Run the pricing and scenario workflow only after its required feature, forecast, and elasticity inputs are available.
9. **Connect Power BI.** Configure the database connection, verify relationships and date handling, and refresh the report. Confirm that visuals reflect the expected date coverage.
10. **Validate the final results.** Compare dashboard figures with the database outputs and note the date range, assumptions, and limitations when interpreting recommendations.

**Do not run every SQL file blindly in an existing database.** Some scripts may create or replace tables/views, depend on earlier outputs, or use local file paths. Review the script and its dependencies before execution.

---

## Data and repository considerations

To keep the repository useful and manageable:

- Do not commit the original multi-million-row CSV files unless there is a clear, permitted reason to distribute them.
- Do not commit large generated forecast exports or full database dumps by default.
- Include SQL scripts, documentation, notebooks, and dashboard/report artifacts that are appropriate to share.
- Where helpful, include small, non-sensitive sample outputs or aggregate summaries instead of full exports.
- Keep credentials, passwords, local connection strings, and machine-specific paths out of version control.
- Use `.gitignore` for local datasets, temporary files, caches, and large generated outputs.
- Add clear instructions for obtaining the source data and configuring paths locally.

The database itself is not stored in GitHub as live PostgreSQL tables. The repository stores the scripts and documentation needed to explain and, after validation, reproduce the workflow.

---

## Limitations and responsible interpretation

- **Forecasts are estimates.** Model metrics describe performance on the evaluated splits and may not generalise to future periods or changing retail conditions.
- **Pricing scenarios are simulated.** Simulated revenue uplift is not observed revenue uplift and should not be presented as a realised business result.
- **Elasticity assumptions matter.** Demand responses may vary by product, store, time, promotion, availability, and market conditions.
- **Recommendation coverage is limited.** The recorded pricing recommendations cover 1 July 2024 through 26 September 2024, not the entire historical dataset.
- **Source data contains missing values.** Missing product attributes and promotion/discount fields can affect analysis; handling decisions should be documented.
- **Data grain must be respected.** Joining tables with different grains without checking keys can duplicate records and distort sales, demand, or revenue calculations.
- **Historical associations are not automatically causal.** A relationship between price and demand in observational data does not, by itself, prove that a price change caused a demand change.
- **Reproducibility requires environment details.** Dataset access, PostgreSQL setup, Python package versions, file paths, and execution order should be documented and tested.

---

## Future improvements

Potential next steps include:

- Verify and document a clean, dependency-aware SQL execution order for a fresh database.
- Add a requirements file or environment specification for the Python workflow.
- Add reproducible backtesting and compare forecasting approaches using a consistent evaluation design.
- Validate elasticity estimates and test recommendation sensitivity to different assumptions.
- Add historical pricing backtesting before making stronger claims about business impact.
- Improve automated data-quality checks and document expected row counts and grains.
- Add small, shareable sample outputs or screenshots to make the repository easier to review.
- Document dashboard measures, filters, and relationships so the report can be maintained more easily.

These are potential improvements, not claims that they have already been completed.

---

## Author

**Nitin B. Mirajkar**

PriceSense was developed as a personal portfolio project to practise and demonstrate SQL-based analytics, demand forecasting, price-elasticity analysis, pricing simulation, and Power BI reporting.

