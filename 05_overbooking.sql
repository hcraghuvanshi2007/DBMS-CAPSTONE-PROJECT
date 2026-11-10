-- File 05: Overbooking and upgrades (Objective 3)  -- run in order
-- RULE: priority = loyalty tier (Platinum first), then fare class (First first),
--       then earliest booking time. Top <capacity> passengers keep/get seats;
--       the rest are OFFLOADED.
USE flight_reservation;

-- 5.1 Detect overbooked flights (active bookings > capacity)
SELECT f.flight_id, f.flight_no, a.total_seats,
       COUNT(*) AS active_bookings, COUNT(*) - a.total_seats AS excess
FROM flights f
JOIN aircraft a ON a.aircraft_id = f.aircraft_id
JOIN bookings b ON b.flight_id = f.flight_id AND b.booking_status IN ('CONFIRMED','WAITLISTED')
GROUP BY f.flight_id, f.flight_no, a.total_seats
HAVING COUNT(*) > a.total_seats;

-- 5.2 State BEFORE applying the rule (flight 7)
SELECT b.booking_id, p.full_name, lt.tier_name, fc.class_name, b.seat_no, b.booking_status, b.booking_timestamp
FROM bookings b
JOIN passengers p ON p.passenger_id=b.passenger_id
JOIN loyalty_tiers lt ON lt.tier_id=p.tier_id
JOIN fare_classes fc ON fc.class_id=b.class_id
WHERE b.flight_id=7 ORDER BY b.booking_status, b.booking_timestamp;

-- 5.3 Apply the rule
START TRANSACTION;
SET @cap = (SELECT a.total_seats FROM flights f JOIN aircraft a ON a.aircraft_id=f.aircraft_id WHERE f.flight_id=7);

CREATE TEMPORARY TABLE tmp_ranked AS
SELECT b.booking_id, b.seat_no,
       ROW_NUMBER() OVER (ORDER BY lt.priority_rank, fc.priority_rank, b.booking_timestamp) AS rn
FROM bookings b
JOIN passengers p ON p.passenger_id=b.passenger_id
JOIN loyalty_tiers lt ON lt.tier_id=p.tier_id
JOIN fare_classes fc ON fc.class_id=b.class_id
WHERE b.flight_id=7 AND b.booking_status IN ('CONFIRMED','WAITLISTED');

-- seats released by displaced passengers, and promoted passengers needing seats
CREATE TEMPORARY TABLE tmp_freed AS
SELECT seat_no, ROW_NUMBER() OVER (ORDER BY seat_no) AS k FROM tmp_ranked WHERE rn > @cap AND seat_no IS NOT NULL;
CREATE TEMPORARY TABLE tmp_promoted AS
SELECT booking_id, ROW_NUMBER() OVER (ORDER BY rn) AS k FROM tmp_ranked WHERE rn <= @cap AND seat_no IS NULL;

UPDATE bookings b
JOIN tmp_promoted pr ON pr.booking_id=b.booking_id
JOIN tmp_freed fr ON fr.k=pr.k
SET b.seat_no=fr.seat_no, b.booking_status='CONFIRMED';

UPDATE bookings b JOIN tmp_ranked r ON r.booking_id=b.booking_id
SET b.booking_status='OFFLOADED', b.seat_no=NULL
WHERE r.rn > @cap;
COMMIT;
DROP TEMPORARY TABLE tmp_ranked, tmp_freed, tmp_promoted;

-- 5.4 State AFTER
SELECT b.booking_id, p.full_name, lt.tier_name, fc.class_name, b.seat_no, b.booking_status
FROM bookings b
JOIN passengers p ON p.passenger_id=b.passenger_id
JOIN loyalty_tiers lt ON lt.tier_id=p.tier_id
JOIN fare_classes fc ON fc.class_id=b.class_id
WHERE b.flight_id=7 ORDER BY b.booking_status, lt.priority_rank, fc.priority_rank;

-- 5.5 Loyalty upgrade: Platinum passengers seated in Economy move to Business
UPDATE bookings b
JOIN passengers p ON p.passenger_id=b.passenger_id
SET b.class_id=2
WHERE b.flight_id=7 AND b.booking_status='CONFIRMED' AND p.tier_id=1 AND b.class_id=3;

SELECT p.full_name, lt.tier_name, fc.class_name AS class_after_upgrade, b.seat_no
FROM bookings b
JOIN passengers p ON p.passenger_id=b.passenger_id
JOIN loyalty_tiers lt ON lt.tier_id=p.tier_id
JOIN fare_classes fc ON fc.class_id=b.class_id
WHERE b.flight_id=7 AND b.booking_status='CONFIRMED' AND p.tier_id=1;
