{#
    Mart: orders with their segment (exercise 6).
    One row per order for 2026, with order_segmentation (New, Returning, VIP).
    The segment is computed in intermediate_orders_segmented on ALL orders;
    here we only keep the 2026 rows (variables segmented_start_date and segmented_end_date).
    Performance: clustered by customer_id and order_segmentation. Partitioned
    by month on order_date when use_partitioning is true.
#}
{{
    config(
        partition_by={'field': 'order_date', 'data_type': 'date', 'granularity': 'month'} if var('use_partitioning') else none,
        cluster_by=['customer_id', 'order_segmentation']
    )
}}

SELECT
    orders.order_date,
    orders.customer_id,
    orders.order_id,
    orders.net_sales,
    segments.order_segmentation
FROM {{ ref('intermediate_orders') }} AS orders
INNER JOIN {{ ref('intermediate_orders_segmented') }} AS segments
    ON orders.order_id = segments.order_id
WHERE orders.order_date BETWEEN '{{ var("segmented_start_date") }}' AND '{{ var("segmented_end_date") }}'
