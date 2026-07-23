-- ============================================================
-- Rollback : R003
-- Reverts  : V003__create_indexes.sql
-- ============================================================

DROP INDEX IF EXISTS idx_album_artist_id;
DROP INDEX IF EXISTS idx_track_album_id;
DROP INDEX IF EXISTS idx_track_genre_id;
DROP INDEX IF EXISTS idx_track_media_type_id;
DROP INDEX IF EXISTS idx_employee_reports_to;
DROP INDEX IF EXISTS idx_employee_department;
DROP INDEX IF EXISTS idx_customer_support_rep;
DROP INDEX IF EXISTS idx_customer_country;
DROP INDEX IF EXISTS idx_invoice_customer_id;
DROP INDEX IF EXISTS idx_invoice_date;
DROP INDEX IF EXISTS idx_invoiceline_invoice_id;
DROP INDEX IF EXISTS idx_invoiceline_track_id;
DROP INDEX IF EXISTS idx_playlisttrack_track_id;

RAISE NOTICE 'R003: All Chinook performance indexes dropped.';
