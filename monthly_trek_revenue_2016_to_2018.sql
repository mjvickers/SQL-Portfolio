WITH company_revenue AS (
	SELECT
		EXTRACT('year' FROM order_date) AS year,
		EXTRACT('month' FROM order_date) AS month,
		ROUND(SUM((oi.list_price * oi.quantity) - (oi.list_price * oi.discount * oi.quantity)), 2) AS revenue
	FROM orders
	INNER JOIN order_items AS oi ON oi.order_id = orders.order_id
	INNER JOIN products ON products.product_id = oi.product_id
	INNER JOIN brands ON brands.brand_id = products.brand_id
	WHERE EXTRACT('year' FROM order_date) IN (2018,2017,2016)
	GROUP BY EXTRACT('year' FROM order_date), EXTRACT('month' FROM order_date)
	ORDER BY year ASC
)

SELECT
	cr.year,
	cr.month,
	ROUND(SUM(
		CASE WHEN brand_name = 'Trek'
			THEN (oi.list_price * oi.quantity) - (oi.list_price * oi.discount * oi.quantity)
			ELSE 0
			END
	), 2) AS trek_revenue,
	cr.revenue AS company_revenue,
	ROUND(SUM(
		CASE WHEN brand_name = 'Trek'
			THEN (oi.list_price * oi.quantity) - (oi.list_price * oi.discount * oi.quantity)
			ELSE 0
			END
	) / cr.revenue, 4) AS trek_rev_share
FROM company_revenue AS cr
LEFT JOIN orders ON EXTRACT('year' FROM order_date) = cr.year AND EXTRACT('month' FROM order_date) = cr.month
LEFT JOIN order_items AS oi ON oi.order_id = orders.order_id
LEFT JOIN products ON products.product_id = oi.product_id
LEFT JOIN brands ON brands.brand_id = products.brand_id
WHERE brand_name = 'Trek' AND EXTRACT('year' FROM order_date) IN (2018,2017,2016)
GROUP BY cr.year, cr.month, cr.revenue
ORDER BY cr.year ASC, cr.month ASC;
	