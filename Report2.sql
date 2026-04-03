CREATE OR REPLACE PROCEDURE rpt_restaurant_sales AS
    -- Cursor for aggregating successful sales by restaurant
    CURSOR c_rest_stats IS
        SELECT
            r.restaurant_id,
            r.name AS restaurant_name,
            r.category,
            COUNT(o.order_id) AS total_delivered_orders,
            NVL(SUM(o.amount), 0) AS total_revenue,
            NVL(ROUND(AVG(o.amount), 2), 0) AS avg_order_value
        FROM restaurants r
        LEFT JOIN orders o
            ON r.restaurant_id = o.restaurant_id
           AND o.order_status = 'Delivered'
        GROUP BY
            r.restaurant_id,
            r.name,
            r.category
        ORDER BY total_revenue DESC;
BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 90, '='));
    DBMS_OUTPUT.PUT_LINE('                      RESTAURANT SALES REPORT');
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 90, '='));
    DBMS_OUTPUT.PUT_LINE(
        RPAD('ID', 5) || 
        RPAD('RESTAURANT NAME', 28) || 
        RPAD('CATEGORY', 12) || 
        RPAD('DELIVERED', 12) || 
        RPAD('REVENUE', 18) || 
        'AVG VALUE'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 90, '-'));

    FOR r_rest IN c_rest_stats LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r_rest.restaurant_id, 5) || 
            RPAD(r_rest.restaurant_name, 28) || 
            RPAD(r_rest.category, 12) || 
            RPAD(r_rest.total_delivered_orders, 12) || 
            RPAD('RM' || TO_CHAR(r_rest.total_revenue, '99990.90'), 18) || 
            'RM' || TO_CHAR(r_rest.avg_order_value, '99990.90')
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 90, '='));
END;
/

SET SERVEROUTPUT ON;
SET LINESIZE 150;
EXEC rpt_restaurant_sales;