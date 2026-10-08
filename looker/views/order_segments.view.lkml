view: order_segments {
  derived_table: {
    sql:
      WITH base AS (
        SELECT
          order_id,
          customer_id,
          order_date
        FROM ${marts_orders.SQL_TABLE_NAME}
      ),

      windowed AS (
        SELECT
          order_id,
          customer_id,
          order_date,
          COUNT(*) OVER (
            PARTITION BY customer_id
            ORDER BY UNIX_DATE(order_date)
            RANGE BETWEEN 365 PRECEDING AND CURRENT ROW
          ) AS orders_in_window,
          ROW_NUMBER() OVER (
            PARTITION BY customer_id, order_date
            ORDER BY order_id
          ) AS rank_same_day,
          COUNT(*) OVER (
            PARTITION BY customer_id, order_date
          ) AS orders_same_day
        FROM base
      )

      SELECT
        order_id,
        orders_in_window
          - (orders_same_day - rank_same_day + 1) AS prior_orders
      FROM windowed ;;
  }

  dimension: order_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: segment {
    type: string
    group_label: "2.1 Customer segment"
    label: "Order segment"
    description: "New: no earlier order in 12 months. Returning: 1 to 3 earlier orders. VIP: 4 or more earlier orders. Segments before July 9, 2026 may be incomplete because less than 12 months of history is available."

    case: {
      when: {
        sql: ${prior_orders} = 0 ;;
        label: "New"
      }
      when: {
        sql: ${prior_orders} <= 3 ;;
        label: "Returning"
      }
      else: "VIP"
    }
  }

  dimension: prior_orders {
    type: number
    group_label: "2.1 Customer segment"
    label: "Earlier orders in 12 months"
    description: "Orders placed by the same customer during the 365 days before this order."
    sql: ${TABLE}.prior_orders ;;
  }
}
