USE mavenfuzzyfactory;

WITH

website_session AS
(
SELECT
	MONTH(created_at) AS month,
    MIN(DATE(created_at)) OVER(PARTITION BY MONTH(created_at)) AS month_start,
    device_type,
    website_session_id
FROM website_sessions a
WHERE DATE(a.created_at) < '2012-11-27'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
)

SELECT
	month,
    mobile_sessions,
    mobile_orders,
    mobile_orders/mobile_sessions AS mobiel_conv_rate,
    desktop_sessions,
    desktop_orders,
    desktop_orders/desktop_sessions AS desktop_conv_rate
FROM
(
	SELECT
		month_start AS month,
		COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN a.website_session_id ELSE NULL END) AS mobile_sessions,
		COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN order_id ELSE NULL END) AS mobile_orders,
		COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN a.website_session_id ELSE NULL END) AS desktop_sessions,
		COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN order_id ELSE NULL END) AS desktop_orders
	FROM website_session a
	LEFT JOIN orders b ON a.website_session_id = b.website_session_id
	GROUP BY 1
) a
ORDER BY 1