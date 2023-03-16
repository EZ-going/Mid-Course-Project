USE mavenfuzzyfactory;

WITH

website_session AS
(
SELECT
	MONTH(created_at) AS month,
    MIN(DATE(created_at)) OVER(PARTITION BY MONTH(created_at)) AS month_start,
    utm_source,
    website_session_id
FROM website_sessions a
WHERE DATE(a.created_at) < '2012-11-27'
)

SELECT
	month,
    gsearch_sessions,
    gsearch_orders,
    gsearch_orders/gsearch_sessions AS gsearch_conv_rate,
    bsearch_sessions,
    bsearch_orders,
    bsearch_orders/bsearch_sessions AS bsearch_conv_rate
FROM
(
	SELECT
		month_start AS month,
		COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN a.website_session_id ELSE NULL END) AS gsearch_sessions,
		COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN order_id ELSE NULL END) AS gsearch_orders,
		COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN a.website_session_id ELSE NULL END) AS bsearch_sessions,
		COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN order_id ELSE NULL END) AS bsearch_orders
	FROM website_session a
	LEFT JOIN orders b ON a.website_session_id = b.website_session_id
	GROUP BY 1
) a
ORDER BY 1