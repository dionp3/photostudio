create database photostudio;

use photostudio;

-- Tabel Users (untuk registrasi dan login)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Studios (untuk studio foto)
CREATE TABLE studios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES users(id)
);

-- Tabel Equipment (untuk peralatan foto)
CREATE TABLE equipment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(255) NOT NULL,
    quantity INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES users(id)
);

-- Tabel Photographers (untuk fotografer)
CREATE TABLE photographers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    contact VARCHAR(255) NOT NULL,
    specialty VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES users(id)
);

-- Tabel Reservations (untuk reservasi studio)
CREATE TABLE reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    studio_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (studio_id) REFERENCES studios(id)
);

-- Tabel Equipment Rentals (untuk penyewaan peralatan)
CREATE TABLE equipment_rentals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    equipment_id INT NOT NULL,
    rent_start DATETIME NOT NULL,
    rent_end DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (equipment_id) REFERENCES equipment(id)
);

-- Tabel Photographer Bookings (untuk pemesanan fotografer)
CREATE TABLE photographer_bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    photographer_id INT NOT NULL,
    booking_start DATETIME NOT NULL,
    booking_end DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (photographer_id) REFERENCES photographers(id)
);

-- Tabel Audit Log (untuk mencatat aksi yang dilakukan oleh admin)
CREATE TABLE audit_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    action VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Data -------------------------------------------------------------------

INSERT INTO users (username, password, role) VALUES
('admin1', 'adminpassword123', 'admin'),
('user1', 'userpassword123', 'user'),
('user2', 'userpassword456', 'user');

INSERT INTO studios (admin_id, name, location) VALUES
(1, 'Studio A', 'Jl. Studio No. 1, Jakarta'),
(1, 'Studio B', 'Jl. Foto No. 10, Bandung');

INSERT INTO equipment (admin_id, name, type, quantity) VALUES
(1, 'Kamera DSLR', 'Kamera', 10),
(1, 'Lampu Studio', 'Lampu', 5),
(1, 'Backdrop', 'Peralatan', 3);

INSERT INTO photographers (admin_id, name, contact, specialty) VALUES
(1, 'John Doe', '081234567890', 'Fashion Photography'),
(1, 'Jane Smith', '081987654321', 'Product Photography');

INSERT INTO reservations (user_id, studio_id, start_time, end_time) VALUES
(2, 1, '2024-12-10 10:00:00', '2024-12-10 12:00:00'),
(3, 2, '2024-12-12 14:00:00', '2024-12-12 16:00:00');

INSERT INTO equipment_rentals (user_id, equipment_id, rent_start, rent_end) VALUES
(2, 1, '2024-12-10 09:00:00', '2024-12-10 12:00:00'),
(3, 2, '2024-12-12 13:00:00', '2024-12-12 16:00:00');

INSERT INTO photographer_bookings (user_id, photographer_id, booking_start, booking_end) VALUES
(2, 1, '2024-12-10 10:00:00', '2024-12-10 12:00:00'),
(3, 2, '2024-12-12 14:00:00', '2024-12-12 16:00:00');


-- auth -------------------------------------------------------------------
DELIMITER $$ 
CREATE PROCEDURE registerUser(
    IN p_username VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_role ENUM('user', 'admin') DEFAULT 'user'
)
BEGIN
    -- Menyimpan user dengan role dan password yang sudah di-hash di aplikasi
    INSERT INTO users (username, password, role)
    VALUES (p_username, p_password, p_role);
END $$ 
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE loginUser(
    IN p_username VARCHAR(255),
    IN p_password VARCHAR(255)
)
BEGIN
    DECLARE user_id INT;
    DECLARE user_role VARCHAR(50);
    DECLARE stored_password VARCHAR(255);
    
    -- Cek apakah username ada
    SELECT id, password, role INTO user_id, stored_password, user_role
    FROM users
    WHERE username = p_username;
    
    -- Jika user ditemukan, verifikasi password di aplikasi
    SELECT user_id AS id, user_role AS role, stored_password AS password;
END $$ 
DELIMITER ;

-- user -------------------------------------------------------------------
CREATE VIEW studio_view AS
SELECT s.id AS studio_id, s.name AS studio_name, s.location, s.created_at AS studio_created_at, u.username AS admin_username
FROM studios s
JOIN users u ON s.admin_id = u.id;

CREATE VIEW equipment_view AS
SELECT e.id AS equipment_id, e.name AS equipment_name, e.type, e.quantity, e.created_at AS equipment_created_at, u.username AS admin_username
FROM equipment e
JOIN users u ON e.admin_id = u.id;

CREATE VIEW photographer_view AS
SELECT p.id AS photographer_id, p.name AS photographer_name, p.contact, p.specialty, p.created_at AS photographer_created_at, u.username AS admin_username
FROM photographers p
JOIN users u ON p.admin_id = u.id;

CREATE VIEW user_reservations_view AS
SELECT 
  r.user_id, 
  s.name AS studio_name, 
  r.start_time, 
  r.end_time
FROM reservations r
JOIN studios s ON r.studio_id = s.id;

DELIMITER $$
CREATE TRIGGER after_reservation_insert
AFTER INSERT ON reservations
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (action, timestamp, user_id)
  VALUES ('Reservation Created', NOW(), NEW.user_id);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE reserve_studio (
  IN userId INT,
  IN studioId INT,
  IN startTime DATETIME,
  IN endTime DATETIME
)
BEGIN
  DECLARE isAvailable BOOLEAN;
  START TRANSACTION;
  SELECT COUNT(*) = 0 INTO isAvailable
  FROM reservations
  WHERE studio_id = studioId
    AND (start_time < endTime AND end_time > startTime);

  IF isAvailable THEN
    INSERT INTO reservations (user_id, studio_id, start_time, end_time)
    VALUES (userId, studioId, startTime, endTime);
    COMMIT;
  ELSE
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Studio is already reserved';
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE rent_equipment (
  IN userId INT,
  IN equipmentId INT,
  IN rentStart DATETIME,
  IN rentEnd DATETIME
)
BEGIN
  DECLARE isAvailable BOOLEAN;
  START TRANSACTION;
  SELECT COUNT(*) = 0 INTO isAvailable
  FROM equipment_rentals
  WHERE equipment_id = equipmentId
    AND (rent_start < rentEnd AND rent_end > rentStart);

  IF isAvailable THEN
    INSERT INTO equipment_rentals (user_id, equipment_id, rent_start, rent_end)
    VALUES (userId, equipmentId, rentStart, rentEnd);
    COMMIT;
  ELSE
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Equipment is already rented';
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE book_photographer (
  IN userId INT,
  IN photographerId INT,
  IN bookingStart DATETIME,
  IN bookingEnd DATETIME
)
BEGIN
  DECLARE isAvailable BOOLEAN;
  START TRANSACTION;
  SELECT COUNT(*) = 0 INTO isAvailable
  FROM photographer_bookings
  WHERE photographer_id = photographerId
    AND (booking_start < bookingEnd AND booking_end > bookingStart);

  IF isAvailable THEN
    INSERT INTO photographer_bookings (user_id, photographer_id, booking_start, booking_end)
    VALUES (userId, photographerId, bookingStart, bookingEnd);
    COMMIT;
  ELSE
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Photographer is already booked';
  END IF;
END$$
DELIMITER ;

-- admin -------------------------------------------------------------------
DELIMITER $$
CREATE PROCEDURE add_studio (
  IN adminId INT,
  IN studioName VARCHAR(255),
  IN studioLocation VARCHAR(255)
)
BEGIN
  INSERT INTO studios (admin_id, name, location)
  VALUES (adminId, studioName, studioLocation);
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_studio_insert
AFTER INSERT ON studios
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (action, timestamp, user_id)
  VALUES ('Studio Added', NOW(), NEW.admin_id);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE update_studio(
  IN studioId INT,
  IN studioName VARCHAR(255),
  IN studioLocation VARCHAR(255)
)
BEGIN
  UPDATE studios
  SET name = studioName, location = studioLocation
  WHERE id = studioId;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_studio_update
AFTER UPDATE ON studios
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (action, timestamp, user_id)
  VALUES ('Studio Updated', NOW(), NEW.admin_id);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE delete_studio(
  IN studioId INT
)
BEGIN
  DELETE FROM studios WHERE id = studioId;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_studio_delete
AFTER DELETE ON studios
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (action, timestamp, user_id)
  VALUES ('Studio Deleted', NOW(), OLD.admin_id);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE view_studio(
  IN studioId INT
)
BEGIN
  SELECT * FROM studios WHERE id = studioId;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE add_equipment (
  IN adminId INT,
  IN equipmentName VARCHAR(255),
  IN equipmentType VARCHAR(255)
)
BEGIN
  INSERT INTO equipment (admin_id, name, type)
  VALUES (adminId, equipmentName, equipmentType);
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_equipment_insert
AFTER INSERT ON equipment
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (action, timestamp, user_id)
  VALUES ('Equipment Added', NOW(), NEW.admin_id);
END$$

DELIMITER ;

DELIMITER $$
CREATE PROCEDURE update_equipment(
  IN equipmentId INT,
  IN equipmentName VARCHAR(255),
  IN equipmentQuantity INT
)
BEGIN
  UPDATE equipment
  SET name = equipmentName, quantity = equipmentQuantity
  WHERE id = equipmentId;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_equipment_update
AFTER UPDATE ON equipment
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (action, timestamp, user_id)
  VALUES ('Equipment Updated', NOW(), NEW.admin_id);
END$$

DELIMITER $$
CREATE PROCEDURE delete_equipment(
  IN equipmentId INT
)
BEGIN
  DELETE FROM equipment WHERE id = equipmentId;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_equipment_delete
AFTER DELETE ON equipment
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (action, timestamp, user_id)
  VALUES ('Equipment Deleted', NOW(), OLD.admin_id);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE view_equipment(
  IN equipmentId INT
)
BEGIN
  SELECT * FROM equipment WHERE id = equipmentId;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE add_photographer (
  IN adminId INT,
  IN photographerName VARCHAR(255),
  IN photographerContact VARCHAR(255)
)
BEGIN
  INSERT INTO photographers (admin_id, name, contact)
  VALUES (adminId, photographerName, photographerContact);
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_photographer_insert
AFTER INSERT ON photographers
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (action, timestamp, user_id)
  VALUES ('Photographer Added', NOW(), NEW.admin_id);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE update_photographer(
  IN photographerId INT,
  IN photographerName VARCHAR(255),
  IN photographerSpecialty VARCHAR(255)
)
BEGIN
  UPDATE photographers
  SET name = photographerName, specialty = photographerSpecialty
  WHERE id = photographerId;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_photographer_update
AFTER UPDATE ON photographers
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (action, timestamp, user_id)
  VALUES ('Photographer Updated', NOW(), NEW.admin_id);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE delete_photographer(
  IN photographerId INT
)
BEGIN
  DELETE FROM photographers WHERE id = photographerId;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_photographer_delete
AFTER DELETE ON photographers
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (action, timestamp, user_id)
  VALUES ('Photographer Deleted', NOW(), OLD.admin_id);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE view_photographer(
  IN photographerId INT
)
BEGIN
  SELECT * FROM photographers WHERE id = photographerId;
END$$
DELIMITER ;