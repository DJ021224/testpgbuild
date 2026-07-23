-- ============================================================
-- Migration : V002
-- Purpose   : Create full Chinook database schema
--             (digital media store sample database)
-- Tables    : Genre, MediaType, Artist, Album, Track,
--             Employee, Customer, Invoice, InvoiceLine,
--             Playlist, PlaylistTrack
-- ============================================================

-- Genre --------------------------------------------------------
CREATE TABLE IF NOT EXISTS genre (
    genre_id   SERIAL       PRIMARY KEY,
    name       VARCHAR(120) NOT NULL
);
COMMENT ON TABLE genre IS 'Music genres (Rock, Jazz, Classical, etc.)';

-- MediaType ----------------------------------------------------
CREATE TABLE IF NOT EXISTS mediatype (
    media_type_id SERIAL       PRIMARY KEY,
    name          VARCHAR(120) NOT NULL
);
COMMENT ON TABLE mediatype IS 'Audio/video media formats';

-- Artist -------------------------------------------------------
CREATE TABLE IF NOT EXISTS artist (
    artist_id SERIAL       PRIMARY KEY,
    name      VARCHAR(120) NOT NULL
);
COMMENT ON TABLE artist IS 'Music artists / bands';

-- Album --------------------------------------------------------
CREATE TABLE IF NOT EXISTS album (
    album_id  SERIAL       PRIMARY KEY,
    title     VARCHAR(160) NOT NULL,
    artist_id INTEGER      NOT NULL REFERENCES artist(artist_id) ON DELETE CASCADE
);
COMMENT ON TABLE album IS 'Music albums released by artists';

-- Track --------------------------------------------------------
CREATE TABLE IF NOT EXISTS track (
    track_id      SERIAL          PRIMARY KEY,
    name          VARCHAR(200)    NOT NULL,
    album_id      INTEGER         REFERENCES album(album_id) ON DELETE SET NULL,
    media_type_id INTEGER         NOT NULL REFERENCES mediatype(media_type_id),
    genre_id      INTEGER         REFERENCES genre(genre_id),
    composer      VARCHAR(220),
    milliseconds  INTEGER         NOT NULL CHECK (milliseconds > 0),
    bytes         INTEGER,
    unit_price    NUMERIC(10, 2)  NOT NULL CHECK (unit_price >= 0)
);
COMMENT ON TABLE track IS 'Individual music tracks within albums';

-- Employee -----------------------------------------------------
CREATE TABLE IF NOT EXISTS employee (
    employee_id SERIAL       PRIMARY KEY,
    last_name   VARCHAR(20)  NOT NULL,
    first_name  VARCHAR(20)  NOT NULL,
    title       VARCHAR(30),
    department  VARCHAR(50),
    reports_to  INTEGER      REFERENCES employee(employee_id),
    birth_date  TIMESTAMPTZ,
    hire_date   TIMESTAMPTZ,
    address     VARCHAR(70),
    city        VARCHAR(40),
    state       VARCHAR(40),
    country     VARCHAR(40),
    postal_code VARCHAR(10),
    phone       VARCHAR(24),
    fax         VARCHAR(24),
    email       VARCHAR(60)
);
COMMENT ON TABLE  employee            IS 'Store employees including sales support agents';
COMMENT ON COLUMN employee.department IS 'Functional department (Sales, IT, HR, Finance, Operations)';

-- Customer -----------------------------------------------------
CREATE TABLE IF NOT EXISTS customer (
    customer_id   SERIAL       PRIMARY KEY,
    first_name    VARCHAR(40)  NOT NULL,
    last_name     VARCHAR(20)  NOT NULL,
    company       VARCHAR(80),
    address       VARCHAR(70),
    city          VARCHAR(40),
    state         VARCHAR(40),
    country       VARCHAR(40),
    postal_code   VARCHAR(10),
    phone         VARCHAR(24),
    fax           VARCHAR(24),
    email         VARCHAR(60)  NOT NULL,
    support_rep_id INTEGER     REFERENCES employee(employee_id)
);
COMMENT ON TABLE customer IS 'Store customers who purchase digital media';

-- Invoice ------------------------------------------------------
CREATE TABLE IF NOT EXISTS invoice (
    invoice_id       SERIAL         PRIMARY KEY,
    customer_id      INTEGER        NOT NULL REFERENCES customer(customer_id),
    invoice_date     TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    billing_address  VARCHAR(70),
    billing_city     VARCHAR(40),
    billing_state    VARCHAR(40),
    billing_country  VARCHAR(40),
    billing_postal   VARCHAR(10),
    total            NUMERIC(10, 2) NOT NULL CHECK (total >= 0)
);
COMMENT ON TABLE invoice IS 'Customer purchase invoices';

-- InvoiceLine --------------------------------------------------
CREATE TABLE IF NOT EXISTS invoiceline (
    invoice_line_id SERIAL         PRIMARY KEY,
    invoice_id      INTEGER        NOT NULL REFERENCES invoice(invoice_id) ON DELETE CASCADE,
    track_id        INTEGER        NOT NULL REFERENCES track(track_id),
    unit_price      NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    quantity        INTEGER        NOT NULL CHECK (quantity > 0)
);
COMMENT ON TABLE invoiceline IS 'Individual line items on each invoice';

-- Playlist -----------------------------------------------------
CREATE TABLE IF NOT EXISTS playlist (
    playlist_id SERIAL       PRIMARY KEY,
    name        VARCHAR(120) NOT NULL
);
COMMENT ON TABLE playlist IS 'Customer-curated or system playlists';

-- PlaylistTrack (junction) ------------------------------------
CREATE TABLE IF NOT EXISTS playlisttrack (
    playlist_id INTEGER NOT NULL REFERENCES playlist(playlist_id) ON DELETE CASCADE,
    track_id    INTEGER NOT NULL REFERENCES track(track_id)       ON DELETE CASCADE,
    PRIMARY KEY (playlist_id, track_id)
);
COMMENT ON TABLE playlisttrack IS 'Many-to-many mapping of tracks to playlists';
