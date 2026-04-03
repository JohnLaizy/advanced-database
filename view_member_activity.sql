CREATE OR REPLACE VIEW vw_member_activity AS
SELECT 
    m.member_id,
    m.name,
    m.status,
    o.order_id,
    o.order_status,
    o.amount
FROM member m
JOIN orders o 
    ON m.member_id = o.member_id;


SELECT 
    name,
    status,
    COUNT(order_id) AS total_orders,
    SUM(amount) AS total_spent
FROM vw_member_activity
GROUP BY name, status
HAVING COUNT(order_id) > 3
ORDER BY total_orders DESC;
