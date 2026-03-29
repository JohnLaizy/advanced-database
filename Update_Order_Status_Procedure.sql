SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE pr_update_order_status (
    p_order_id     IN orders.order_id%TYPE,
    p_new_status   IN orders.order_status%TYPE
)
IS
    v_count NUMBER;
BEGIN
    -- 1. 检查订单是否存在
    SELECT COUNT(*)
    INTO v_count
    FROM orders
    WHERE order_id = p_order_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Order ID does not exist.');
    END IF;

    -- 2. 检查状态是否合法
    IF p_new_status NOT IN (
        'Pending',
        'Confirmed',
        'Preparing',
        'Out for Delivery',
        'Delivered',
        'Cancelled'
    ) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid order status.');
    END IF;

    -- 3. 更新订单状态
    UPDATE orders
    SET order_status = p_new_status
    WHERE order_id = p_order_id;

    DBMS_OUTPUT.PUT_LINE('Order status updated successfully.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error updating order status: ' || SQLERRM);
END;
/