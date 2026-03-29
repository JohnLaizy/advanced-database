CREATE OR REPLACE TRIGGER trg_check_payment
BEFORE INSERT ON payments
FOR EACH ROW
-- Rejects any payment with a non-positive amount before it hits the table.
BEGIN
    IF :NEW.amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20003,
            'Invalid payment amount: ' || :NEW.amount ||
            '. Amount must be greater than zero.');
    END IF;
END trg_check_payment;
/