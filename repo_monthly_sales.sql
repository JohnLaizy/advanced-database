-- ------------------------------------------------------------
-- Accepts p_month (VARCHAR2, 'YYYY-MM' format) as an IN parameter. If NULL is passed, all months are shown.
-- This makes it a true on-demand report — callers control scope.
--
-- Usage examples:
--   EXEC monthly_sales_report('2024-03');   -- specific month
--   EXEC monthly_sales_report(NULL);        -- all months
--
-- Cursor: single implicit FOR loop (summary-level data)
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE monthly_sales_report (
    p_month IN VARCHAR2 DEFAULT NULL
)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    IF p_month IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('   MONTHLY SALES REPORT: ' || p_month);
    ELSE
        DBMS_OUTPUT.PUT_LINE('   MONTHLY SALES REPORT: ALL MONTHS');
    END IF;
    DBMS_OUTPUT.PUT_LINE('========================================');

    FOR v_row IN (
        SELECT
            TO_CHAR(order_date, 'YYYY-MM')  AS month,
            COUNT(*)                         AS total_orders,
            SUM(amount)                      AS total_revenue
        FROM   orders
        WHERE  order_status != 'Cancelled'
        AND   (p_month IS NULL
               OR TO_CHAR(order_date, 'YYYY-MM') = p_month)
        GROUP  BY TO_CHAR(order_date, 'YYYY-MM')
        ORDER  BY 1
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Month: '        || v_row.month           ||
            ' | Orders: '    || v_row.total_orders     ||
            ' | Revenue: RM '|| TO_CHAR(v_row.total_revenue, 'FM999,999.00')
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('========================================');
END monthly_sales_report;
/

-- TEST CASE 4A: Monthly Sales Report (Specific Month)
EXEC monthly_sales_report('2024-03');

-- TEST CASE 4B: Monthly Sales Report (All Time)
EXEC monthly_sales_report(NULL);
