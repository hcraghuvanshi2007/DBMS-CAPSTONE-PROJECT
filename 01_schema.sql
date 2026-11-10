-- =====================================================================
-- Flight Reservation System  |  DBMS Capstone (ETCCMS304)
-- File 01: Schema   (MySQL 8.0.16+ required for CHECK constraints)
-- =====================================================================
DROP DATABASE IF EXISTS flight_reservation;
CREATE DATABASE flight_reservation;
USE flight_reservation;

-- Reference: airports
CREATE TABLE airports (
    airport_code  CHAR(3)      PRIMARY KEY,
    airport_name  VARCHAR(100) NOT NULL,
    city          VARCHAR(50)  NOT NULL,
    country       VARCHAR(50)  NOT NULL DEFAULT 'India'
);

Describe airports;

SELECT * FROM airports;

-- Reference: aircraft (capacity lives here)
CREATE TABLE aircraft (
    aircraft_id  INT AUTO_INCREMENT PRIMARY KEY,
    model        VARCHAR(50) NOT NULL,
    total_seats  INT         NOT NULL,
    CONSTRAINT chk_aircraft_seats CHECK (total_seats > 0)
);

Describe aircraft;
SELECT * FROM aircraft;

-- Reference: loyalty tiers (priority_rank 1 = highest priority)
CREATE TABLE loyalty_tiers (
    tier_id        TINYINT     PRIMARY KEY,
    tier_name      VARCHAR(20) NOT NULL UNIQUE,
    priority_rank  TINYINT     NOT NULL UNIQUE
);
Describe loyalty_tiers;
SELECT * FROM loyalty_tiers;

-- Reference: fare classes (priority_rank 1 = highest priority)
CREATE TABLE fare_classes (
    class_id         TINYINT      PRIMARY KEY,
    class_name       VARCHAR(20)  NOT NULL UNIQUE,
    priority_rank    TINYINT      NOT NULL UNIQUE,
    fare_multiplier  DECIMAL(4,2) NOT NULL,
    CONSTRAINT chk_fare_mult CHECK (fare_multiplier > 0)
);
Describe fare_classes;
SELECT * FROM fare_classes;

CREATE TABLE passengers (
    passenger_id  INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(80)  NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    phone         VARCHAR(15),
    tier_id       TINYINT      NOT NULL DEFAULT 4,
    CONSTRAINT fk_pass_tier FOREIGN KEY (tier_id) REFERENCES loyalty_tiers(tier_id)
);
DESCRIBE passengers;
SELECT * FROM passengers LIMIT 15; 
 
-- A flight = a scheduled run on a route (source -> destination)
CREATE TABLE flights (
    flight_id           INT AUTO_INCREMENT PRIMARY KEY,
    flight_no           VARCHAR(10)   NOT NULL,
    source              CHAR(3)       NOT NULL,
    destination         CHAR(3)       NOT NULL,
    departure_datetime  DATETIME      NOT NULL,
    arrival_datetime    DATETIME      NOT NULL,
    aircraft_id         INT           NOT NULL,
    base_fare           DECIMAL(10,2) NOT NULL,
    flight_status       ENUM('SCHEDULED','CANCELLED','DEPARTED') NOT NULL DEFAULT 'SCHEDULED',
    CONSTRAINT fk_fl_source   FOREIGN KEY (source)      REFERENCES airports(airport_code),
    CONSTRAINT fk_fl_dest     FOREIGN KEY (destination) REFERENCES airports(airport_code),
    CONSTRAINT fk_fl_aircraft FOREIGN KEY (aircraft_id) REFERENCES aircraft(aircraft_id),
    CONSTRAINT uq_flight_run  UNIQUE (flight_no, departure_datetime),
    CONSTRAINT chk_fl_route   CHECK (source <> destination),
    CONSTRAINT chk_fl_times   CHECK (arrival_datetime > departure_datetime),
    CONSTRAINT chk_fl_fare    CHECK (base_fare > 0)
);

DESCRIBE flights;
DROP TABLE flights;
SELECT * FROM flights LIMIT 15;
 
CREATE TABLE bookings (
    booking_id         INT AUTO_INCREMENT PRIMARY KEY,
    flight_id          INT           NOT NULL,
    passenger_id       INT           NOT NULL,
    class_id           TINYINT       NOT NULL,
    seat_no            VARCHAR(4)    NULL,          -- NULL for waitlisted / offloaded / cancelled
    booking_status     ENUM('CONFIRMED','WAITLISTED','CANCELLED','OFFLOADED') NOT NULL DEFAULT 'CONFIRMED',
    booking_timestamp  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fare_paid          DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_bk_flight FOREIGN KEY (flight_id)    REFERENCES flights(flight_id),
    CONSTRAINT fk_bk_pass   FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
    CONSTRAINT fk_bk_class  FOREIGN KEY (class_id)     REFERENCES fare_classes(class_id),
    CONSTRAINT chk_bk_fare  CHECK (fare_paid >= 0),
    CONSTRAINT chk_bk_seat  CHECK (booking_status <> 'CONFIRMED' OR seat_no IS NOT NULL)
);
DESCRIBE bookings;
SELECT * FROM bookings LIMIT 15;  