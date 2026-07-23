-- ============================================================
-- View : vw_invoice_summary
-- Purpose: Revenue summary per customer with invoice counts
-- ============================================================

CREATE OR REPLACE VIEW vw_invoice_summary AS
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name   AS customer_name,
    c.country,
    c.email,
    e.first_name || ' ' || e.last_name   AS support_rep,
    COUNT(i.invoice_id)                  AS invoice_count,
    SUM(i.total)                         AS total_spend,
    MIN(i.invoice_date)                  AS first_purchase,
    MAX(i.invoice_date)                  AS last_purchase
FROM   customer c
LEFT   JOIN invoice  i ON i.customer_id    = c.customer_id
LEFT   JOIN employee e ON e.employee_id    = c.support_rep_id
GROUP  BY c.customer_id, c.first_name, c.last_name,
          c.country, c.email, e.first_name, e.last_name;

COMMENT ON VIEW vw_invoice_summary IS
    'Per-customer revenue summary with support rep and purchase history';


-- ============================================================
-- View : vw_track_catalog
-- Purpose: Full denormalized track catalog for reporting
-- ============================================================

CREATE OR REPLACE VIEW vw_track_catalog AS
SELECT
    t.track_id,
    t.name               AS track_name,
    al.title             AS album_title,
    ar.name              AS artist_name,
    g.name               AS genre,
    mt.name              AS media_type,
    t.composer,
    t.milliseconds,
    ROUND(t.milliseconds / 60000.0, 2)   AS duration_minutes,
    t.bytes,
    t.unit_price
FROM   track    t
JOIN   album    al ON al.album_id      = t.album_id
JOIN   artist   ar ON ar.artist_id     = al.artist_id
JOIN   mediatype mt ON mt.media_type_id = t.media_type_id
LEFT   JOIN genre g ON g.genre_id      = t.genre_id;

COMMENT ON VIEW vw_track_catalog IS
    'Denormalized view of the full track catalog for query convenience';


-- ============================================================
-- View : vw_department_headcount
-- Purpose: Employee count and manager per department
-- ============================================================

CREATE OR REPLACE VIEW vw_department_headcount AS
SELECT
    department,
    COUNT(*)                                                    AS headcount,
    STRING_AGG(first_name || ' ' || last_name, ', ' ORDER BY hire_date) AS employees
FROM   employee
WHERE  department IS NOT NULL
GROUP  BY department
ORDER  BY headcount DESC;

COMMENT ON VIEW vw_department_headcount IS
    'Headcount and employee list per department';
