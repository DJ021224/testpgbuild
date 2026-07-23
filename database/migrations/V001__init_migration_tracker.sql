-- ============================================================
-- Migration : V001
-- Purpose   : Bootstrap schema_migrations tracking table
-- Note      : This table tracks all applied migrations.
--             It is created by setup-database.ps1 but is
--             included here as a migration so it is versioned.
-- ============================================================

CREATE TABLE IF NOT EXISTS schema_migrations (
    version        VARCHAR(30)  NOT NULL PRIMARY KEY,
    description    VARCHAR(200) NOT NULL,
    script_name    VARCHAR(300) NOT NULL,
    applied_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    applied_by     VARCHAR(100) NOT NULL DEFAULT CURRENT_USER,
    execution_ms   INTEGER,
    checksum       VARCHAR(64)
);

COMMENT ON TABLE  schema_migrations IS 'Tracks all applied database migration versions';
COMMENT ON COLUMN schema_migrations.version      IS 'Zero-padded version number extracted from filename';
COMMENT ON COLUMN schema_migrations.checksum     IS 'MD5 hash of the SQL file at application time';
