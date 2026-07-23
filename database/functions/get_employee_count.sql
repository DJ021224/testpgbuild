-- ============================================================
-- Function  : get_employee_count
-- Purpose   : Return the number of employees in a department.
--             Returns 0 if the department does not exist.
-- ============================================================

CREATE OR REPLACE FUNCTION get_employee_count(p_department VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO   v_count
    FROM   employee
    WHERE  LOWER(department) = LOWER(TRIM(p_department));

    RETURN COALESCE(v_count, 0);
END;
$$;

COMMENT ON FUNCTION get_employee_count IS
    'Returns number of employees in the given department (case-insensitive)';


-- ============================================================
-- Function  : get_customer_total_spend
-- Purpose   : Return the total amount spent by a customer
-- ============================================================

CREATE OR REPLACE FUNCTION get_customer_total_spend(p_customer_id INTEGER)
RETURNS NUMERIC(10,2)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_total NUMERIC(10,2);
BEGIN
    SELECT COALESCE(SUM(total), 0)
    INTO   v_total
    FROM   invoice
    WHERE  customer_id = p_customer_id;

    RETURN v_total;
END;
$$;

COMMENT ON FUNCTION get_customer_total_spend IS
    'Returns the lifetime total spend of a customer across all invoices';


-- ============================================================
-- Function  : get_top_tracks
-- Purpose   : Return the N best-selling tracks by quantity sold
-- ============================================================

CREATE OR REPLACE FUNCTION get_top_tracks(p_limit INTEGER DEFAULT 10)
RETURNS TABLE (
    track_id   INTEGER,
    track_name VARCHAR(200),
    artist_name VARCHAR(120),
    total_sold  BIGINT
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.track_id,
        t.name             AS track_name,
        ar.name            AS artist_name,
        SUM(il.quantity)   AS total_sold
    FROM   invoiceline il
    JOIN   track  t  ON t.track_id  = il.track_id
    JOIN   album  al ON al.album_id = t.album_id
    JOIN   artist ar ON ar.artist_id = al.artist_id
    GROUP BY t.track_id, t.name, ar.name
    ORDER BY total_sold DESC
    LIMIT p_limit;
END;
$$;

COMMENT ON FUNCTION get_top_tracks IS
    'Returns the top N tracks ranked by total quantity sold';
