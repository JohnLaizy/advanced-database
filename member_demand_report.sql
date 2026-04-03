CREATE OR REPLACE PROCEDURE member_demand_report (p_member_id IN NUMBER) AS
    -- Cursor for Member Details
    CURSOR c_member_info IS
        SELECT m.name, m.email, mt.type_name, m.status
        FROM member m
        JOIN membership_type mt ON m.membership_type_id = mt.membership_type_id
        WHERE m.member_id = p_member_id;

    -- Cursor for Feedback History
    CURSOR c_feedback IS
        SELECT f.feedback_type, f.comments, f.status
        FROM feedback f
        JOIN orders o ON f.order_id = o.order_id
        WHERE o.member_id = p_member_id;
        
    r_mem           c_member_info%ROWTYPE;
    v_feedback_count NUMBER := 0; -- Counter for total feedback
BEGIN
    -- Validation: Check if member exists
    OPEN c_member_info;
    FETCH c_member_info INTO r_mem;
    
    IF c_member_info%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('ERROR: Member ID ' || p_member_id || ' was not found in the system.');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
        CLOSE c_member_info;
        RETURN;
    END IF;
    CLOSE c_member_info;

    -- Header Section
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('                ON-DEMAND MEMBER ACTIVITY REPORT            ');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('NAME:', 15) || r_mem.name);
    DBMS_OUTPUT.PUT_LINE(RPAD('EMAIL:', 15) || r_mem.email);
    DBMS_OUTPUT.PUT_LINE(RPAD('MEMBERSHIP:', 15) || r_mem.type_name || ' (' || UPPER(r_mem.status) || ')');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
    
    -- Feedback Table Header
    DBMS_OUTPUT.PUT_LINE(RPAD('TYPE', 15) || RPAD('STATUS', 12) || 'COMMENTS (Preview)');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');

    -- Feedback Loop
    FOR r_fb IN c_feedback LOOP
        v_feedback_count := v_feedback_count + 1; -- Increment total
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r_fb.feedback_type, 15) || 
            RPAD(r_fb.status, 12) || 
            SUBSTR(r_fb.comments, 1, 33) || '...'
        );
    END LOOP;
    
    -- Footer with Summary
    IF v_feedback_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No feedback entries found for this member.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(RPAD('TOTAL FEEDBACK ENTRIES:', 25) || v_feedback_count);
    DBMS_OUTPUT.PUT_LINE('======================== END OF REPORT =====================');
END;
/
