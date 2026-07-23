-- ============================================================
-- Procedure : employee_dj
-- Purpose   : Update the title of all employees in a given
--             department to 'DJ'. Raises a notice on success.
-- Parameters:
--   p_department  — department name to target
--   p_increment   — reserved for future salary increment logic
-- ============================================================

CREATE OR REPLACE PROCEDURE employee_dj(
    p_department  VARCHAR,
    p_increment   NUMERIC DEFAULT 0
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_affected INTEGER;
BEGIN
    IF p_department IS NULL OR TRIM(p_department) = '' THEN
        RAISE EXCEPTION 'p_department cannot be null or empty';
    END IF;

    UPDATE employee
    SET    title = 'DJ'
    WHERE  LOWER(department) = LOWER(TRIM(p_department));

    GET DIAGNOSTICS v_affected = ROW_COUNT;

    RAISE NOTICE 'employee_dj: % employee(s) in department "%" updated to title DJ.',
                 v_affected, p_department;
END;
$$;

COMMENT ON PROCEDURE employee_dj IS
    'Sets title=DJ for all employees in the specified department';
