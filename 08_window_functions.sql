-- File 08: Window functions (Objective 6)
USE flight_reservation;

-- 8.1 Upgrade / offload decision for overbooked flight 7
-- ROW_NUMBER: strict order (tier, class, booking time) -> no ties.
-- RANK on tier+class only: shows ties that the timestamp then breaks.
SELECT b.flight_id, p.full_name, lt.tier_name, fc.class_name, b.booking_timestamp,
       ROW_NUMBER() OVER (PARTITION BY b.flight_id
                          ORDER BY lt.priority_rank, fc.priority_rank, b.booking_timestamp) AS priority_no,
       RANK()       OVER (PARTITION BY b.flight_id
                          ORDER BY lt.priority_rank, fc.priority_rank) AS rank_ignoring_time,
       a.total_seats,
       CASE WHEN ROW_NUMBER() OVER (PARTITION BY b.flight_id
                          ORDER BY lt.priority_rank, fc.priority_rank, b.booking_timestamp) <= a.total_seats
            THEN 'SEATED' ELSE 'OFFLOAD' END AS decision
FROM bookings b
JOIN passengers p     ON p.passenger_id = b.passenger_id
JOIN loyalty_tiers lt ON lt.tier_id = p.tier_id
JOIN fare_classes fc  ON fc.class_id = b.class_id
JOIN flights f        ON f.flight_id = b.flight_id
JOIN aircraft a       ON a.aircraft_id = f.aircraft_id
WHERE b.flight_id = 7 AND b.booking_status IN ('CONFIRMED','WAITLISTED','OFFLOADED')
ORDER BY priority_no;

-- 8.2 Running total of daily revenue per route (confirmed bookings, route DEL-BOM)
WITH daily AS (
    SELECT CONCAT(f.source,'-',f.destination) AS route,
           DATE(b.booking_timestamp)          AS booking_date,
           COUNT(*)                           AS bookings_made,
           SUM(b.fare_paid)                   AS daily_revenue
    FROM bookings b JOIN flights f ON f.flight_id = b.flight_id
    WHERE b.booking_status = 'CONFIRMED'
    GROUP BY route, booking_date
)
SELECT route, booking_date, daily_revenue,
       SUM(daily_revenue) OVER (PARTITION BY route ORDER BY booking_date) AS running_total
FROM daily
WHERE route = 'DEL-BOM'
ORDER BY booking_date
LIMIT 15;

-- 8.3 LAG(): each day's bookings vs the previous day (route DEL-BOM)
WITH daily AS (
    SELECT CONCAT(f.source,'-',f.destination) AS route,
           DATE(b.booking_timestamp)          AS booking_date,
           COUNT(*)                           AS bookings_made
    FROM bookings b JOIN flights f ON f.flight_id = b.flight_id
    WHERE b.booking_status = 'CONFIRMED'
    GROUP BY route, booking_date
)
SELECT route, booking_date, bookings_made,
       LAG(bookings_made) OVER (PARTITION BY route ORDER BY booking_date) AS previous_day_bookings,
       bookings_made - LAG(bookings_made) OVER (PARTITION BY route ORDER BY booking_date) AS change_vs_previous
FROM daily
WHERE route = 'DEL-BOM'
ORDER BY booking_date
LIMIT 15;
