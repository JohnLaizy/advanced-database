CREATE OR REPLACE PROCEDURE sp_top_restaurants
IS
    CURSOR c_top IS
        SELECT r.name, SUM(o.amount) AS total_sales
        FROM orders o
        JOIN restaurants r ON o.restaurant_id = r.restaurant_id
        GROUP BY r.name
        ORDER BY total_sales DESC;

    v_name VARCHAR2(150);
    v_sales NUMBER;
    v_total_count NUMBER;

BEGIN
    -- Check if any data exists before opening cursor
    SELECT COUNT(*) INTO v_total_count FROM orders;
    
    -- Extra Effort: Default Exception check
    IF v_total_count = 0 THEN
        RAISE NO_DATA_FOUND;
    END IF;

    OPEN c_top;
    LOOP
        FETCH c_top INTO v_name, v_sales;
        EXIT WHEN c_top%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            'Restaurant: ' || RPAD(v_name, 25) || 
            ' | Total Sales: RM' || TO_CHAR(v_sales, 'FM99,990.90')
        );
    END LOOP;
    CLOSE c_top;

EXCEPTION
    -- Extra Effort: Type 1 - Default Exception Handling
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('REPORT ERROR: No order data available to generate sales rankings.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred in sp_top_restaurants.');
END;
/