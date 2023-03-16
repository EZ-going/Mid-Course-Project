USE mavenfuzzyfactory;

WITH

website_session AS
(
SELECT DISTINCT
	a.website_pageview_id,
    a.website_session_id,
    pageview_url AS landing_page
FROM website_pageviews a
JOIN website_sessions b ON a.website_session_id = b.website_session_id
WHERE DATE(a.created_at) < '2012-07-28'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
AND a.website_pageview_id >= 23504
AND pageview_url IN ('/lander-1','/home')
)

SELECT
	lander_sessions,
	lander_orders,
    lander_revenue,
    lander_revenue - lander_cost AS lander_profit,
    home_sessions,
    home_orders,
    home_revenue,
    home_revenue - home_cost AS home_profit
FROM
(
	SELECT
		COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN a.website_session_id ELSE NULL END) AS lander_sessions,
		COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN order_id ELSE NULL END) AS lander_orders,
		SUM(CASE WHEN landing_page = '/lander-1' THEN price_usd ELSE 0 END) AS lander_revenue,
		SUM(CASE WHEN landing_page = '/lander-1' THEN cogs_usd ELSE 0 END) AS lander_cost,
        COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN a.website_session_id ELSE NULL END) AS home_sessions,
		COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN order_id ELSE NULL END) AS home_orders,
		SUM(CASE WHEN landing_page = '/home' THEN price_usd ELSE 0 END) AS home_revenue,
		SUM(CASE WHEN landing_page = '/home' THEN cogs_usd ELSE 0 END) AS home_cost
	FROM website_session a
	LEFT JOIN orders b ON a.website_session_id = b.website_session_id
) a