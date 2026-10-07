# THC Analytics: dbt + BigQuery

dbt project for the Astrafy take-home challenge (Part 1). It turns two raw files (orders and sales lines) into one table with one row per order, the quantity of products, and the customer segment (New, Returning, VIP).

## Project layout

```
raw files (BigQuery)
  orders_recrutement, sales_recrutement
        |
        v
staging        staging_orders, staging_sales            (views)
        |
        v
intermediate   intermediate_orders                      (view)
               intermediate_orders_segmented            (view)
        |
        v
marts          marts_orders                             (table, exercise 4)
               marts_orders_segmented                   (table, exercise 6)
```

| Layer | What it does |
|---|---|
| staging | Renames columns, casts types. No business logic. |
| intermediate | Adds quantity per order and the segment of each order. |
| marts | Final tables, one per exercise. One row per order. |

Each layer is built in its own dataset: `<DBT_DATASET>_staging`, `_intermediate`, `_marts`.

### Marts

Each mart matches one exercise: `marts_orders` (exercise 4) and `marts_orders_segmented` (exercise 6). Exercises 1 to 3 are answered from `marts_orders`.

## Models

- `staging_orders`: one row per order.
- `staging_sales`: one row per product in an order.
- `intermediate_orders`: one row per order with `qty_product` and the list of products.
- `intermediate_orders_segmented`: segment of each order. It reads **all** orders, because the 12 months before an order are needed.
- `marts_orders`: exercise 4. Orders of 2025 and 2026 with `qty_product` and the list of `products`.
- `marts_orders_segmented`: exercise 6. Orders of 2026 with `order_segmentation`.

## Segmentation rules

For each order, we count the orders the same customer placed in the 12 months before it.

| Orders before | Segment |
|---|---|
| 0 | New |
| 1 to 3 | Returning |
| 4 or more | VIP |

How it works:
- One window function per customer (`COUNT(*) OVER ... RANGE BETWEEN 365 PRECEDING AND CURRENT ROW`). No self-join, so it scales.
- If a customer places several orders on the same day, they are ordered by `order_id`. The second one counts the first as a previous order.
- The thresholds and the number of days are variables (`segment_lookback_days`, `segment_returning_max_prior_orders`). The labels live in the macro `segment_label`.

## Setup

1. Create a virtual environment (Python 3.10 or newer).

```bash
python3.11 -m venv .venv
source .venv/bin/activate
pip install dbt-bigquery
```

2. Set the variables (see `.env.example`).

```bash
export DBT_PROJECT="your-gcp-project"
export DBT_DATASET="sales_recruitment"
export DBT_LOCATION="EU"
gcloud auth application-default login
```

For a service account, also set `DBT_AUTH_METHOD=service-account` and `DBT_KEYFILE=/path/to/key.json`. Keep the key outside the repo.

3. Load the two files into the dataset `thc_source` as `orders_recrutement` and `sales_recrutement`. Use the variable `source_schema` to change the dataset.

4. Run.

```bash
dbt deps
dbt build
```

## Variables (`dbt_project.yml`)

| Variable | Default | Use |
|---|---|---|
| `source_schema` | `thc_source` | Dataset of the raw tables |
| `orders_start_date` / `orders_end_date` | 2025-01-01 / 2026-12-31 | Orders in `marts_orders` |
| `segmented_start_date` / `segmented_end_date` | 2026-01-01 / 2026-12-31 | Orders in `marts_orders_segmented` |
| `segment_lookback_days` | 365 | Look-back window |
| `segment_returning_max_prior_orders` | 3 | Last number of previous orders that is still Returning |
| `use_partitioning` | `false` | Partition the mart by month (see below) |

## Data tests

- Generic tests: `unique`, `not_null`, `accepted_values`, `relationships`, and `dbt_utils.accepted_range` on keys, dates, amounts, quantities and segments.
- Singular test `assert_order_net_sales_matches_lines`: the `net_sales` of an order must equal the sum of its sales lines.
- Column and model descriptions are pushed to BigQuery (`persist_docs`).

## BigQuery cost and performance

The marts are built for a large volume:
- Clustered by `customer_id` (and `order_segmentation` for the segmented table).
- Partitioned by month on `order_date` when `use_partitioning` is `true`. Queries that filter on a date then read only the needed partitions.
- The segment uses a window function, not a join of the table with itself.

At billions of rows, the next step would be an incremental model. For an order, only the previous 12 months of the same customer are needed, so each run could rebuild only the recent days.

## Exercises

The queries for exercises 1 to 3 are in `analyses/` (run `dbt compile` to get the SQL with the table name filled in). Exercise 4 is the table `marts_orders` (orders of 2025 and 2026, with `qty_product` and `products`). Exercises 5 and 6 are the table `marts_orders_segmented` (orders of 2026, with `order_segmentation`).

## Known data issues

- **Orphan order**: order 5361303 (2026-12-31) is in sales but not in orders. The `relationships` test warns on 1 row and fails above 5.
- **Short history**: the data starts on 2025-07-09. For orders before 2026-07-09, the 12 months before the order are not fully in the data, so some customers show as New when they are not. The column `is_lookback_complete` in `intermediate_orders_segmented` is `false` for these orders.
- **Same-day orders**: handled by `order_id`, as explained above.
- **BigQuery sandbox**: partitioned tables lose rows older than 60 days (we saw this on the marts). That is why `use_partitioning` is `false`. Set it to `true` on a billed project.
