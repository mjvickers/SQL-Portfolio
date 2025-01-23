WITH uniq_brand_products AS (
SELECT
	brands.brand_id,
	COUNT(*) AS uniq_product_count
FROM products
INNER JOIN brands ON brands.brand_id = products.brand_id
GROUP BY brands.brand_id
)

SELECT
	brands.brand_id,
	brand_name,
	ROUND(AVG(products.list_price), 2) AS avg_list_price,
	uniq_product_count,
	SUM(oi.quantity) AS products_sold,
	ROUND(SUM((oi.list_price * oi.quantity) - (oi.list_price * oi.discount * oi.quantity)), 2) AS brand_revenue
FROM brands
INNER JOIN products ON products.brand_id = brands.brand_id
INNER JOIN order_items AS oi on oi.product_id = products.product_id
INNER JOIN orders ON orders.order_id = oi.order_id
INNER JOIN uniq_brand_products ON uniq_brand_products.brand_id = brands.brand_id
WHERE EXTRACT('year' FROM order_date) IN (2018,2017,2016)
GROUP BY brands.brand_id, brand_name, uniq_product_count
ORDER BY brand_revenue DESC;