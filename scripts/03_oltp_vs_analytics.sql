USE appdb;

-- OLTP-style query (fast, selective)
SELECT * FROM orders
WHERE customer_id = 12345
ORDER BY created_at DESC
LIMIT 50;

-- Analytics-style query (heavy aggregation)
SELECT status, DATE(created_at) AS day, COUNT(*) AS orders, SUM(order_total) AS revenue
FROM orders
WHERE created_at >= NOW() - INTERVAL 30 DAY
GROUP BY status, DATE(created_at)
ORDER BY day DESC;
