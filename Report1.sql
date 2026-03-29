SET LINESIZE 180
SET PAGESIZE 100
SET VERIFY OFF

TTITLE LEFT '				MEMBER ORDER SUMMARY REPORT'

COLUMN member_id        FORMAT 999
COLUMN member_name      FORMAT A20
COLUMN membership_type  FORMAT A10
COLUMN total_orders     FORMAT 999
COLUMN total_spent      FORMAT 99990.99
COLUMN avg_order_amount FORMAT 99990.99

SELECT
    m.member_id,
    m.name AS member_name,
    mt.type_name AS membership_type,
    COUNT(o.order_id) AS total_orders,
    NVL(SUM(o.amount), 0) AS total_spent,
    NVL(ROUND(AVG(o.amount), 2), 0) AS avg_order_amount
FROM member m
JOIN membership_type mt
    ON m.membership_type_id = mt.membership_type_id
LEFT JOIN orders o
    ON m.member_id = o.member_id
GROUP BY
    m.member_id,
    m.name,
    mt.type_name
ORDER BY total_spent DESC;