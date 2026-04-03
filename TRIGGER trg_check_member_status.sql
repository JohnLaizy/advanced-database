CREATE OR REPLACE TRIGGER trg_check_member_status
BEFORE INSERT ON orders
FOR EACH ROW
DECLARE
    v_status VARCHAR2(20);
BEGIN
    SELECT status INTO v_status
    FROM member
    WHERE member_id = :NEW.member_id;

    IF v_status <> 'active' THEN
        RAISE_APPLICATION_ERROR(-20010, 'Only active members can place orders');
    END IF;
END;
/
