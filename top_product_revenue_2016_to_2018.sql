SELECT
	oi.product_id,
	product_name,
	ROUND(SUM((oi.list_price * oi.quantity) - (oi.list_price * oi.discount * oi.quantity)), 2) AS prod_revenue
FROM order_items AS oi
INNER JOIN orders ON orders.order_id = oi.order_id
INNER JOIN products ON products.product_id = oi.product_id
WHERE EXTRACT('year' FROM order_date) IN(2018,2017,2016)
GROUP BY oi.product_id, product_name
ORDER BY prod_revenue DESC;