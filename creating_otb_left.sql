CREATE VIEW otb_left AS (
SELECT 
    orders.order_id,
    orders.customer_id,
    orders.order_date,
    orders.store_id,
    orders.staff_id,
    oi.item_id,
    oi.product_id,
    oi.quantity,
    oi.list_price,
    oi.discount,
	((oi.list_price * quantity) - (oi.list_price * discount * quantity)) AS revenue,
    products.product_name,
    products.brand_id,
    brands.brand_name
FROM orders
LEFT JOIN order_items AS oi ON oi.order_id = orders.order_id
LEFT JOIN products ON products.product_id = oi.product_id
LEFT JOIN brands ON brands.brand_id = products.brand_id
);