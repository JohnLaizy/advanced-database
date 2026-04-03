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

BEGIN
    OPEN c_top;

    LOOP
        FETCH c_top INTO v_name, v_sales;
        EXIT WHEN c_top%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            'Restaurant: ' || v_name || 
            ', Total Sales: ' || v_sales
        );
    END LOOP;

    CLOSE c_top;
END;
