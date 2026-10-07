{#
    Mart: orders with quantity (exercise 4).
    One row per order for 2025 and 2026, with qty_product (units in the order).
    The dates come from the variables orders_start_date and orders_end_date.
    Performance: clustered by customer_id. Partitioned by month on order_date
    when use_partitioning is true (it is false on the BigQuery sandbox, where
    partitions older than 60 days are deleted).
    Exercises 1 to 3 are answered from this table.
#}
{{
    config(
        partition_by={'field': 'order_date', 'data_type': 'date', 'granularity': 'month'} if var('use_partitioning') else none,
        cluster_by=['customer_id']
    )
}}

SELECT
    order_date,
    customer_id,
    order_id,
    net_sales,
    qty_product,
    products
FROM {{ ref('intermediate_orders') }}
WHERE order_date BETWEEN '{{ var("orders_start_date") }}' AND '{{ var("orders_end_date") }}'
