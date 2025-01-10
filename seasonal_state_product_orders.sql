-- Seasonal Product Orders

-- CTE: assigns a season to each order based on the month of order_date
WITH seasonality AS (
SELECT
	order_id,
	order_date,
	CASE 
		WHEN EXTRACT('month' FROM order_date) IN (3,4,5) THEN 'Spring'
		WHEN EXTRACT('month' FROM order_date) IN (6,7,8) THEN 'Summer'
		WHEN EXTRACT('month' FROM order_date) IN (9,10,11) THEN 'Fall'
		WHEN EXTRACT('month' FROM order_date) IN (12,1,2) THEN 'Winter'
		ELSE 'season unknown'
	END AS season
FROM orders
)

/* Main Query: queries all product information including product id, name, list price,
discount, product revenue along with relevant order information such as order id, date,
and season [pulled/create in CTE above]*/
SELECT
	oi.product_id,
	product_name,
	oi.order_id,
	oi.quantity,
	oi.list_price,
	oi.discount,
	ROUND((oi.quantity * oi.list_price) - (oi.quantity * oi.list_price * oi.discount), 2) AS product_revenue,
	orders.order_date,
	season,
	state,
	city
FROM products
INNER JOIN order_items AS oi ON oi.product_id = products.product_id
INNER JOIN orders ON orders.order_id = oi.order_id
INNER JOIN seasonality ON seasonality.order_id = oi.order_id
INNER JOIN customers ON customers.customer_id = orders.customer_id
WHERE EXTRACT('year' FROM orders.order_date) = 2018
ORDER BY order_date ASC;

--Techniques: CTE, CASE, INNER JOIN, and date filtering