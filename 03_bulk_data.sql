-- =====================================================================
-- File 03: Bulk data (deterministic, no RAND) so EXPLAIN shows real
-- differences.  Adds 600 passengers, 3000 flights, ~36,000 bookings.
-- Run AFTER 02_sample_data.sql.  Takes a few seconds.
-- =====================================================================
USE flight_reservation;
SET SESSION cte_max_recursion_depth = 10000;

INSERT INTO passengers (full_name,email,phone,tier_id)
WITH RECURSIVE n AS (SELECT 1 AS i UNION ALL SELECT i+1 FROM n WHERE i < 600)
SELECT CONCAT('Passenger ',LPAD(i,4,'0')),
       CONCAT('bulk',i,'@example.com'),
       CONCAT('9',LPAD(MOD(i*7919321,1000000000),9,'0')),
       CASE MOD(i,10) WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 2
                      WHEN 3 THEN 3 WHEN 4 THEN 3 WHEN 5 THEN 3 ELSE 4 END
FROM n;

INSERT INTO flights (flight_no,source,destination,departure_datetime,arrival_datetime,aircraft_id,base_fare,flight_status)
WITH RECURSIVE n AS (SELECT 1 AS i UNION ALL SELECT i+1 FROM n WHERE i < 3000),
c AS (SELECT i, MOD(i,8) AS s, MOD(MOD(i,8)+1+MOD(i DIV 8,7),8) AS d,
             DATE_ADD(DATE_ADD('2026-11-10', INTERVAL MOD(i,60) DAY), INTERVAL 6+MOD(i,15) HOUR) AS dep
      FROM n)
SELECT CONCAT('BK',1000+i),
       ELT(s+1,'DEL','BOM','BLR','HYD','MAA','CCU','JAI','GOI'),
       ELT(d+1,'DEL','BOM','BLR','HYD','MAA','CCU','JAI','GOI'),
       dep, DATE_ADD(dep, INTERVAL 2 HOUR),
       1+MOD(i,3), 3000+MOD(i,20)*250, 'SCHEDULED'
FROM c;

SET @p0 = (SELECT MIN(passenger_id) FROM passengers WHERE email LIKE 'bulk%');

INSERT INTO bookings (flight_id,passenger_id,class_id,seat_no,booking_status,booking_timestamp,fare_paid)
WITH RECURSIVE k AS (SELECT 1 AS j UNION ALL SELECT j+1 FROM k WHERE j < 12)
SELECT f.flight_id,
       @p0 + MOD(f.flight_id*13 + k.j*7, 600),
       fc.class_id,
       IF(MOD(f.flight_id+k.j,11)=0, NULL, CONCAT(k.j, ELT(1+MOD(f.flight_id,6),'A','B','C','D','E','F'))),
       IF(MOD(f.flight_id+k.j,11)=0, 'CANCELLED', 'CONFIRMED'),
       DATE_SUB(f.departure_datetime, INTERVAL (5+MOD(f.flight_id*k.j,60)) DAY),
       f.base_fare * fc.fare_multiplier
FROM flights f
CROSS JOIN k
JOIN fare_classes fc ON fc.class_id = CASE MOD(f.flight_id+k.j,10) WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 2 ELSE 3 END
WHERE f.flight_no LIKE 'BK%';

-- refresh optimizer statistics after the bulk load (otherwise EXPLAIN row estimates are stale)
ANALYZE TABLE airports, aircraft, loyalty_tiers, fare_classes, passengers, flights, bookings;

SELECT COUNT(*) AS FLIGHTS_ROW_COUNT FROM flights;

SELECT COUNT(*) AS BOOKINGS_ROW_COUNT FROM bookings; 

SELECT COUNT(*) AS PASSENGERS_ROW_COUNT FROM passengers; 