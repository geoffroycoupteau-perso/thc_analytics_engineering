# LookML semantic layer

This LookML project was developed and validated in a private Looker development environment. It is ready to deploy after configuring the BigQuery connection in `thc_analytics.model.lkml`.

## Structure

- `thc_analytics.model.lkml`: connection and project includes.
- `explores/marts_orders.explore.lkml`: business-facing Explore and joins.
- `views/marts_orders.view.lkml`: order, customer, sales, basket and product fields.
- `views/order_segments.view.lkml`: New, Returning and VIP segmentation calculated over the previous 365 days.

## Data source

The public version points to:

```text
thc-challenge.sales_recruitment_marts.marts_orders
```

Change the connection name or table reference when deploying in another environment.

## Grain and joins

The base view has one row per order. Customer segmentation joins one-to-one on `order_id`. Products are stored as a nested array and are unnested with a one-to-many join.

## Conversational Analytics

Business fields have short labels and descriptions. Raw amounts, quantities, nested structures and technical keys are hidden where users do not need them. The Explore description states the data coverage and scope.

## Known limitation

The available data starts on July 9, 2025. Segments for orders placed before July 9, 2026 use less than 12 months of history, so some customers may appear as New.
