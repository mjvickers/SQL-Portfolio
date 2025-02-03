SELECT
	state,
	ROUND(AVG((list_price * quantity) - (list_price * discount * quantity)), 2) AS avg_order_rev
FROM customers
INNER JOIN orders ON orders.customer_id = customers.customer_id
INNER JOIN order_items AS oi ON oi.order_id = orders.order_id
WHERE EXTRACT('year' FROM order_date) IN (2018,2017,2016)
GROUP BY state;