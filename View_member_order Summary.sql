CREATE OR REPLACE VIEW vw_member_order_summary AS
SELECT 
    m.member_id,
    m.name AS member_name,
    m.email,
    mt.type_name AS membership_type,
    o.order_id,
    o.amount,
    o.order_date,
    o.order_status
FROM member m
JOIN membership_type mt
    ON m.membership_type_id = mt.membership_type_id
JOIN orders o
    ON m.member_id = o.member_id;
	
SET LINESIZE 150
SET PAGESIZE 120

COLUMN member_id        FORMAT 999
COLUMN member_name      FORMAT A20
COLUMN email            FORMAT A28
COLUMN membership_type  FORMAT A10
COLUMN order_id			FORMAT 9999
COLUMN total_orders     FORMAT 999
COLUMN total_spent      FORMAT 99999.99
COLUMN avg_order_amount FORMAT 99999.99

TTITLE LEFT '						MEMBER ORDER SUMMARY REPORT'

SELECT* from vw_member_order_summary;