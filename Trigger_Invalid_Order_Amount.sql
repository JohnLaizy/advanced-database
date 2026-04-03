CREATE OR REPLACE TRIGGER trg_check_order_amount
BEFORE INSERT OR UPDATE ON orders
FOR EACH ROW
BEGIN
    IF :NEW.amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Order amount must be greater than 0.');
    END IF;
END;
/