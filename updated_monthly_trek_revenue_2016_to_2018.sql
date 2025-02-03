WITH trek_order_lead_diff AS (
    SELECT
        orders.customer_id,
        CONCAT(first_name, ' ', last_name) AS full_name,
        state,
        orders.order_id,
        order_date,
		ROW_NUMBER() OVER(
            PARTITION BY orders.customer_id
            ORDER BY order_date
        ) AS trek_order_seq,
        LEAD(order_date) OVER(
            PARTITION BY orders.customer_id
            ORDER BY order_date
        ) - order_date AS days_between_orders
    FROM customers
    INNER JOIN orders ON orders.customer_id = customers.customer_id
    INNER JOIN order_items AS oi ON oi.order_id = orders.order_id
	INNER JOIN products ON products.product_id = oi.product_id
	INNER JOIN brands ON brands.brand_id = products.brand_id
    WHERE brand_name = 'Trek'
    	AND EXTRACT(YEAR FROM order_date) IN (2018, 2017, 2016) 
),

all_brand_order_lead_diff AS (
    SELECT
        orders.customer_id,
        orders.order_id,
        order_date,
		ROW_NUMBER() OVER(
            PARTITION BY orders.customer_id
            ORDER BY order_date
        ) AS non_trek_order_seq,
        LEAD(order_date) OVER(
            PARTITION BY orders.customer_id
            ORDER BY order_date
        ) - order_date AS days_between_non_trek_orders
    FROM customers
    INNER JOIN orders ON orders.customer_id = customers.customer_id
    INNER JOIN order_items AS oi ON oi.order_id = orders.order_id
	INNER JOIN products ON products.product_id = oi.product_id
	INNER JOIN brands ON brands.brand_id = products.brand_id
    WHERE brand_name != 'Trek'
    	AND EXTRACT(YEAR FROM order_date) IN (2018, 2017, 2016) 
),

customer_trek_rev AS (
	SELECT
		customer_id,
		ROUND(SUM((oi.list_price * quantity) - (oi.list_price * discount*quantity)),2) AS trek_revenue
	FROM order_items AS oi
	INNER JOIN orders ON orders.order_id = oi.order_id
	INNER JOIN products ON products.product_id = oi.product_id
	INNER JOIN brands ON brands.brand_id = products.brand_id
    WHERE brand_name = 'Trek'
    	AND EXTRACT(YEAR FROM order_date) IN (2018, 2017, 2016)
GROUP BY customer_id
),

customer_non_trek_rev AS (
	SELECT
		customer_id,
		ROUND(SUM((oi.list_price * quantity) - (oi.list_price * discount*quantity)),2) AS non_trek_revenue
	FROM order_items AS oi
	INNER JOIN orders ON orders.order_id = oi.order_id
	INNER JOIN products ON products.product_id = oi.product_id
	INNER JOIN brands ON brands.brand_id = products.brand_id
    WHERE brand_name != 'Trek'
    	AND EXTRACT(YEAR FROM order_date) IN (2018, 2017, 2016)
GROUP BY customer_id
),

trek_order_count AS (
    SELECT
        customer_id,
        COUNT(DISTINCT orders.order_id) AS total_trek_orders  -- ✅ Ensures each Trek order is counted once per customer
    FROM orders
    INNER JOIN order_items AS oi ON oi.order_id = orders.order_id
    INNER JOIN products ON products.product_id = oi.product_id
    INNER JOIN brands ON brands.brand_id = products.brand_id
    WHERE brand_name = 'Trek'
        AND EXTRACT(YEAR FROM order_date) IN (2018, 2017, 2016)
    GROUP BY customer_id
)

SELECT
    trek_order_lead_diff.customer_id,
    full_name,
    state,
    trek_order_count.total_trek_orders,
	trek_revenue,
	non_trek_revenue,
    ROUND(SUM(COALESCE(days_between_orders, 0)), 0) AS total_days_between_purchases,
    ROUND(AVG(NULLIF(days_between_orders, 0)), 0) AS avg_days_between_trek_purchases,
	ROUND(AVG(NULLIF(days_between_non_trek_orders, 0)), 0) AS avg_days_between_non_trek_purchases
FROM trek_order_lead_diff
LEFT JOIN customer_trek_rev ON customer_trek_rev.customer_id = trek_order_lead_diff.customer_id
LEFT JOIN customer_non_trek_rev ON customer_non_trek_rev.customer_id = trek_order_lead_diff.customer_id
LEFT JOIN all_brand_order_lead_diff
	ON all_brand_order_lead_diff.customer_id = trek_order_lead_diff.customer_id 
    AND all_brand_order_lead_diff.non_trek_order_seq = trek_order_lead_diff.trek_order_seq
LEFT JOIN trek_order_count ON trek_order_count.customer_id = trek_order_lead_diff.customer_id
WHERE days_between_orders IS NOT NULL  -- Ensures only valid differences are used
GROUP BY trek_order_lead_diff.customer_id, full_name, state, trek_order_count.total_trek_orders, trek_revenue, non_trek_revenue
ORDER BY total_trek_orders DESC;