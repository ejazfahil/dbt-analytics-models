# dbt Conventions 2023-09-08

## Layer rules
- `stg_*` — 1:1 with source, rename cols, cast types, no business logic
- `int_*` — join/aggregate, business logic, not exposed to BI
- `mart_*` — wide, denormalised, exposed in dashboards

## Naming
- Boolean cols: `is_`, `has_`
- Timestamps: `_at` suffix (UTC)
- Amounts: `_usd` suffix
