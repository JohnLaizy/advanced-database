CREATE OR REPLACE PROCEDURE pr_bulk_update_menu_price (
    p_restaurant_id IN NUMBER,
    p_percentage    IN NUMBER
) IS
    -- Define a record type to hold the price changes
    TYPE price_log_rec IS RECORD (
        item_name  menu.item_name%TYPE,
        old_price  menu.price%TYPE,
        new_price  menu.price%TYPE
    );
    
    -- Define a collection (table) of that record type
    TYPE price_log_tab IS TABLE OF price_log_rec;
    v_logs price_log_tab;

BEGIN
    -- 1. Perform the update and capture the old/new values in one go
    -- Note: We calculate the 'old' price mathematically based on the update for display
    UPDATE menu
    SET price = price * (1 + (p_percentage / 100))
    WHERE restaurant_id = p_restaurant_id
    RETURNING item_name, (price / (1 + (p_percentage / 100))), price 
    BULK COLLECT INTO v_logs;

    -- 2. Validation: Check if any rows were affected
    IF v_logs.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No menu items found for Restaurant ID: ' || p_restaurant_id);
    ELSE
        -- 3. Output Formatting: Display the price audit
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 60, '-'));
        DBMS_OUTPUT.PUT_LINE(RPAD('ITEM NAME', 25) || RPAD('OLD PRICE', 15) || 'NEW PRICE');
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 60, '-'));

        FOR i IN 1 .. v_logs.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(v_logs(i).item_name, 25) || 
                RPAD('RM' || TO_CHAR(v_logs(i).old_price, '999.99'), 15) || 
                'RM' || TO_CHAR(v_logs(i).new_price, '999.99')
            );
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 60, '-'));
        DBMS_OUTPUT.PUT_LINE('Total items updated: ' || v_logs.COUNT);
    END IF;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20016, 'Error during bulk price update: ' || SQLERRM);
END;
/
EXEC pr_bulk_update_menu_price(3, 10);