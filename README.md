# Flight Reservation System - SQL package (MySQL 8.0.16+)

Run in this order (all tested on MySQL 8.0):

| File | Purpose | Objective |
|---|---|---|
| 01_schema.sql | Creates database + 7 tables with constraints | 1 |
| 02_sample_data.sql | Small readable data set (9 flights, 24 passengers, 43 bookings) | 1 |
| 03_bulk_data.sql | +600 passengers, 3,000 flights, ~36,000 bookings so EXPLAIN is meaningful (ends with ANALYZE TABLE) | 4 |
| 04_core_queries.sql | Seat availability, booking status, flight cancellation | 2 |
| 05_overbooking.sql | Detect overbooked flight 7, apply priority rule, loyalty upgrade | 3 |
| 06_indexing.sql | Two composite indexes, EXPLAIN before/after, "index not used" cases | 4 |
| 07_views.sql | 2 views + WITH CHECK OPTION demo (includes two expected errors) | 5 |
| 08_window_functions.sql | ROW_NUMBER/RANK decision, running revenue, LAG | 6 |

flight_reservation_setup.sql = files 01 + 02 + 03 in one file (schema + all data).
To reset the database at any time, re-run flight_reservation_setup.sql.

Expected errors (they are the demonstrations): 1288 (update through aggregate view) and 1369 (CHECK OPTION failed).

Tables: airports, aircraft, loyalty_tiers, fare_classes, passengers, flights, bookings.
