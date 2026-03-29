CREATE OR REPLACE TRIGGER trg_check_voucher_expiry
BEFORE INSERT OR UPDATE ON voucher
FOR EACH ROW
BEGIN
    -- 如果过期 → 自动变 Inactive
    IF :NEW.end_date < TRUNC(SYSDATE) THEN
        :NEW.status := 'Inactive';
    END IF;

    -- 如果还没过期 → 自动变 Active
    IF :NEW.end_date >= TRUNC(SYSDATE) THEN
        :NEW.status := 'Active';
    END IF;
END;
/
