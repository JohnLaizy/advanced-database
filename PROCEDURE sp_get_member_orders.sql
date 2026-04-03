CREATE OR REPLACE PROCEDURE sp_get_member_orders (
    p_member_id IN NUMBER
)
IS
    CURSOR c_orders IS
        SELECT o.order_id, o.amount, o.order_status, r.name AS restaurant_name
        FROM orders o
        JOIN restaurants r ON o.restaurant_id = r.restaurant_id
        WHERE o.member_id = p_member_id;

    v_order_id orders.order_id%TYPE;
    v_amount orders.amount%TYPE;
    v_status orders.order_status%TYPE;
    v_restaurant_name restaurants.name%TYPE;

BEGIN
    OPEN c_orders;
    
    LOOP
        FETCH c_orders INTO v_order_id, v_amount, v_status, v_restaurant_name;
        EXIT WHEN c_orders%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            'Order ID: ' || v_order_id ||
            ', Amount: ' || v_amount ||
            ', Status: ' || v_status ||
            ', Restaurant: ' || v_restaurant_name
        );
    END LOOP;

    CLOSE c_orders;
END;
/

-- Run procedure:
EXEC sp_get_member_orders(1);
