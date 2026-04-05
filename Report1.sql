CREATE OR REPLACE PROCEDURE rpt_member_summary AS
    -- Cursor for calculating member-specific order aggregates
    CURSOR c_member_stats IS
        SELECT
            m.member_id,
            m.name AS member_name,
            mt.type_name AS membership_type,
            COUNT(o.order_id) AS total_orders,
            NVL(SUM(o.amount), 0) AS total_spent,
            NVL(ROUND(AVG(o.amount), 2), 0) AS avg_order_amount
        FROM member m
        JOIN membership_type mt
            ON m.membership_type_id = mt.membership_type_id
        LEFT JOIN orders o
            ON m.member_id = o.member_id
        GROUP BY
            m.member_id,
            m.name,
            mt.type_name
        ORDER BY total_spent DESC;
BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 85, '='));
    DBMS_OUTPUT.PUT_LINE('                    MEMBER ORDER SUMMARY REPORT');
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 85, '='));
    DBMS_OUTPUT.PUT_LINE(
        RPAD('ID', 5) || 
        RPAD('MEMBER NAME', 22) || 
        RPAD('TYPE', 12) || 
        RPAD('ORDERS', 8) || 
        RPAD('SPENT', 18) || 
        'AVG AMOUNT'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 85, '-'));

    FOR r_mem IN c_member_stats LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r_mem.member_id, 5) || 
            RPAD(r_mem.member_name, 22) || 
            RPAD(r_mem.membership_type, 12) || 
            RPAD(r_mem.total_orders, 8) || 
            RPAD('RM' || TO_CHAR(r_mem.total_spent, '99990.90'), 18) || 
            'RM' || TO_CHAR(r_mem.avg_order_amount, '99990.90')
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 85, '='));
END;
/



SET SERVEROUTPUT ON;
SET LINESIZE 150;
EXEC rpt_member_summary;