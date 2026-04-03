CREATE OR REPLACE TRIGGER trg_prevent_menu_deletion
BEFORE DELETE ON menu
FOR EACH ROW
BEGIN
    IF :OLD.is_available = 1 THEN
        RAISE_APPLICATION_ERROR(-20021, 'Cannot delete active menu items. Set is_available to 0 first.');
    END IF;
END;
/