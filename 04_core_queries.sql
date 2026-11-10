-- File 04: Core queries (Objective 2). Uses the 9 hand-written flights.
USE flight_reservation;

-- 4.1 Seat availability per flight
SELECT f.flight_id, f.flight_no, f.source, f.destination, a.total_seats,
       COUNT(CASE WHEN b.booking_status='CONFIRMED' THEN 1 END) AS seats_booked,
       a.total_seats - COUNT(CASE WHEN b.booking_status='CONFIRMED' THEN 1 END) AS seats_available
FROM flights f
JOIN aircraft a ON a.aircraft_id = f.aircraft_id
LEFT JOIN bookings b ON b.flight_id = f.flight_id
WHERE f.flight_id BETWEEN 1 AND 9
GROUP BY f.flight_id, f.flight_no, f.source, f.destination, a.total_seats
ORDER BY f.flight_id;

-- 4.1b Is a specific seat free?
SELECT IF(COUNT(*)=0,'FREE','TAKEN') AS seat_12D_on_flight_1
FROM bookings WHERE flight_id=1 AND seat_no='12D' AND booking_status='CONFIRMED';

-- 4.2 Booking status: counts per flight and status
SELECT flight_id, booking_status, COUNT(*) AS total
FROM bookings WHERE flight_id BETWEEN 1 AND 9
GROUP BY flight_id, booking_status ORDER BY flight_id, booking_status;

-- 4.2b Passenger itinerary with status
SELECT p.full_name, lt.tier_name, f.flight_no, f.source, f.destination,
       f.departure_datetime, fc.class_name, b.seat_no, b.booking_status
FROM bookings b
JOIN passengers p     ON p.passenger_id = b.passenger_id
JOIN loyalty_tiers lt ON lt.tier_id = p.tier_id
JOIN flights f        ON f.flight_id = b.flight_id
JOIN fare_classes fc  ON fc.class_id = b.class_id
WHERE p.passenger_id = 1;

-- 4.3 Flight cancellation (flight 8): before, cancel in a transaction, after
SELECT f.flight_id, f.flight_status, b.booking_status, COUNT(*) AS total
FROM flights f JOIN bookings b ON b.flight_id=f.flight_id
WHERE f.flight_id=8 GROUP BY f.flight_id, f.flight_status, b.booking_status;

START TRANSACTION;
UPDATE flights  SET flight_status='CANCELLED' WHERE flight_id=8;
UPDATE bookings SET booking_status='CANCELLED', seat_no=NULL
WHERE flight_id=8 AND booking_status IN ('CONFIRMED','WAITLISTED');
COMMIT;

SELECT f.flight_id, f.flight_status, b.booking_status, COUNT(*) AS total
FROM flights f JOIN bookings b ON b.flight_id=f.flight_id
WHERE f.flight_id=8 GROUP BY f.flight_id, f.flight_status, b.booking_status;
COMMIT;
