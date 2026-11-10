-- File 07: Views (Objective 5)   (run after 05_overbooking.sql)
USE flight_reservation;

-- 7.1 Flight occupancy view
-- NOT updatable: uses GROUP BY, aggregate functions and joins.
CREATE OR REPLACE VIEW v_flight_occupancy AS
SELECT f.flight_id, f.flight_no, f.source, f.destination, f.departure_datetime,
       a.total_seats,
       COUNT(b.booking_id)                                   AS seats_booked,
       a.total_seats - COUNT(b.booking_id)                   AS seats_available,
       ROUND(100 * COUNT(b.booking_id) / a.total_seats, 2)   AS occupancy_pct
FROM flights f
JOIN aircraft a ON a.aircraft_id = f.aircraft_id
LEFT JOIN bookings b ON b.flight_id = f.flight_id AND b.booking_status = 'CONFIRMED'
GROUP BY f.flight_id, f.flight_no, f.source, f.destination, f.departure_datetime, a.total_seats;

SELECT * FROM v_flight_occupancy WHERE flight_id BETWEEN 1 AND 9;

-- Proof it is not updatable (expect error 1288)
UPDATE v_flight_occupancy SET seats_booked = 0 WHERE flight_id = 1;

-- 7.2 Waitlisted / overbooked (offloaded) passengers, by loyalty tier then fare class
-- Multi-table join view: only columns from ONE base table can be updated through it
-- (no GROUP BY / DISTINCT / aggregates), so it is partially updatable.
CREATE OR REPLACE VIEW v_waitlisted_passengers AS
SELECT b.booking_id, b.flight_id, f.flight_no, p.full_name,
       lt.tier_name, fc.class_name, b.booking_status, b.booking_timestamp
FROM bookings b
JOIN passengers p     ON p.passenger_id = b.passenger_id
JOIN loyalty_tiers lt ON lt.tier_id     = p.tier_id
JOIN fare_classes fc  ON fc.class_id    = b.class_id
JOIN flights f        ON f.flight_id    = b.flight_id
WHERE b.booking_status IN ('WAITLISTED','OFFLOADED')
ORDER BY lt.priority_rank, fc.priority_rank, b.booking_timestamp;

SELECT * FROM v_waitlisted_passengers WHERE flight_id BETWEEN 1 AND 9;

-- 7.3 WITH CHECK OPTION on an updatable (single-table, no aggregate) view
CREATE OR REPLACE VIEW v_confirmed_bookings AS
SELECT booking_id, flight_id, passenger_id, class_id, seat_no, booking_status, booking_timestamp, fare_paid
FROM bookings
WHERE booking_status = 'CONFIRMED'
WITH CHECK OPTION;

-- accepted: row satisfies booking_status = 'CONFIRMED'
INSERT INTO v_confirmed_bookings (flight_id, passenger_id, class_id, seat_no, booking_status, booking_timestamp, fare_paid)
VALUES (1, 12, 3, '30F', 'CONFIRMED', '2026-10-24 12:00:00', 5500);
SELECT * FROM bookings WHERE flight_id=1 AND seat_no='30F';

-- rejected: the changed row would leave the view (expect error 1369)
UPDATE v_confirmed_bookings SET booking_status = 'CANCELLED' WHERE flight_id=1 AND seat_no='30F';

-- clean up the demo row
DELETE FROM bookings WHERE flight_id=1 AND seat_no='30F';
