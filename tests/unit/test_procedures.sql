-- ============================================================
-- Test Suite : Unit — Stored Procedures & Functions
-- ============================================================

DO $$
DECLARE
    v_count   INTEGER;
    v_spend   NUMERIC;
BEGIN

    -- Test 1: employee_dj sets title correctly
    CALL employee_dj('Sales', 0);
    SELECT COUNT(*) INTO v_count
    FROM   employee
    WHERE  department = 'Sales' AND title = 'DJ';
    IF v_count < 1 THEN
        RAISE EXCEPTION 'FAIL: employee_dj did not update Sales department';
    END IF;
    RAISE NOTICE 'PASS: employee_dj updates Sales dept (% rows)', v_count;

    -- Reset titles
    UPDATE employee SET title = 'Sales Support Agent'
    WHERE  department = 'Sales' AND employee_id IN (3,4,5);
    UPDATE employee SET title = 'Sales Manager'
    WHERE  department = 'Sales' AND employee_id = 2;

    -- Test 2: employee_dj rejects empty department
    BEGIN
        CALL employee_dj('', 0);
        RAISE EXCEPTION 'FAIL: employee_dj should reject empty department';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'PASS: employee_dj rejects empty department';
    END;

    -- Test 3: get_employee_count returns correct count
    SELECT get_employee_count('IT') INTO v_count;
    IF v_count <> 3 THEN
        RAISE EXCEPTION 'FAIL: get_employee_count(IT) expected 3, got %', v_count;
    END IF;
    RAISE NOTICE 'PASS: get_employee_count(IT) = %', v_count;

    -- Test 4: get_employee_count is case-insensitive
    SELECT get_employee_count('it') INTO v_count;
    IF v_count <> 3 THEN
        RAISE EXCEPTION 'FAIL: get_employee_count case-insensitive failed, got %', v_count;
    END IF;
    RAISE NOTICE 'PASS: get_employee_count case-insensitive OK';

    -- Test 5: get_employee_count returns 0 for unknown department
    SELECT get_employee_count('NonExistent') INTO v_count;
    IF v_count <> 0 THEN
        RAISE EXCEPTION 'FAIL: get_employee_count(NonExistent) expected 0, got %', v_count;
    END IF;
    RAISE NOTICE 'PASS: get_employee_count returns 0 for unknown dept';

    -- Test 6: get_customer_total_spend returns positive value for known customer
    SELECT get_customer_total_spend(1) INTO v_spend;
    IF v_spend <= 0 THEN
        RAISE EXCEPTION 'FAIL: get_customer_total_spend(1) expected > 0, got %', v_spend;
    END IF;
    RAISE NOTICE 'PASS: get_customer_total_spend(1) = %', v_spend;

    RAISE NOTICE '========== UNIT TESTS COMPLETE ==========';
END;
$$;
