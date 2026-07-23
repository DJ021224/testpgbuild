-- ============================================================
-- Test Suite : Integration — Data Integrity & Relationships
-- ============================================================

DO $$
DECLARE
    v_count   BIGINT;
    v_orphans BIGINT;
BEGIN

    -- Test 1: All core tables have data
    SELECT COUNT(*) INTO v_count FROM genre;
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: genre table is empty'; END IF;
    RAISE NOTICE 'PASS: genre has % rows', v_count;

    SELECT COUNT(*) INTO v_count FROM artist;
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: artist table is empty'; END IF;
    RAISE NOTICE 'PASS: artist has % rows', v_count;

    SELECT COUNT(*) INTO v_count FROM track;
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: track table is empty'; END IF;
    RAISE NOTICE 'PASS: track has % rows', v_count;

    SELECT COUNT(*) INTO v_count FROM employee;
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: employee table is empty'; END IF;
    RAISE NOTICE 'PASS: employee has % rows', v_count;

    SELECT COUNT(*) INTO v_count FROM customer;
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: customer table is empty'; END IF;
    RAISE NOTICE 'PASS: customer has % rows', v_count;

    SELECT COUNT(*) INTO v_count FROM invoice;
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: invoice table is empty'; END IF;
    RAISE NOTICE 'PASS: invoice has % rows', v_count;

    SELECT COUNT(*) INTO v_count FROM invoiceline;
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: invoiceline table is empty'; END IF;
    RAISE NOTICE 'PASS: invoiceline has % rows', v_count;

    -- Test 2: No orphaned albums (album must reference valid artist)
    SELECT COUNT(*) INTO v_orphans
    FROM   album al
    WHERE  NOT EXISTS (SELECT 1 FROM artist WHERE artist_id = al.artist_id);
    IF v_orphans > 0 THEN
        RAISE EXCEPTION 'FAIL: % orphaned album(s) with no artist', v_orphans;
    END IF;
    RAISE NOTICE 'PASS: No orphaned albums';

    -- Test 3: No orphaned tracks (track must reference valid album or be single)
    SELECT COUNT(*) INTO v_orphans
    FROM   track t
    WHERE  t.album_id IS NOT NULL
      AND  NOT EXISTS (SELECT 1 FROM album WHERE album_id = t.album_id);
    IF v_orphans > 0 THEN
        RAISE EXCEPTION 'FAIL: % orphaned track(s) with invalid album_id', v_orphans;
    END IF;
    RAISE NOTICE 'PASS: No orphaned tracks';

    -- Test 4: No invoiceline references a missing track
    SELECT COUNT(*) INTO v_orphans
    FROM   invoiceline il
    WHERE  NOT EXISTS (SELECT 1 FROM track WHERE track_id = il.track_id);
    IF v_orphans > 0 THEN
        RAISE EXCEPTION 'FAIL: % invoiceline row(s) reference missing tracks', v_orphans;
    END IF;
    RAISE NOTICE 'PASS: No invoiceline orphans';

    -- Test 5: Invoice totals are all positive
    SELECT COUNT(*) INTO v_count FROM invoice WHERE total <= 0;
    IF v_count > 0 THEN
        RAISE EXCEPTION 'FAIL: % invoice(s) with zero or negative total', v_count;
    END IF;
    RAISE NOTICE 'PASS: All invoice totals are positive';

    -- Test 6: vw_invoice_summary returns rows
    SELECT COUNT(*) INTO v_count FROM vw_invoice_summary;
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: vw_invoice_summary returned no rows'; END IF;
    RAISE NOTICE 'PASS: vw_invoice_summary has % rows', v_count;

    -- Test 7: vw_track_catalog returns rows
    SELECT COUNT(*) INTO v_count FROM vw_track_catalog;
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: vw_track_catalog returned no rows'; END IF;
    RAISE NOTICE 'PASS: vw_track_catalog has % rows', v_count;

    -- Test 8: get_top_tracks returns results
    SELECT COUNT(*) INTO v_count FROM get_top_tracks(5);
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: get_top_tracks(5) returned no rows'; END IF;
    RAISE NOTICE 'PASS: get_top_tracks(5) returned % rows', v_count;

    -- Test 9: schema_migrations has entries
    SELECT COUNT(*) INTO v_count FROM schema_migrations;
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: schema_migrations has no entries'; END IF;
    RAISE NOTICE 'PASS: schema_migrations has % entry/entries', v_count;

    -- Test 10: employee department column is populated
    SELECT COUNT(*) INTO v_count FROM employee WHERE department IS NOT NULL;
    IF v_count = 0 THEN RAISE EXCEPTION 'FAIL: No employees have a department set'; END IF;
    RAISE NOTICE 'PASS: % employee(s) have a department', v_count;

    RAISE NOTICE '========== INTEGRATION TESTS COMPLETE ==========';
END;
$$;
