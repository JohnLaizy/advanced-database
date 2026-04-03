CREATE OR REPLACE TRIGGER trg_log_feedback_resolution
BEFORE UPDATE ON feedback
FOR EACH ROW
BEGIN
    IF :NEW.status = 'Resolved' AND :NEW.comments IS NULL THEN
        RAISE_APPLICATION_ERROR(-20020, 'Cannot resolve feedback without resolution comments.');
    END IF;
END;
/