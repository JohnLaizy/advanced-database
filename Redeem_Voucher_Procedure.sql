SET SERVEROUTPUT ON;

CREATE SEQUENCE seq_redemption_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE OR REPLACE PROCEDURE pr_redeem_voucher (
    p_order_id    IN voucher_redemption.order_id%TYPE,
    p_voucher_id  IN voucher_redemption.voucher_id%TYPE,
    p_member_id   IN voucher_redemption.member_id%TYPE
)
IS
    v_minimum_spend        voucher.minimum_spend%TYPE;
    v_voucher_value        voucher.value%TYPE;
    v_membership_required  voucher.membership_required%TYPE;
    v_voucher_status       voucher.status%TYPE;
    v_order_amount         orders.amount%TYPE;
    v_member_type          membership_type.type_name%TYPE;

    ex_min_spend_failed EXCEPTION;
    ex_membership_failed EXCEPTION;
    ex_voucher_inactive EXCEPTION;
BEGIN
    -- 1. Get voucher details
    SELECT minimum_spend, value, membership_required, status
    INTO v_minimum_spend, v_voucher_value, v_membership_required, v_voucher_status
    FROM voucher
    WHERE voucher_id = p_voucher_id;

    -- 2. Get order amount
    SELECT amount
    INTO v_order_amount
    FROM orders
    WHERE order_id = p_order_id;

    -- 3. Get member membership type
    SELECT mt.type_name
    INTO v_member_type
    FROM member m
    JOIN membership_type mt
        ON m.membership_type_id = mt.membership_type_id
    WHERE m.member_id = p_member_id;

    -- 4. Check voucher status
    IF v_voucher_status <> 'Active' THEN
        RAISE ex_voucher_inactive;
    END IF;

    -- 5. Check minimum spend
    IF v_order_amount < v_minimum_spend THEN
        RAISE ex_min_spend_failed;
    END IF;

    -- 6. Check membership eligibility
    IF v_membership_required <> 'Both'
       AND v_membership_required <> v_member_type THEN
        RAISE ex_membership_failed;
    END IF;

    -- 7. Insert voucher redemption record
    INSERT INTO voucher_redemption (
        redemption_id,
        redeemed_at,
        discount_applied,
        status,
        order_id,
        voucher_id,
        member_id
    )
    VALUES (
        seq_redemption_id.NEXTVAL,
        SYSDATE,
        v_voucher_value,
        'Applied',
        p_order_id,
        p_voucher_id,
        p_member_id
    );

    DBMS_OUTPUT.PUT_LINE('Voucher redeemed successfully.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Order, voucher, or member not found.');
    WHEN ex_voucher_inactive THEN
        DBMS_OUTPUT.PUT_LINE('Voucher is not active.');
    WHEN ex_min_spend_failed THEN
        DBMS_OUTPUT.PUT_LINE('Order amount does not meet minimum spend.');
    WHEN ex_membership_failed THEN
        DBMS_OUTPUT.PUT_LINE('Member is not eligible for this voucher.');
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('This order already has a voucher redemption record.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END;
/