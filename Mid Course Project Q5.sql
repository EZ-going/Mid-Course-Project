USE mavenfuzzyfactory;

WITH

website_session AS
(
SELECT
	MONTH(created_at) AS month,
    MIN(DATE(created_at)) OVER(PARTITION BY MONTH(created_at)) AS month_start,
    website_session_id
FROM website_sessions a
WHERE DATE(a.created_at) < '2012-11-27'
)

SELECT
	month,
    COUNT(DISTINCT a.website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT a.website_session_id) AS conv_rate
FROM website_session a
LEFT JOIN orders b ON a.website_session_id = b.website_session_id
GROUP BY 1
ORDER BY 1