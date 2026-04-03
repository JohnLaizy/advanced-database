CREATE OR REPLACE VIEW vw_delivery_performance AS
SELECT 
    o.order_id,
    o.order_status,
    o.order_type,
    d.delivery_status,
    dc.service_type,
    o.amount
FROM orders o
JOIN delivery d 
    ON o.order_id = d.order_id
JOIN delivery_company dc 
    ON d.company_id = dc.company_id;

SELECT 
    service_type,
    COUNT(order_id) AS total_orders,
    SUM(CASE WHEN order_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(AVG(amount), 2) AS avg_order_value
FROM vw_delivery_performance
GROUP BY service_type;
