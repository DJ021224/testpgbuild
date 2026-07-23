-- ============================================================
-- Migration : V003
-- Purpose   : Create performance indexes for all Chinook tables
-- ============================================================

-- Album
CREATE INDEX IF NOT EXISTS idx_album_artist_id  ON album(artist_id);

-- Track
CREATE INDEX IF NOT EXISTS idx_track_album_id       ON track(album_id);
CREATE INDEX IF NOT EXISTS idx_track_genre_id        ON track(genre_id);
CREATE INDEX IF NOT EXISTS idx_track_media_type_id   ON track(media_type_id);

-- Employee
CREATE INDEX IF NOT EXISTS idx_employee_reports_to   ON employee(reports_to);
CREATE INDEX IF NOT EXISTS idx_employee_department    ON employee(department);

-- Customer
CREATE INDEX IF NOT EXISTS idx_customer_support_rep  ON customer(support_rep_id);
CREATE INDEX IF NOT EXISTS idx_customer_country       ON customer(country);

-- Invoice
CREATE INDEX IF NOT EXISTS idx_invoice_customer_id   ON invoice(customer_id);
CREATE INDEX IF NOT EXISTS idx_invoice_date           ON invoice(invoice_date);

-- InvoiceLine
CREATE INDEX IF NOT EXISTS idx_invoiceline_invoice_id ON invoiceline(invoice_id);
CREATE INDEX IF NOT EXISTS idx_invoiceline_track_id   ON invoiceline(track_id);

-- PlaylistTrack
CREATE INDEX IF NOT EXISTS idx_playlisttrack_track_id ON playlisttrack(track_id);
