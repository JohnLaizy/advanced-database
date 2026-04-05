CREATE OR REPLACE VIEW vw_restaurant_revenue AS
SELECT
    r.restaurant_id,
    r.name                  AS restaurant_name,
    COUNT(o.order_id)       AS total_orders,
    SUM(o.amount)           AS total_revenue
FROM restaurants r
JOIN orders o
    ON r.restaurant_id = o.restaurant_id
WHERE o.order_status != 'Cancelled'
GROUP BY r.restaurant_id, r.name;

SELECT
    restaurant_id,
    restaurant_name,
    total_orders,
    total_revenue
FROM vw_restaurant_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue) FROM vw_restaurant_revenue
)
ORDER BY total_revenue DESC;
