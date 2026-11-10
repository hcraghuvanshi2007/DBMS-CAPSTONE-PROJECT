-- =====================================================================
-- File 02: Hand-written sample data (small, readable, used for demos)
-- Flight 7 is deliberately OVERBOOKED (8 seats, 12 active bookings)
-- Flight 8 is later cancelled by a query; flight 9 is already cancelled
-- =====================================================================
USE flight_reservation;

INSERT INTO airports VALUES
('DEL','Indira Gandhi International','Delhi','India'),
('BOM','Chhatrapati Shivaji Maharaj International','Mumbai','India'),
('BLR','Kempegowda International','Bengaluru','India'),
('HYD','Rajiv Gandhi International','Hyderabad','India'),
('MAA','Chennai International','Chennai','India'),
('CCU','Netaji Subhas Chandra Bose International','Kolkata','India'),
('JAI','Jaipur International','Jaipur','India'),
('GOI','Dabolim Airport','Goa','India');

INSERT INTO aircraft (model,total_seats) VALUES
('Airbus A320',180),('Boeing 737-800',189),('ATR 72-600',72),('Cessna 208 Caravan',8);

INSERT INTO loyalty_tiers VALUES (1,'Platinum',1),(2,'Gold',2),(3,'Silver',3),(4,'Basic',4);
INSERT INTO fare_classes VALUES (1,'First',1,4.00),(2,'Business',2,2.50),(3,'Economy',3,1.00);

INSERT INTO passengers (full_name,email,phone,tier_id) VALUES
('Aarav Sharma','aarav.sharma@example.com','9810000001',1),
('Priya Verma','priya.verma@example.com','9810000002',2),
('Rohan Mehta','rohan.mehta@example.com','9810000003',3),
('Sneha Iyer','sneha.iyer@example.com','9810000004',4),
('Vikram Singh','vikram.singh@example.com','9810000005',1),
('Ananya Gupta','ananya.gupta@example.com','9810000006',2),
('Karan Malhotra','karan.malhotra@example.com','9810000007',4),
('Neha Kapoor','neha.kapoor@example.com','9810000008',3),
('Rahul Nair','rahul.nair@example.com','9810000009',4),
('Isha Reddy','isha.reddy@example.com','9810000010',2),
('Arjun Patel','arjun.patel@example.com','9810000011',4),
('Meera Joshi','meera.joshi@example.com','9810000012',3),
('Aditya Rao','aditya.rao@example.com','9810000013',4),
('Kavya Menon','kavya.menon@example.com','9810000014',1),
('Sanjay Das','sanjay.das@example.com','9810000015',4),
('Pooja Bansal','pooja.bansal@example.com','9810000016',3),
('Manish Tiwari','manish.tiwari@example.com','9810000017',2),
('Divya Chawla','divya.chawla@example.com','9810000018',4),
('Harsh Agarwal','harsh.agarwal@example.com','9810000019',4),
('Ritu Saxena','ritu.saxena@example.com','9810000020',3),
('Nikhil Jain','nikhil.jain@example.com','9810000021',4),
('Tanvi Desai','tanvi.desai@example.com','9810000022',1),
('Yash Khanna','yash.khanna@example.com','9810000023',4),
('Simran Kaur','simran.kaur@example.com','9810000024',2);

INSERT INTO flights (flight_id,flight_no,source,destination,departure_datetime,arrival_datetime,aircraft_id,base_fare,flight_status) VALUES
(1,'AI101','DEL','BOM','2026-11-02 06:30:00','2026-11-02 08:40:00',1,5500,'SCHEDULED'),
(2,'AI102','BOM','DEL','2026-11-02 18:30:00','2026-11-02 20:45:00',2,5600,'SCHEDULED'),
(3,'6E201','DEL','BLR','2026-11-03 09:00:00','2026-11-03 11:50:00',1,6200,'SCHEDULED'),
(4,'6E202','BLR','DEL','2026-11-04 14:00:00','2026-11-04 16:50:00',2,6100,'SCHEDULED'),
(5,'UK301','DEL','BOM','2026-11-03 07:15:00','2026-11-03 09:25:00',1,5400,'SCHEDULED'),
(6,'UK302','DEL','BOM','2026-11-04 07:15:00','2026-11-04 09:25:00',2,5300,'SCHEDULED'),
(7,'QP401','HYD','GOI','2026-11-05 11:00:00','2026-11-05 12:30:00',4,4800,'SCHEDULED'),
(8,'6E203','DEL','JAI','2026-11-06 10:30:00','2026-11-06 11:30:00',3,3900,'SCHEDULED'),
(9,'6E204','DEL','CCU','2026-11-01 08:00:00','2026-11-01 10:15:00',2,6800,'CANCELLED');

-- (flight, passenger, class, seat, status, booked_at)
INSERT INTO bookings (flight_id,passenger_id,class_id,seat_no,booking_status,booking_timestamp) VALUES
-- Flight 1  DEL-BOM
(1,1,1,'1A','CONFIRMED','2026-10-18 10:15:00'),
(1,2,2,'4C','CONFIRMED','2026-10-18 14:20:00'),
(1,3,3,'12D','CONFIRMED','2026-10-19 09:05:00'),
(1,4,3,'12E','CONFIRMED','2026-10-20 18:40:00'),
(1,5,2,'3B','CONFIRMED','2026-10-21 11:30:00'),
-- Flight 2  BOM-DEL
(2,6,3,'15A','CONFIRMED','2026-10-19 12:00:00'),
(2,7,3,'15B','CONFIRMED','2026-10-19 16:45:00'),
(2,8,2,'5D','CONFIRMED','2026-10-20 08:10:00'),
(2,9,3,'22C','CONFIRMED','2026-10-22 20:25:00'),
-- Flight 3  DEL-BLR
(3,10,3,'10A','CONFIRMED','2026-10-20 13:15:00'),
(3,11,3,'10B','CONFIRMED','2026-10-21 09:50:00'),
(3,12,2,'6A','CONFIRMED','2026-10-21 17:35:00'),
(3,13,3,'18F','CONFIRMED','2026-10-22 10:00:00'),
(3,14,1,'1C','CONFIRMED','2026-10-23 15:20:00'),
-- Flight 4  BLR-DEL
(4,15,3,'9A','CONFIRMED','2026-10-21 11:11:00'),
(4,16,3,'9B','CONFIRMED','2026-10-22 12:12:00'),
(4,17,2,'4A','CONFIRMED','2026-10-23 13:13:00'),
-- Flight 5  DEL-BOM
(5,18,3,'20A','CONFIRMED','2026-10-19 09:30:00'),
(5,19,3,'20B','CONFIRMED','2026-10-20 10:30:00'),
(5,20,2,'5A','CONFIRMED','2026-10-21 11:30:00'),
(5,21,3,'21C','CONFIRMED','2026-10-22 12:30:00'),
-- Flight 6  DEL-BOM
(6,22,1,'1B','CONFIRMED','2026-10-20 08:00:00'),
(6,23,3,'25D','CONFIRMED','2026-10-21 08:30:00'),
(6,24,2,'4D','CONFIRMED','2026-10-22 09:00:00'),
(6,1,3,'25E','CONFIRMED','2026-10-23 09:30:00'),
(6,2,3,'26A','CONFIRMED','2026-10-24 10:00:00'),
-- Flight 7  HYD-GOI  (8-seater, OVERBOOKED: 8 confirmed + 4 waitlisted)
(7,4,3,'1A','CONFIRMED','2026-10-10 09:00:00'),
(7,7,3,'1B','CONFIRMED','2026-10-10 10:00:00'),
(7,9,3,'2A','CONFIRMED','2026-10-11 09:00:00'),
(7,11,3,'2B','CONFIRMED','2026-10-11 10:00:00'),
(7,13,3,'3A','CONFIRMED','2026-10-12 09:00:00'),
(7,3,3,'3B','CONFIRMED','2026-10-12 10:00:00'),
(7,8,3,'4A','CONFIRMED','2026-10-13 09:00:00'),
(7,6,2,'4B','CONFIRMED','2026-10-13 10:00:00'),
(7,5,2,NULL,'WAITLISTED','2026-10-20 09:00:00'),
(7,14,3,NULL,'WAITLISTED','2026-10-21 09:00:00'),
(7,10,3,NULL,'WAITLISTED','2026-10-22 09:00:00'),
(7,16,2,NULL,'WAITLISTED','2026-10-23 09:00:00'),
-- Flight 8  DEL-JAI  (will be cancelled by a query)
(8,17,3,'7A','CONFIRMED','2026-10-22 10:00:00'),
(8,18,3,'7B','CONFIRMED','2026-10-23 10:00:00'),
(8,19,3,'7C','CONFIRMED','2026-10-24 10:00:00'),
-- Flight 9  DEL-CCU  (already cancelled)
(9,20,3,NULL,'CANCELLED','2026-10-10 10:00:00'),
(9,21,2,NULL,'CANCELLED','2026-10-11 10:00:00');

-- fare_paid = base_fare x class multiplier
UPDATE bookings b
JOIN flights f       ON f.flight_id = b.flight_id
JOIN fare_classes fc ON fc.class_id = b.class_id
SET b.fare_paid = f.base_fare * fc.fare_multiplier;
