SET LINESIZE 180
SET PAGESIZE 100
SET VERIFY OFF

TTITLE LEFT '			RESTAURANT SALES REPORT'

COLUMN restaurant_id           FORMAT 999
COLUMN restaurant_name         FORMAT A25
COLUMN category                FORMAT A10
COLUMN total_delivered_orders  FORMAT 999
COLUMN total_revenue           FORMAT 99990.99
COLUMN avg_order_value         FORMAT 99990.99

SELECT
    r.restaurant_id,
    r.name AS restaurant_name,
    r.category,
    COUNT(o.order_id) AS total_delivered_orders,
    NVL(SUM(o.amount), 0) AS total_revenue,
    NVL(ROUND(AVG(o.amount), 2), 0) AS avg_order_value
FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
   AND o.order_status = 'Delivered'
GROUP BY
    r.restaurant_id,
    r.name,
    r.category
ORDER BY total_revenue DESC;