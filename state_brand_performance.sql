WITH sccr AS (
-- state customer count and revenue
	SELECT
		state,
		COUNT(DISTINCT customer_id) AS number_of_customers,
		ROUND(SUM(revenue), 2) AS state_revenue,
		COUNT(DISTINCT order_id) AS total_orders
	FROM ctb_left
	WHERE EXTRACT('year' FROM order_date) IN (2018,2017,2016)
	GROUP BY state
),

pbor AS (
-- popular brand order rank
	SELECT
		state,
		brand_id,
		brand_name,
		COUNT(DISTINCT order_id) AS orders_per_brand,
		RANK() OVER(
			PARTITION BY state
			ORDER BY COUNT(DISTINCT order_id) DESC
		) AS total_order_rank
	FROM ctb_left
	WHERE EXTRACT('year' FROM order_date) IN (2018,2017,2016)
	GROUP BY state, brand_id, brand_name, brand_id
),

pbrr AS (
-- popular brand revenue rank
	SELECT
		state,
		brand_id,
		brand_name,
		ROUND(SUM(revenue), 2) AS revenue_per_brand,
		RANK() OVER(
			PARTITION BY state
			ORDER BY SUM(revenue) DESC
		) AS revenue_rank
	FROM ctb_left
	WHERE EXTRACT('year' FROM order_date) IN (2018,2017,2016)
	GROUP BY state, brand_id, brand_name, brand_id
),

rc AS (
-- recurring customers
	SELECT
		state,
		COUNT(DISTINCT customer_id) AS recurring_customers
	FROM ctb_left
	WHERE 
		customer_id IN (
			SELECT
				customer_id
			FROM ctb_left
			WHERE EXTRACT('year' FROM order_date) IN (2018,2017,2016)
			GROUP BY customer_id
			HAVING COUNT(order_id) > 1)
		AND EXTRACT('year' FROM order_date) IN (2018,2017,2016)
	GROUP BY state
)

SELECT
	sccr.state,
	number_of_customers,
	recurring_customers,
	ROUND((recurring_customers::numeric / number_of_customers), 2) AS recurring_customer_percentage,
	state_revenue,
	total_orders,
	CONCAT(pbor.brand_name, ' (', pbor.orders_per_brand, ' orders)') AS most_popular_brand,
	CONCAT(pbrr.brand_name, ' ($', pbrr.revenue_per_brand, ')') AS highest_revenue_brand
FROM sccr
INNER JOIN
	(SELECT
		state,
		brand_name,
		orders_per_brand
	FROM pbor
	WHERE total_order_rank = 1) AS pbor ON pbor.state = sccr.state
INNER JOIN 
	(SELECT
		state,
		brand_name,
		revenue_per_brand
	FROM pbrr
	WHERE revenue_rank = 1) AS pbrr ON pbrr.state = sccr.state
INNER JOIN rc ON rc.state = sccr.state;