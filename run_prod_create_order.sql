DECLARE
    --for storing the new order ID
    v_id NUMBER;
BEGIN
    create_order(1, 2, 50, v_id);
    DBMS_OUTPUT.PUT_LINE('New Order ID: ' || v_id);
END;
/