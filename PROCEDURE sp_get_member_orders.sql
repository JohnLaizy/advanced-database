CREATE OR REPLACE PROCEDURE sp_get_member_orders (
    p_member_id IN NUMBER
)
IS
    -- Extra Effort: Type 2 - Custom Exception Definition
    e_invalid_member EXCEPTION;
    v_member_exists NUMBER;

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
    -- Validate member existence
    SELECT COUNT(*) INTO v_member_exists FROM member WHERE member_id = p_member_id;

    IF v_member_exists = 0 THEN
        -- Extra Effort: Raising the Custom Exception
        RAISE e_invalid_member;
    END IF;

    OPEN c_orders;
    LOOP
        FETCH c_orders INTO v_order_id, v_amount, v_status, v_restaurant_name;
        EXIT WHEN c_orders%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            'Order ID: ' || v_order_id ||
            ' | Amount: RM' || TO_CHAR(v_amount, 'FM990.90') ||
            ' | Status: ' || RPAD(v_status, 12) ||
            ' | Restaurant: ' || v_restaurant_name
        );
    END LOOP;
    
    -- If loop never ran, the member exists but has no orders
    IF c_orders%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No order history found for Member ID: ' || p_member_id);
    END IF;
    
    CLOSE c_orders;

EXCEPTION
    -- Extra Effort: Handling the Custom Exception
    WHEN e_invalid_member THEN
        DBMS_OUTPUT.PUT_LINE('VALIDATION ERROR: Member ID ' || p_member_id || ' does not exist in the database.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected system error occurred.');
END;
/