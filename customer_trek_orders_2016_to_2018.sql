SELECT
	customers.customer_id,
	CONCAT(first_name ,' ' ,last_name) AS full_name,
	state,
	COUNT(oi.order_id) AS total_trek_orders,
	ROUND(SUM((list_price * quantity) - (list_price * discount*quantity)),2) AS trek_revenue
FROM customers
INNER JOIN orders ON orders.customer_id = customers.customer_id
INNER JOIN order_items AS oi ON oi.order_id = orders.order_id
WHERE oi.order_id IN (
	SELECT
		order_id
	FROM order_items AS oi
	INNER JOIN products ON products.product_id = oi.product_id
	INNER JOIN brands ON brands.brand_id = products.brand_id
	WHERE brand_name = 'Trek')
	AND EXTRACT('year' FROM order_date) IN (2018,2017,2016)
GROUP BY customers.customer_id, full_name, state
ORDER BY total_trek_orders DESC;