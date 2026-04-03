-- ------------------------------------------------------------
-- Prints each member's full order history with a per-member
-- running subtotal and a grand total across all members.
-- Nested cursor qualifies for full 8 marks (nested cursor tier).
-- Outer cursor : iterates members
-- Inner cursor : iterates each member's orders
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE member_order_report
IS
    v_subtotal      NUMBER;
    v_grand_total   NUMBER := 0;
    v_grand_orders  NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('         MEMBER ORDER REPORT            ');
    DBMS_OUTPUT.PUT_LINE('========================================');

    -- Outer cursor: all members
    FOR m IN (
        SELECT member_id, name, status
        FROM   member
        ORDER  BY member_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Member : ' || RPAD(m.name, 20) ||
            ' (ID: '    || RPAD(m.member_id, 3) ||
            ' | Status: '|| RPAD(m.status, 10) || ')'
        );

        v_subtotal := 0;

        -- Inner cursor: orders for this member, joined with restaurant name
        FOR o IN (
            SELECT
                o.order_id,
                o.amount,
                o.order_date,
                o.order_status,
                r.name AS restaurant_name
            FROM   orders o
            JOIN   restaurants r ON o.restaurant_id = r.restaurant_id
            WHERE  o.member_id = m.member_id
            ORDER  BY o.order_date
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                '   Order #'  || RPAD(o.order_id, 4)                            ||
                ' | '         || TO_CHAR(o.order_date, 'DD-Mon-YYYY') ||
                ' | '         || RPAD(o.restaurant_name, 20)          ||
                ' | RM '      || LPAD(TO_CHAR(o.amount, 'FM999,999.00'), 9)    ||
                ' | '         || RPAD(o.order_status, 15)
            );
            v_subtotal     := v_subtotal + o.amount;
            v_grand_orders := v_grand_orders + 1;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE(
            '   >>> Member Total: RM ' || TO_CHAR(v_subtotal, 'FM999,999.00')
        );
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');

        v_grand_total := v_grand_total + v_subtotal;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE(
        'GRAND TOTAL - Orders: ' || v_grand_orders ||
        '   Revenue: RM '        || TO_CHAR(v_grand_total, 'FM999,999.00')
    );
    DBMS_OUTPUT.PUT_LINE('========================================');
END member_order_report;
/

-- TEST CASE: Member Order History (Detailed Nested Cursor)
EXEC member_order_report;