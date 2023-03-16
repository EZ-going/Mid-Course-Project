USE mavenfuzzyfactory;

WITH

website_session AS
(
SELECT
	MONTH(created_at) AS month,
    MIN(DATE(created_at)) OVER(PARTITION BY MONTH(created_at)) AS month_start,
    utm_campaign,
    website_session_id
FROM website_sessions a
WHERE DATE(a.created_at) < '2012-11-27'
AND utm_source = 'gsearch'
AND utm_campaign IN ('brand','nonbrand')
)
SELECT
	month,
    brand_sessions,
    brand_orders,
    brand_orders/brand_sessions AS brand_conv_rate,
    nonbrand_sessions,
    nonbrand_orders,
    nonbrand_orders/nonbrand_sessions AS nonbrand_conv_rate
FROM
(
	SELECT
		month_start AS month,
		COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN a.website_session_id ELSE NULL END) AS brand_sessions,
		COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END) AS brand_orders,
		COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN a.website_session_id ELSE NULL END) AS nonbrand_sessions,
		COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN order_id ELSE NULL END) AS nonbrand_orders
	FROM website_session a
	LEFT JOIN orders b ON a.website_session_id = b.website_session_id
	GROUP BY 1
) a
ORDER BY 1