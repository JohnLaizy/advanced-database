--Check voucher data
SELECT voucher_id, voucher_code, membership_required, minimum_spend, status, value
FROM voucher
ORDER BY voucher_id;

SET LINESIZE 180
SET PAGESIZE 100

COLUMN voucher_id            FORMAT 999
COLUMN voucher_code          FORMAT A15
COLUMN voucher_type          FORMAT A15
COLUMN membership_required   FORMAT A10
COLUMN minimum_spend         FORMAT 90.99
COLUMN value                 FORMAT 99999.99
COLUMN status                FORMAT A10
COLUMN start_date            FORMAT A12
COLUMN end_date              FORMAT A12

TTITLE LEFT '		VOUCHER DATA REPORT'

--Check order data
SELECT order_id, member_id, amount, order_status
FROM orders
ORDER BY order_id;

--Check member type
SELECT m.member_id, m.name, mt.type_name
FROM member m
JOIN membership_type mt
    ON m.membership_type_id = mt.membership_type_id
ORDER BY m.member_id;

--Check voucher eligibility
SELECT voucher_id,
       voucher_code,
       membership_required,
       status,
       minimum_spend
FROM voucher
ORDER BY voucher_id;

--Run the procedure
BEGIN
    pr_redeem_voucher(3, 1, 8);
END;
/


--Before running, make sure this combination actually satisfies 
the rules.

--Check result
SELECT redemption_id,
       order_id,
       voucher_id,
       member_id,
       discount_applied,
       status,
       redeemed_at
FROM voucher_redemption
ORDER BY redemption_id;

--Inactive voucher

BEGIN
    pr_redeem_voucher(3, 6, 8);
END;
/

--Minimum spend failed
BEGIN
    pr_redeem_voucher(33, 1, 3);
END;
/

--Membership mismatch
BEGIN
    pr_redeem_voucher(3, 2, 2);
END;
/

--Duplicate redemption
BEGIN
    pr_redeem_voucher(3, 1, 8);
END;
/

BEGIN
    pr_redeem_voucher(3, 1, 8);
END;
/
