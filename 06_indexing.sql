-- File 06: Indexing (Objective 4)   (run after 03_bulk_data.sql)
-- NOTE: foreign keys already create single-column indexes (e.g. on source,
-- destination, flight_id). So the "before" plan may use those; compare
-- type / key / rows against the composite index in the "after" plan.
USE flight_reservation;
SHOW INDEX FROM flights;
SHOW INDEX FROM bookings;

-- ===== 6.1 Flight search path: (source, destination, departure_datetime) =====
-- BEFORE
EXPLAIN SELECT flight_id, flight_no, departure_datetime
FROM flights
WHERE source='DEL' AND destination='BOM'
  AND departure_datetime >= '2026-11-10' AND departure_datetime < '2026-11-20';

CREATE INDEX idx_flight_search ON flights (source, destination, departure_datetime);

-- AFTER (same query)
EXPLAIN SELECT flight_id, flight_no, departure_datetime
FROM flights
WHERE source='DEL' AND destination='BOM'
  AND departure_datetime >= '2026-11-10' AND departure_datetime < '2026-11-20';

-- Query where the composite index is NOT used (leading column 'source' missing,
-- and a function wrapped around the date column)
EXPLAIN SELECT * FROM flights WHERE DATE(departure_datetime) = '2026-11-15';

-- ===== 6.2 Booking lookup: (flight_id, seat_no, booking_status) =====
-- BEFORE
EXPLAIN SELECT booking_id, passenger_id FROM bookings
WHERE flight_id=1500 AND seat_no='3C' AND booking_status='CONFIRMED';

CREATE INDEX idx_booking_lookup ON bookings (flight_id, seat_no, booking_status);

-- AFTER (same query)
EXPLAIN SELECT booking_id, passenger_id FROM bookings
WHERE flight_id=1500 AND seat_no='3C' AND booking_status='CONFIRMED';

-- NOT used: filter on a non-leading column only (low selectivity as well)
EXPLAIN SELECT * FROM bookings WHERE booking_status='CONFIRMED';
EXPLAIN SELECT * FROM bookings WHERE seat_no='3C';
