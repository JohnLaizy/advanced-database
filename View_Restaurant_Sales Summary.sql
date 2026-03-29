CREATE OR REPLACE VIEW vw_restaurant_sales_summary AS
SELECT
    r.restaurant_id,
    r.name AS restaurant_name,
    r.category,
    r.rating,
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
    r.category,
    r.rating;

SET LINESIZE 180
SET PAGESIZE 100

COLUMN restaurant_id           FORMAT 999
COLUMN restaurant_name         FORMAT A25
COLUMN category                FORMAT A10
COLUMN rating                  FORMAT 9.9
COLUMN total_delivered_orders  FORMAT 999
COLUMN total_revenue           FORMAT 99999.99
COLUMN avg_order_value         FORMAT 99999.99

TTITLE LEFT '				RESTAURANT SALES SUMMARY REPORT'

SELECT *
FROM vw_restaurant_sales_summary
ORDER BY total_revenue DESC, total_delivered_orders DESC;