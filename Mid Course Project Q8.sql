USE mavenfuzzyfactory;

WITH

billings AS
(
SELECT
	pageview_url AS billing_page,
    website_session_id,
    website_pageview_id
FROM website_pageviews a
WHERE DATE(created_at) < '2012-11-10'
AND website_pageview_id >= 53550
AND pageview_url IN ('/billing','/billing-2')
)

SELECT
	billing_page,
    COUNT(DISTINCT a.website_session_id) AS sessions,
    SUM(price_usd) AS revenue,
    SUM(price_usd)/COUNT(DISTINCT a.website_session_id) AS rev_per_billing_page
FROM billings a
LEFT JOIN orders b ON a.website_session_id = b.website_session_id
GROUP BY 1