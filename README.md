# dbt-analytics-models

> A layered dbt project for SaaS analytics — staging, intermediate, and mart models with source freshness, schema tests, and clear modelling conventions.

![dbt](https://img.shields.io/badge/dbt-analytics%20engineering-FF694B?logo=dbt&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-modelling-336791?logo=postgresql&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-warehouse-4169E1?logo=postgresql&logoColor=white)
![Status](https://img.shields.io/badge/status-core%20models-success)

---

## Overview / Aim

This is a **dbt** transformation project that turns raw SaaS order data into
trusted, dashboard-ready analytics tables following the canonical
**staging → intermediate → mart** layering. The aim is to demonstrate disciplined
**analytics engineering**: a single source of truth, tested staging models, reusable
intermediate business logic, and denormalised marts that BI tools can query
directly — all governed by explicit naming and layering conventions.

## Architecture / How It Works

```
 raw.orders ─┐
 raw.customers ┘  (source freshness: warn 12h / error 24h)
        │
        ▼
 ┌──────────────┐   stg_orders (view)
 │   STAGING    │   1:1 with source · rename · cast · filter null ids
 └──────┬───────┘   tested: unique/not_null/accepted_values
        ▼
 ┌──────────────┐   int_customer_ltv (table)
 │ INTERMEDIATE │   completed-orders LTV, AOV, tenure per customer
 └──────┬───────┘   (business logic, not exposed to BI)
        ▼
 ┌──────────────┐   mart_revenue (table, btree index on month)
 │     MART     │   monthly gross revenue, active customers, AOV
 └──────────────┘   (denormalised, dashboard-facing)
```

Materialisation strategy mirrors the layer's purpose: **views** for cheap,
always-fresh staging; **tables** for heavier intermediate/mart aggregations, with
a B-tree index on the marts time grain.

## Tech Stack & Tools

| Tool | Role |
|------|------|
| **dbt** | Transformation framework (`ref`, `source`, `config`, tests) |
| **SQL (PostgreSQL dialect)** | Model logic (`::` casts, `DATE_TRUNC`, `NULLIF`) |
| **dbt source freshness** | SLA on raw load recency (12h warn / 24h error) |
| **dbt schema tests** | `unique`, `not_null`, `accepted_values` |

## Project Structure

```
dbt-analytics-models/
├── models/
│   ├── staging/
│   │   ├── sources.yml      # raw.orders / raw.customers + freshness SLAs
│   │   ├── stg_orders.sql   # view: rename, cast, filter null order_id
│   │   └── stg_orders.yml   # column tests (unique/not_null/accepted_values)
│   ├── intermediate/
│   │   └── int_customer_ltv.sql   # table: LTV, AOV, tenure for completed orders
│   └── mart/
│       └── mart_revenue.sql       # table: monthly revenue/AOV/active customers
└── docs/
    └── conventions.md       # layer rules + naming standards
```

## Key Features / Highlights

- **Three-layer architecture** — staging (1:1, no business logic), intermediate
  (joins/aggregations), mart (wide, denormalised, BI-facing), exactly as
  documented in `docs/conventions.md`.
- **Source freshness SLAs** — `sources.yml` warns after 12h and errors after 24h
  on the raw load timestamp, catching stalled ingestion at the source.
- **Schema tests as contracts** — `unique`/`not_null` on keys and
  `accepted_values` on `status` keep bad data from propagating downstream.
- **Customer LTV model** — `int_customer_ltv` derives order count, lifetime value,
  first/last order dates, tenure, and average order value per customer.
- **Revenue mart** — monthly gross revenue, active customers, and AOV, with a
  B-tree index on the `month` grain for fast dashboard reads.
- **Naming discipline** — `is_/has_` booleans, `_at` UTC timestamps, `_usd`
  amounts, enforced by convention.

## Challenges

- **Layer boundaries** — keeping business logic out of staging and out of BI's
  reach until the mart, so models stay reusable and testable.
- **Idempotent, divide-by-zero-safe metrics** — `NULLIF(n_orders, 0)` guards AOV
  against customers with zero qualifying orders.
- **Freshness vs. cost** — views for staging avoid storage churn while tables
  materialise the expensive aggregations once per run.

## Future Work

- Add `dbt_project.yml` + `profiles.yml` for a runnable, CI-tested project.
- Incremental materialisation for `mart_revenue` on large fact volumes.
- Snapshots for slowly-changing customer dimensions.
- Expand tests with `dbt-utils` (relationships, recency, expression checks).
- Exposures + auto-generated dbt docs site.

## Getting Started / Usage

> The models are written for a standard dbt project. To run locally, place these
> under a dbt project with a Postgres `profiles.yml` target.

```bash
pip install dbt-postgres

dbt deps
dbt source freshness     # check raw load SLAs
dbt run                  # build staging → intermediate → mart
dbt test                 # run unique / not_null / accepted_values
```

## Conclusion

Demonstrates **analytics-engineering** fundamentals with dbt: layered modelling,
source-freshness SLAs, schema tests as data contracts, and clean revenue/LTV
metrics — the SQL-modelling discipline expected of a modern data team.
