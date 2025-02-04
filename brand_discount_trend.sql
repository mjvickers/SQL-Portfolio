WITH ds AS (
-- discount source
	SELECT
		DISTINCT
		brand_name,
		discount,
		COUNT(oi.product_id) AS unique_products,
		SUM(quantity) AS products_sold,
		ROUND(SUM((oi.list_price * quantity) - (oi.list_price * discount * quantity)), 2) AS revenue
	FROM order_items AS oi
	INNER JOIN orders ON orders.order_id = oi.order_id
	INNER JOIN products ON products.product_id = oi.product_id
	INNER JOIN brands ON brands.brand_id = products.brand_id
	WHERE EXTRACT('year' FROM order_date) IN (2018,2017,2016)
	GROUP BY brand_name, discount
)

SELECT
	brand_name,
	discount,
	unique_products,
	products_sold,
	revenue,
	ROUND((revenue / products_sold), 2) AS avg_rev_per_product
FROM ds
ORDER BY avg_rev_per_product DESC;