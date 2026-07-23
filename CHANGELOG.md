# Changelog

All notable changes to this project are documented here.

## [Unreleased]

## [1.0.0] — 2026-07-23

### Added
- Full industrial-level folder structure for PostgreSQL DevOps pipeline
- Modular PowerShell scripts: validate, setup-database, deploy-migrations, deploy-objects, deploy-seeds, rollback, test-connection, run-tests
- Shared utility modules: logger.ps1, common.ps1
- Master build orchestrator: scripts/build/build.ps1
- Versioned migration system with schema_migrations tracking table (V001–V003)
- Complete Chinook database schema (11 tables, indexes, foreign keys)
- Sample seed data (15 artists, 30 tracks, 10 customers, 10 invoices, etc.)
- Stored procedure: employee_dj
- Functions: get_employee_count, get_customer_total_spend, get_top_tracks
- Views: vw_invoice_summary, vw_track_catalog, vw_department_headcount
- Rollback scripts: R002, R003
- Unit and integration SQL test suites
- Jenkins pipeline with 7 stages and full parameter support
- Environment config files (dev.env committed; staging/prod templates only)
- Comprehensive BUILD_PROCESS.md documentation
