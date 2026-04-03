CREATE OR REPLACE PROCEDURE create_order (
    p_member_id     IN  NUMBER,
    p_restaurant_id IN  NUMBER,
    p_amount        IN  NUMBER,
    p_order_id      OUT NUMBER
)
IS
    -- Custom named exception for missing member
    e_member_not_found  EXCEPTION;
    -- PRAGMA binds ORA-01403 (NO_DATA_FOUND) to the custom name above
    PRAGMA EXCEPTION_INIT(e_member_not_found, -10403);

    v_status VARCHAR2(20);
BEGIN
    -- Guard: amount must be positive
    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Order amount must be greater than zero');
    END IF;

    -- Fetch member status; e_member_not_found raised below if member doesn't exist
    SELECT status
    INTO   v_status
    FROM   member
    WHERE  member_id = p_member_id;

    IF v_status != 'active' THEN
        RAISE_APPLICATION_ERROR(-20001,
            'Member ID ' || p_member_id || ' is not active (status: ' || v_status || ')');
    END IF;

    p_order_id := seq_order_id.NEXTVAL;

    INSERT INTO orders (
        order_id, amount, order_date, order_status,
        order_type, restaurant_id, member_id
    ) VALUES (
        p_order_id, p_amount, SYSDATE, 'Pending',
        'Delivery', p_restaurant_id, p_member_id
    );

    COMMIT;

EXCEPTION
    -- Catches the PRAGMA-bound custom exception for missing member
    WHEN e_member_not_found THEN
        RAISE_APPLICATION_ERROR(-20004,
            'Member ID ' || p_member_id || ' does not exist');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END create_order;
/

SET SERVEROUTPUT ON;
-- Declare bind variables for OUT parameters
VARIABLE v_id NUMBER;
VARIABLE v_status_msg VARCHAR2(100);
-- TEST block
DECLARE
    v_new_id NUMBER;
BEGIN
    -- Member 1 is 'active' in mock data
    create_order(p_member_id => 1, p_restaurant_id => 5, p_amount => 55.50, p_order_id => v_new_id);
    DBMS_OUTPUT.PUT_LINE('Success! New Order ID: ' || v_new_id);
END;
/

-- TEST CASE 1B: Fail - Inactive Member (Suspended)
variable v_id NUMBER;

-- Member 4 is 'suspended' in mock data
EXEC create_order(4, 1, 20.00, :v_id); 

-- TEST CASE 1C: Fail - Non-existent Member
EXEC create_order(999, 1, 20.00, :v_id); 

-- TEST CASE 1D: Fail - Non-positive Amount
EXEC create_order(1, 1, -5.00, :v_id);