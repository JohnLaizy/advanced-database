CREATE OR REPLACE TRIGGER trg_voucher_expiry
BEFORE INSERT OR UPDATE ON voucher
FOR EACH ROW
-- Automatically marks a voucher as Expired if its end date is in the past.
-- Fires on both INSERT (new vouchers) and UPDATE (e.g. date corrections).
BEGIN
    IF :NEW.end_date < SYSDATE THEN
        :NEW.status := 'Expired';
    END IF;
END trg_voucher_expiry;
/

-- One-time backfill: mark existing expired vouchers that predate the trigger
UPDATE voucher
SET    status = 'Expired'
WHERE  end_date < SYSDATE
AND    status  != 'Expired';
COMMIT;