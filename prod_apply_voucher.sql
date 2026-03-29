CREATE OR REPLACE PROCEDURE apply_voucher (
    p_order_id   IN NUMBER,
    p_voucher_id IN NUMBER
)
IS
    v_min_spend      NUMBER;
    v_discount       NUMBER;
    v_voucher_status VARCHAR2(20);
    v_amount         NUMBER;
    v_already_used   NUMBER;
BEGIN
    -- Fetch voucher details in one query
    SELECT minimum_spend, value, status
    INTO   v_min_spend, v_discount, v_voucher_status
    FROM   voucher
    WHERE  voucher_id = p_voucher_id;

    -- Guard: voucher must be active
    IF v_voucher_status != 'Active' THEN
        RAISE_APPLICATION_ERROR(-20008,
            'Voucher ID ' || p_voucher_id || ' is ' || v_voucher_status || ' and cannot be applied');
    END IF;

    -- Fetch order amount
    SELECT amount
    INTO   v_amount
    FROM   orders
    WHERE  order_id = p_order_id;

    -- Guard: minimum spend check
    IF v_amount < v_min_spend THEN
        RAISE_APPLICATION_ERROR(-20002,
            'Order amount (' || v_amount || ') does not meet minimum spend (' || v_min_spend || ')');
    END IF;

    -- Guard: prevent duplicate redemption on the same order
    SELECT COUNT(*)
    INTO   v_already_used
    FROM   voucher_redemption
    WHERE  order_id   = p_order_id
    AND    voucher_id = p_voucher_id;

    IF v_already_used > 0 THEN
        RAISE_APPLICATION_ERROR(-20006,
            'Voucher ID ' || p_voucher_id || ' has already been applied to order ' || p_order_id);
    END IF;

    INSERT INTO voucher_redemption (
        redemption_id, order_id, voucher_id, member_id, discount_applied
    )
    SELECT
        seq_redemption_id.NEXTVAL,
        o.order_id,
        p_voucher_id,
        o.member_id,
        v_discount
    FROM orders o
    WHERE o.order_id = p_order_id;

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005,
            'Voucher ID ' || p_voucher_id || ' or Order ID ' || p_order_id || ' not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END apply_voucher;
/

-- SETUP: Create a fresh order to test with
VAR g_order_id NUMBER;
EXEC create_order(1, 1, 100.00, :g_order_id);

-- TEST CASE 2A: Successful Voucher Application
-- Voucher 1: Active, Min Spend 20 (Our order is 100)
EXEC apply_voucher(:g_order_id, 1);

-- TEST CASE 2B: Fail - Duplicate Application
-- Should trigger ORA-20006 (Duplicate redemption)
EXEC apply_voucher(:g_order_id, 1);

-- TEST CASE 2C: Fail - Minimum Spend Not Met
-- Create a small order
VAR g_small_order NUMBER;
EXEC create_order(1, 1, 5.00, :g_small_order);
-- Voucher 1 requires 20.00
EXEC apply_voucher(:g_small_order, 1);

-- TEST CASE 2D: Fail - Voucher Inactive/Expired
-- Voucher 6 is 'Inactive' in mock data
EXEC apply_voucher(:g_order_id, 6);