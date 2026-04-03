CREATE OR REPLACE TRIGGER trg_limit_voucher_usage
BEFORE INSERT ON voucher_redemption
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM voucher_redemption
    WHERE voucher_id = :NEW.voucher_id;

    IF v_count >= 2 THEN
        RAISE_APPLICATION_ERROR(-20030, 'Voucher usage limit reached');
    END IF;
END;
/
