-- ============================================================
-- Seed File : 01_chinook_sample_data.sql
-- Purpose   : Insert sample data for the Chinook digital media
--             store database. Safe to run — uses INSERT ...
--             ON CONFLICT DO NOTHING.
-- ============================================================

-- ── Genre ────────────────────────────────────────────────────
INSERT INTO genre (genre_id, name) VALUES
  (1,  'Rock'),
  (2,  'Jazz'),
  (3,  'Metal'),
  (4,  'Alternative & Punk'),
  (5,  'Classical'),
  (6,  'Blues'),
  (7,  'Latin'),
  (8,  'Reggae'),
  (9,  'Pop'),
  (10, 'Hip Hop/Rap')
ON CONFLICT (genre_id) DO NOTHING;

SELECT setval('genre_genre_id_seq', (SELECT MAX(genre_id) FROM genre));

-- ── MediaType ────────────────────────────────────────────────
INSERT INTO mediatype (media_type_id, name) VALUES
  (1, 'MPEG audio file'),
  (2, 'Protected AAC audio file'),
  (3, 'Protected MPEG-4 video file'),
  (4, 'Purchased AAC audio file'),
  (5, 'AAC audio file')
ON CONFLICT (media_type_id) DO NOTHING;

SELECT setval('mediatype_media_type_id_seq', (SELECT MAX(media_type_id) FROM mediatype));

-- ── Artist ───────────────────────────────────────────────────
INSERT INTO artist (artist_id, name) VALUES
  (1,  'AC/DC'),
  (2,  'Accept'),
  (3,  'Aerosmith'),
  (4,  'Alanis Morissette'),
  (5,  'Alice In Chains'),
  (6,  'Antônio Carlos Jobim'),
  (7,  'Apocalyptica'),
  (8,  'Audioslave'),
  (9,  'BackBeat'),
  (10, 'Billy Cobham'),
  (11, 'Black Label Society'),
  (12, 'Black Sabbath'),
  (13, 'Body Count'),
  (14, 'Bruce Dickinson'),
  (15, 'Buddy Guy')
ON CONFLICT (artist_id) DO NOTHING;

SELECT setval('artist_artist_id_seq', (SELECT MAX(artist_id) FROM artist));

-- ── Album ────────────────────────────────────────────────────
INSERT INTO album (album_id, title, artist_id) VALUES
  (1,  'For Those About To Rock We Salute You', 1),
  (2,  'Balls to the Wall',                     2),
  (3,  'Restless and Wild',                     2),
  (4,  'Let There Be Rock',                     1),
  (5,  'Big Ones',                              3),
  (6,  'Jagged Little Pill',                    4),
  (7,  'Facelift',                              5),
  (8,  'Warner 25 Anos',                        6),
  (9,  'Plays Metallica By Four Cellos',        7),
  (10, 'Audioslave',                            8),
  (11, 'Out Of Exile',                          8),
  (12, 'BackBeat Soundtrack',                   9),
  (13, 'The Best Of Billy Cobham',              10),
  (14, 'Alcohol Fueled Brewtality Live! [Disc 1]', 11),
  (15, 'Black Sabbath Vol. 4 [Disc 1]',        12)
ON CONFLICT (album_id) DO NOTHING;

SELECT setval('album_album_id_seq', (SELECT MAX(album_id) FROM album));

-- ── Track ────────────────────────────────────────────────────
INSERT INTO track (track_id, name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price) VALUES
  (1,  'For Those About To Rock (We Salute You)', 1,  1, 1,  'Angus Young, Malcolm Young, Brian Johnson', 343719, 11170334, 0.99),
  (2,  'Balls to the Wall',                       2,  2, 1,  NULL,                                         342562, 5510424,  0.99),
  (3,  'Fast As a Shark',                         3,  2, 1,  'F. Baltes, S. Kaufman, U. Dirkscneider & W. Hoffman', 230619, 3990994, 0.99),
  (4,  'Restless and Wild',                       3,  2, 1,  'F. Baltes, R.A. Smith-Diesel, S. Kaufman, U. Dirkscneider & W. Hoffman', 252051, 4331779, 0.99),
  (5,  'Princess of the Dawn',                    3,  2, 1,  'Deaffy & R.A. Smith-Diesel', 375418, 6290521, 0.99),
  (6,  'Put The Finger On You',                   1,  2, 1,  'Angus Young, Malcolm Young, Brian Johnson', 205662, 6713451, 0.99),
  (7,  'Let''s Get It Up',                        1,  2, 1,  'Angus Young, Malcolm Young, Brian Johnson', 233926, 7636561, 0.99),
  (8,  'Inject The Venom',                        1,  2, 1,  'Angus Young, Malcolm Young, Brian Johnson', 210834, 6852860, 0.99),
  (9,  'Snowballed',                              1,  2, 1,  'Angus Young, Malcolm Young, Brian Johnson', 203102, 6599424, 0.99),
  (10, 'Evil Walks',                              1,  2, 1,  'Angus Young, Malcolm Young, Brian Johnson', 263497, 8611245, 0.99),
  (11, 'C.O.D.',                                  1,  2, 1,  'Angus Young, Malcolm Young, Brian Johnson', 199836, 6566314, 0.99),
  (12, 'Breaking The Rules',                      1,  2, 1,  'Angus Young, Malcolm Young, Brian Johnson', 263288, 8596840, 0.99),
  (13, 'Night Of The Long Knives',                1,  2, 1,  'Angus Young, Malcolm Young, Brian Johnson', 205688, 6706347, 0.99),
  (14, 'Spellbound',                              1,  2, 1,  'Angus Young, Malcolm Young, Brian Johnson', 270863, 8817038, 0.99),
  (15, 'Go Down',                                 4,  2, 1,  'AC/DC',                                     331180, 10847611, 0.99),
  (16, 'Dog Eat Dog',                             4,  2, 1,  'AC/DC',                                     215196, 7032162, 0.99),
  (17, 'Let There Be Rock',                       4,  2, 1,  'AC/DC',                                     366654, 12021261, 0.99),
  (18, 'Bad Boy Boogie',                          4,  2, 1,  'AC/DC',                                     267728, 8776158, 0.99),
  (19, 'Problem Child',                           4,  2, 1,  'AC/DC',                                     325041, 10617116, 0.99),
  (20, 'Overdose',                                4,  2, 1,  'AC/DC',                                     369319, 12066294, 0.99),
  (21, 'Hell Ain''t A Bad Place To Be',           4,  2, 1,  'AC/DC',                                     254380, 8331286, 0.99),
  (22, 'Whole Lotta Rosie',                       4,  2, 1,  'AC/DC',                                     323761, 10547154, 0.99),
  (23, 'Walk On Water',                           5,  2, 1,  'Steven Tyler, Joe Perry, Jack Blades, Tommy Shaw', 295680, 9719579, 0.99),
  (24, 'Love In An Elevator',                     5,  2, 1,  'Steven Tyler, Joe Perry',                   321828, 10552051, 0.99),
  (25, 'Rag Doll',                                5,  2, 1,  'Steven Tyler, Joe Perry, Jim Vallance, Holly Knight', 264698, 8675345, 0.99),
  (26, 'All I Needed',                            6,  2, 4,  'Alanis Morissette',                         234519, 7736289, 0.99),
  (27, 'Hand In My Pocket',                       6,  2, 4,  'Alanis Morissette, Glen Ballard',           221398, 7248475, 0.99),
  (28, 'Right Through You',                       6,  2, 4,  'Alanis Morissette',                         176117, 5793485, 0.99),
  (29, 'Forgiven',                                6,  2, 4,  'Alanis Morissette, Glen Ballard',           300355, 9977686, 0.99),
  (30, 'You Learn',                               6,  2, 4,  'Alanis Morissette, Glen Ballard',           258630, 8543965, 0.99)
ON CONFLICT (track_id) DO NOTHING;

SELECT setval('track_track_id_seq', (SELECT MAX(track_id) FROM track));

-- ── Employee ─────────────────────────────────────────────────
INSERT INTO employee (employee_id, last_name, first_name, title, department, reports_to,
                      birth_date, hire_date, address, city, state, country, postal_code, phone, fax, email) VALUES
  (1, 'Adams',    'Andrew', 'General Manager',         'Operations', NULL,
   '1962-02-18', '2002-08-14', '11120 Jasper Ave NW', 'Edmonton', 'AB', 'Canada', 'T5K 2N1',
   '+1 (780) 428-9482', '+1 (780) 428-3457', 'andrew@chinookcorp.com'),
  (2, 'Edwards',  'Nancy',  'Sales Manager',           'Sales',      1,
   '1958-12-08', '2002-05-01', '825 8 Ave SW',        'Calgary',   'AB', 'Canada', 'T2P 2T3',
   '+1 (403) 262-3443', '+1 (403) 262-3322', 'nancy@chinookcorp.com'),
  (3, 'Peacock',  'Jane',   'Sales Support Agent',     'Sales',      2,
   '1973-08-29', '2002-04-01', '1111 6 Ave SW',       'Calgary',   'AB', 'Canada', 'T2P 5M5',
   '+1 (403) 262-3443', '+1 (403) 262-6712', 'jane@chinookcorp.com'),
  (4, 'Park',     'Margaret','Sales Support Agent',   'Sales',      2,
   '1947-09-19', '2003-05-03', '683 10 Street SW',    'Calgary',   'AB', 'Canada', 'T2P 5G3',
   '+1 (403) 263-4423', '+1 (403) 263-4289', 'margaret@chinookcorp.com'),
  (5, 'Johnson',  'Steve',  'Sales Support Agent',     'Sales',      2,
   '1965-03-03', '2003-10-17', '7727B 41 Ave',        'Calgary',   'AB', 'Canada', 'T3B 1Y7',
   '1 (780) 836-9987', '1 (780) 836-9543',  'steve@chinookcorp.com'),
  (6, 'Mitchell', 'Michael','IT Manager',              'IT',         1,
   '1973-07-01', '2003-10-17', '5827 Bowness Road NW','Calgary',  'AB', 'Canada', 'T3B 0C5',
   '+1 (403) 246-9887', '+1 (403) 246-9899', 'michael@chinookcorp.com'),
  (7, 'King',     'Robert', 'IT Staff',                'IT',         6,
   '1970-05-29', '2004-01-02', '590 Columbia Boulevard West', 'Lethbridge', 'AB', 'Canada', 'T1K 5N8',
   '+1 (403) 456-9986', '+1 (403) 456-8485', 'robert@chinookcorp.com'),
  (8, 'Callahan', 'Laura',  'IT Staff',                'IT',         6,
   '1968-01-09', '2004-03-04', '923 7 ST NW',         'Lethbridge', 'AB', 'Canada', 'T1H 1Y8',
   '+1 (403) 467-3351', '+1 (403) 467-8772', 'laura@chinookcorp.com')
ON CONFLICT (employee_id) DO NOTHING;

SELECT setval('employee_employee_id_seq', (SELECT MAX(employee_id) FROM employee));

-- ── Customer ─────────────────────────────────────────────────
INSERT INTO customer (customer_id, first_name, last_name, company, address, city, state, country, postal_code, phone, fax, email, support_rep_id) VALUES
  (1,  'Luís',      'Gonçalves',  'Embraer - Empresa Brasileira de Aeronáutica S.A.',
       'Av. Brigadeiro Faria Lima, 2170', 'São José dos Campos', 'SP', 'Brazil',    '12227-000', '+55 (12) 3923-5555', '+55 (12) 3923-5566', 'luisg@embraer.com.br', 3),
  (2,  'Leonie',    'Köhler',     NULL,
       'Theodor-Heuss-Straße 34',         'Stuttgart',            NULL, 'Germany',   '70174',     '+49 0711 2842222',  NULL,                  'leonekohler@surfeu.de', 5),
  (3,  'François',  'Tremblay',   NULL,
       '1498 rue Bélanger',               'Montréal',             'QC', 'Canada',    'H2G 1A7',   '+1 (514) 721-4711', '+1 (514) 721-4712',   'ftremblay@gmail.com', 3),
  (4,  'Bjørn',     'Hansen',     NULL,
       'Ullevålsveien 14',                'Oslo',                 NULL, 'Norway',    '0171',      '+47 22 44 22 22',   NULL,                  'bjorn.hansen@yahoo.no', 4),
  (5,  'František', 'Wichterlová','JetBrains s.r.o.',
       'Klanova 9/506',                   'Prague',               NULL, 'Czech Republic', '14700', '+420 2 4172 5555', '+420 2 4172 5555',    'frantisekw@jetbrains.com', 4),
  (6,  'Helena',    'Holý',       NULL,
       'Rilská 3174/6',                   'Prague',               NULL, 'Czech Republic', '14300', '+420 2 4177 0449', NULL,                  'hholy@gmail.com', 5),
  (7,  'Astrid',    'Gruber',     NULL,
       'Rotenturmstraße 4, 1010 Innere Stadt', 'Vienne',          NULL, 'Austria',   '1010',      '+43 01 5134505',    NULL,                  'astridgruber@apple.at', 5),
  (8,  'Daan',      'Peeters',    NULL,
       'Grétrystraat 63',                 'Brussels',             NULL, 'Belgium',   '1000',      '+32 02 219 03 03',  NULL,                  'daan_peeters@apple.be', 4),
  (9,  'Kara',      'Nielsen',    NULL,
       'Sønder Boulevard 51',             'Copenhagen',           NULL, 'Denmark',   '1720',      '+453 3331 9991',    NULL,                  'kara.nielsen@jubii.dk', 4),
  (10, 'Eduardo',   'Martins',    'Woodstock Discos',
       'Rua Dr. Falcão Filho, 155',       'São Paulo',            'SP', 'Brazil',    '01007-010', '+55 (11) 3033-5446', '+55 (11) 3033-4564', 'eduardo@woodstock.com.br', 3)
ON CONFLICT (customer_id) DO NOTHING;

SELECT setval('customer_customer_id_seq', (SELECT MAX(customer_id) FROM customer));

-- ── Invoice ──────────────────────────────────────────────────
INSERT INTO invoice (invoice_id, customer_id, invoice_date, billing_address, billing_city, billing_state, billing_country, billing_postal, total) VALUES
  (1,  2,  '2021-01-01', 'Theodor-Heuss-Straße 34',            'Stuttgart',            NULL, 'Germany',        '70174',     1.98),
  (2,  4,  '2021-01-02', 'Ullevålsveien 14',                   'Oslo',                 NULL, 'Norway',         '0171',      3.96),
  (3,  8,  '2021-01-03', 'Grétrystraat 63',                    'Brussels',             NULL, 'Belgium',        '1000',      5.94),
  (4,  14, '2021-02-11', '8210 111 ST NW',                     'Edmonton',             'AB', 'Canada',         'T6G 2C7',   8.91),
  (5,  23, '2021-02-11', '69 Salem Street',                    'Boston',               'MA', 'USA',            '2113',      13.86),
  (6,  37, '2021-02-11', 'Berger Straße 10',                   'Frankfurt',            NULL, 'Germany',        '60316',     0.99),
  (7,  38, '2021-02-11', 'Barbarossastraße 19',                'Berlin',               NULL, 'Germany',        '10779',     1.98),
  (8,  40, '2021-02-11', '8, Rue Hanovre',                     'Paris',                NULL, 'France',         '75002',     1.98),
  (9,  6,  '2021-04-01', 'Rilská 3174/6',                      'Prague',               NULL, 'Czech Republic', '14300',     3.96),
  (10, 1,  '2021-04-15', 'Av. Brigadeiro Faria Lima, 2170',   'São José dos Campos',  'SP', 'Brazil',         '12227-000', 5.94)
ON CONFLICT (invoice_id) DO NOTHING;

SELECT setval('invoice_invoice_id_seq', (SELECT MAX(invoice_id) FROM invoice));

-- ── InvoiceLine ──────────────────────────────────────────────
INSERT INTO invoiceline (invoice_line_id, invoice_id, track_id, unit_price, quantity) VALUES
  (1,  1,  2,  0.99, 1),
  (2,  1,  4,  0.99, 1),
  (3,  2,  6,  0.99, 1),
  (4,  2,  8,  0.99, 1),
  (5,  2,  10, 0.99, 1),
  (6,  2,  12, 0.99, 1),
  (7,  3,  16, 0.99, 1),
  (8,  3,  20, 0.99, 1),
  (9,  3,  24, 0.99, 1),
  (10, 3,  28, 0.99, 1),
  (11, 3,  2,  0.99, 1),
  (12, 3,  4,  0.99, 1),
  (13, 4,  6,  0.99, 1),
  (14, 4,  8,  0.99, 1),
  (15, 4,  10, 0.99, 1),
  (16, 4,  12, 0.99, 1),
  (17, 4,  14, 0.99, 1),
  (18, 4,  16, 0.99, 1),
  (19, 4,  18, 0.99, 1),
  (20, 4,  20, 0.99, 1),
  (21, 4,  22, 0.99, 1),
  (22, 5,  1,  0.99, 1),
  (23, 5,  3,  0.99, 1),
  (24, 5,  5,  0.99, 1),
  (25, 6,  7,  0.99, 1),
  (26, 7,  9,  0.99, 1),
  (27, 7,  11, 0.99, 1),
  (28, 8,  13, 0.99, 1),
  (29, 8,  15, 0.99, 1),
  (30, 9,  17, 0.99, 1),
  (31, 9,  19, 0.99, 1),
  (32, 9,  21, 0.99, 1),
  (33, 9,  23, 0.99, 1),
  (34, 10, 25, 0.99, 1),
  (35, 10, 27, 0.99, 1),
  (36, 10, 29, 0.99, 1),
  (37, 10, 1,  0.99, 1),
  (38, 10, 3,  0.99, 1),
  (39, 10, 5,  0.99, 1)
ON CONFLICT (invoice_line_id) DO NOTHING;

SELECT setval('invoiceline_invoice_line_id_seq', (SELECT MAX(invoice_line_id) FROM invoiceline));

-- ── Playlist ─────────────────────────────────────────────────
INSERT INTO playlist (playlist_id, name) VALUES
  (1, 'Music'),
  (2, 'Movies'),
  (3, 'TV Shows'),
  (4, 'Audiobooks'),
  (5, 'Rock Classics')
ON CONFLICT (playlist_id) DO NOTHING;

SELECT setval('playlist_playlist_id_seq', (SELECT MAX(playlist_id) FROM playlist));

-- ── PlaylistTrack ────────────────────────────────────────────
INSERT INTO playlisttrack (playlist_id, track_id) VALUES
  (1, 1),(1, 2),(1, 3),(1, 4),(1, 5),
  (1, 6),(1, 7),(1, 8),(1, 9),(1, 10),
  (5, 1),(5, 2),(5, 3),(5, 4),(5, 6),
  (5, 7),(5, 15),(5, 16),(5, 17),(5, 22)
ON CONFLICT (playlist_id, track_id) DO NOTHING;
