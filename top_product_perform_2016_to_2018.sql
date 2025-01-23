SELECT
	oi.product_id,
	product_name,
	brand_name,
	ROUND(SUM((oi.list_price * oi.quantity) - (oi.list_price * oi.discount * oi.quantity)), 2) AS prod_revenue,
	SUM(oi.quantity) AS total_quantity_sold,
	RANK() OVER(
		ORDER BY SUM(oi.quantity) DESC) AS total_quantity_sold_rank,
	oi.list_price,
	RANK() OVER(
		ORDER BY oi.list_price DESC) AS list_price_rank,
	ROUND(AVG(oi.discount), 5) AS avg_discount,
	RANK() OVER(
		ORDER BY ROUND(AVG(oi.discount), 5) DESC) AS avg_discount_rank
FROM order_items AS oi
INNER JOIN orders ON orders.order_id = oi.order_id
INNER JOIN products ON products.product_id = oi.product_id
INNER JOIN brands ON brands.brand_id = products.brand_id
WHERE EXTRACT('year' FROM order_date) IN (2018,2017,2016)
GROUP BY oi.product_id, product_name, brand_name, oi.list_price
ORDER BY prod_revenue DESC;
	