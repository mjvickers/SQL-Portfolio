WITH mbr AS (
-- monthly brand revenue
SELECT
	EXTRACT('month' FROM order_date) AS month,
	EXTRACT('year' FROM order_date) AS year,
	brand_id,
	brand_name,
	ROUND(SUM((list_price * quantity) - (list_price * discount * quantity)), 2) AS brand_revenue,
	SUM(quantity) AS products_sold
FROM otb_left
WHERE EXTRACT('year' FROM order_date) IN (2018,2017,2016)
GROUP BY EXTRACT('year' FROM order_date), EXTRACT('month' FROM order_date), brand_id, brand_name
ORDER BY year ASC, month ASC
),

ambr AS (
-- average monthly brand revenue [per specific month]
SELECT
	month,
	brand_id,
	ROUND(AVG(brand_revenue), 2) AS avg_spec_month_brand_rev
FROM mbr
GROUP BY month, brand_id
),

bam AS (
-- brand monthly average [not tied to a specific month]
    SELECT 
        brand_id,
        ROUND(AVG(brand_revenue), 2) AS avg_monthly_revenue
    FROM mbr
    GROUP BY brand_id
),

cmr AS (
-- company monthly revenue
	SELECT
		month,
		year,
		SUM(brand_revenue) AS company_revenue
	FROM mbr
	GROUP BY month, year
),

aps AS (
-- average products sold per month
	SELECT
		brand_id,
		ROUND(AVG(products_sold), 0) AS avg_prod_sold
	FROM mbr
	GROUP BY brand_id
),

amps AS (
-- average monthly products sold per brand [month specific]
	SELECT
		month,
		brand_id,
		ROUND(AVG(products_sold), 0) AS avg_spec_month_products_sold
	FROM mbr
	GROUP BY month, brand_id
)

SELECT
	mbr.month,
	mbr.year,
	CONCAT(
        CASE 
            WHEN mbr.month = 1 THEN 'January'
            WHEN mbr.month = 2 THEN 'February'
            WHEN mbr.month = 3 THEN 'March'
            WHEN mbr.month = 4 THEN 'April'
            WHEN mbr.month = 5 THEN 'May'
            WHEN mbr.month = 6 THEN 'June'
            WHEN mbr.month = 7 THEN 'July'
            WHEN mbr.month = 8 THEN 'August'
            WHEN mbr.month = 9 THEN 'September'
            WHEN mbr.month = 10 THEN 'October'
            WHEN mbr.month = 11 THEN 'November'
            WHEN mbr.month = 12 THEN 'December'
        END, ', ', mbr.year
    ) AS month_year,
	mbr.brand_name,
	products_sold,
	avg_spec_month_products_sold,
	avg_prod_sold,
	brand_revenue,
	avg_spec_month_brand_rev,
	avg_monthly_revenue,
	company_revenue,
	ROUND((brand_revenue / company_revenue), 4) AS monthly_brand_rev_share
FROM mbr
LEFT JOIN ambr ON ambr.month = mbr.month
	AND ambr.brand_id = mbr.brand_id
LEFT JOIN bam ON bam.brand_id = mbr.brand_id
LEFT JOIN cmr ON cmr.month = mbr.month
	AND cmr.year = mbr.year
LEFT JOIN aps ON aps.brand_id = mbr.brand_id
LEFT JOIN amps ON amps.brand_id = mbr.brand_id
	AND amps.month = mbr.month
ORDER BY year ASC, month ASC;