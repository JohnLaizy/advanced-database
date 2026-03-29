INSERT INTO voucher (voucher_id, voucher_code, voucher_type, membership_required, minimum_spend, value, status, start_date, end_date)
VALUES (15, 'TEST_EXPIRE1', 'Discount', 'Both', 50, 10, 'Active', SYSDATE-10, SYSDATE-1);

INSERT INTO voucher (voucher_id, voucher_code, voucher_type, membership_required, minimum_spend, value, status, start_date, end_date)
VALUES (12, 'TEST_ACTIVE2', 'Discount', 'Both', 50, 10, 'Inactive', SYSDATE, SYSDATE+10);

SELECT voucher_id, status FROM voucher WHERE voucher_id = 1001;