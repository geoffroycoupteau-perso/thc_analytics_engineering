explore: marts_orders {
  label: "Sales & Customer Analysis"
  view_label: "1. Orders"
  description: "Analyse orders, net sales, basket size, customer segments and products. Data covers July 9, 2025 to December 31, 2026. Currency is defined by the source data."

  join: order_segments {
    view_label: "2. Customer segmentation"
    type: left_outer
    relationship: one_to_one
    sql_on: ${marts_orders.order_id} = ${order_segments.order_id} ;;
  }

  join: marts_orders__products {
    view_label: "3. Products"
    relationship: one_to_many
    sql:
      LEFT JOIN UNNEST(${marts_orders.products})
        AS marts_orders__products ;;
  }
}
