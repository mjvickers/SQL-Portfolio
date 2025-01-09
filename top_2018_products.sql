-- Top Performing Products in 2018

-- CTE: calculating the total revenue for each product sold in 2018
-- *the aliased revenue field factors in the discount applied each time a product was purchased*
WITH product_revenue AS (
SELECT
	product_id,
	ROUND(SUM((quantity * list_price) - (quantity * list_price * discount)), 2) AS revenue
FROM order_items AS oi
INNER JOIN orders ON orders.order_id = oi.order_id
WHERE EXTRACT('year' FROM order_date) = 2018
GROUP BY product_id
),

-- CTE: querying the total amount of times each product was purchased in 2018
quantity_sold AS (
SELECT
	product_id,
	SUM(quantity) AS quantity_sold
FROM order_items AS oi
INNER JOIN orders ON orders.order_id = oi.order_id
WHERE EXTRACT('year' FROM order_date) = 2018
GROUP BY product_id
),

-- CTE: calculating the average revenue each time a product was sold
-- *discounts vary per order - not every particular product was purchased at the same price*
average_revenue_per_product AS (
SELECT
	pr.product_id,
	ROUND(revenue / quantity_sold, 2) AS avg_revenue
FROM product_revenue AS pr
INNER JOIN quantity_sold AS qs ON qs.product_id = pr.product_id
)

/* Main Query: queries product_id, product_name, quantiy_sold [from CTE], revenue [from CTE],
list_price [for comparison to avg_revenue], avg_revenue [from CTE], and rank [ranks products
based on avg_revenue*/
SELECT
	products.product_id,
	product_name,
	quantity_sold,
	revenue,
	products.list_price,
	avg_revenue,
	RANK() OVER(
		ORDER BY avg_revenue DESC)
FROM products
INNER JOIN product_revenue AS pr ON pr.product_id = products.product_id
INNER JOIN quantity_sold AS qs On qs.product_id = products.product_id
INNER JOIN average_revenue_per_product AS ar ON ar.product_id = products.product_id
ORDER BY revenue DESC;

 
	


 