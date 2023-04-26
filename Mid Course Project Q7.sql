USE mavenfuzzyfactory;

WITH

website_session AS
(
SELECT DISTINCT
    a.website_pageview_id,
    a.website_session_id,
    CASE 
	WHEN pageview_url = '/lander-1' THEN 'lander-1'
        WHEN pageview_url = '/home' THEN 'home'
    END AS landing_page
FROM website_pageviews a
JOIN website_sessions b ON a.website_session_id = b.website_session_id
WHERE DATE(a.created_at) < '2012-07-28'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
AND a.website_pageview_id >= 23504
AND pageview_url IN ('/lander-1','/home')
)

SELECT
    landing_page,
    sessions,
    to_product/sessions AS homepage_click_rate,
    to_mrfuzzy/to_product AS product_click_rate,
    to_cart/to_mrfuzzy AS mrfuzzy_click_rate,
    to_shipping/to_cart AS cart_click_rate,
    to_billing/to_shipping AS shipping_click_rate,
    to_thank_you/to_billing AS billing_click_rate
FROM
(
	SELECT
		landing_page,
		COUNT(DISTINCT website_session_id) AS sessions,
		COUNT(DISTINCT CASE WHEN to_product = 1 THEN website_session_id ELSE NULL END) AS to_product,
		COUNT(DISTINCT CASE WHEN to_mrfuzzy = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
		COUNT(DISTINCT CASE WHEN to_cart = 1 THEN website_session_id ELSE NULL END) AS to_cart,
		COUNT(DISTINCT CASE WHEN to_shipping = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
		COUNT(DISTINCT CASE WHEN to_billing = 1 THEN website_session_id ELSE NULL END) AS to_billing,
		COUNT(DISTINCT CASE WHEN to_thank_you = 1 THEN website_session_id ELSE NULL END) AS to_thank_you
	FROM
	(
		SELECT
			a.landing_page,
			a.website_session_id,
			CASE WHEN pageview_url = '/productS' THEN 1 ELSE 0 END AS to_product,
			CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS to_mrfuzzy,
			CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS to_cart,
			CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS to_shipping,
			CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS to_billing,
			CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS to_thank_you
		FROM website_session a
		LEFT JOIN website_pageviews b ON a.website_session_id = b.website_session_id
	) a
	GROUP BY 1
) a
