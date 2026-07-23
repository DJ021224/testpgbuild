-- ============================================================
-- Rollback : R002
-- Reverts  : V002__create_chinook_schema.sql
-- WARNING  : This drops all Chinook tables and ALL their data.
--            Run only when explicitly rolling back migration V002.
-- ============================================================

DROP TABLE IF EXISTS playlisttrack  CASCADE;
DROP TABLE IF EXISTS playlist       CASCADE;
DROP TABLE IF EXISTS invoiceline    CASCADE;
DROP TABLE IF EXISTS invoice        CASCADE;
DROP TABLE IF EXISTS customer       CASCADE;
DROP TABLE IF EXISTS employee       CASCADE;
DROP TABLE IF EXISTS track          CASCADE;
DROP TABLE IF EXISTS album          CASCADE;
DROP TABLE IF EXISTS artist         CASCADE;
DROP TABLE IF EXISTS mediatype      CASCADE;
DROP TABLE IF EXISTS genre          CASCADE;

RAISE NOTICE 'R002: All Chinook schema tables dropped.';
