
-- orders over that generate over $1000 in revenue
-- query customer name, order_id, and revenue [alias]

WITH order_revenue AS (
SELECT
	oi.order_id,
	ROUND(SUM((quantity * list_price) - (quantity * list_price * discount)), 2) AS revenue
FROM order_items AS oi
INNER JOIN orders ON orders.order_id = oi.order_id
GROUP BY oi.order_id
)

SELECT
	CONCAT(first_name, ' ', last_name) AS full_name,
	order_date,
	order_revenue.order_id,
	revenue
FROM customers
INNER JOIN orders ON orders.customer_id = customers.customer_id
INNER JOIN order_revenue ON order_revenue.order_id = orders.order_id
WHERE revenue > 1000
ORDER BY revenue DESC;

--techniques: cte, aggregate function [SUM], INNER JOIN [matches only], CONCAT [combine strings]

 
	


 