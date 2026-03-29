--Check Original Status
SELECT order_id, order_status
FROM orders
WHERE order_id = 3;

--run procedure
BEGIN
    pr_update_order_status(3, 'Pending');
END;
/

--Query again
SELECT order_id, order_status
FROM orders
WHERE order_id = 3;

--Error Testing
BEGIN
    pr_update_order_status(9999, 'Delivered');
END;
/

--Test Invalid Status
BEGIN
    pr_update_order_status(3, 'Shipping');
END;
/