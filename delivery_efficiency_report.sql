CREATE OR REPLACE PROCEDURE delivery_efficiency_report AS
    -- Cursor to get all delivery companies
    CURSOR c_companies IS 
        SELECT company_id, company_name, service_type 
        FROM delivery_company; --
        
    v_total_deliv   NUMBER;
    v_success_deliv NUMBER;
    v_success_rate  NUMBER(5,2);
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('                DELIVERY PERFORMANCE SUMMARY                ');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('COMPANY', 15) || RPAD('SERVICE', 12) || RPAD('TOTAL', 10) || 'SUCCESS %');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');

    FOR r_comp IN c_companies LOOP
        -- Count total deliveries assigned to this company
        SELECT COUNT(*) INTO v_total_deliv 
        FROM delivery 
        WHERE company_id = r_comp.company_id; --

        -- Count only successful deliveries
        SELECT COUNT(*) INTO v_success_deliv 
        FROM delivery 
        WHERE company_id = r_comp.company_id 
        AND delivery_status = 'Delivered'; --

        -- Calculate percentage
        IF v_total_deliv > 0 THEN
            v_success_rate := (v_success_deliv / v_total_deliv) * 100;
        ELSE
            v_success_rate := 0;
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(SUBSTR(r_comp.company_name, 1, 14), 15) || 
            RPAD(r_comp.service_type, 12) || 
            RPAD(v_total_deliv, 10) || 
            TO_CHAR(v_success_rate, '990.99') || '%'
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('============================================================');
END;
/
