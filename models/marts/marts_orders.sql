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
