create database photostudio;

use photostudio;

-- Tabel Users (untuk registrasi dan login)
CREATE or replace TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Studios (untuk studio foto)
CREATE TABLE studios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    capacity INT NOT NULL DEFAULT 0,
    location VARCHAR(255) NOT NULL,
    hourly_rate DECIMAL(10, 2) NOT NULL, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Equipment (untuk peralatan foto)
CREATE TABLE equipments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(255) NOT NULL,
    quantity INT DEFAULT 1,
    hourly_rate DECIMAL(10, 2) NOT NULL, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Photographers (untuk fotografer)
CREATE TABLE photographers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact VARCHAR(255) NOT NULL,
    specialty VARCHAR(255),
    hourly_rate DECIMAL(10, 2) NOT NULL, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



-- Tabel Reservations (untuk reservasi studio)
CREATE TABLE reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    studio_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    total_cost DECIMAL(10, 2) DEFAULT 0, -- Total biaya reservasi
    status ENUM('pending', 'confirmed', 'canceled') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (studio_id) REFERENCES studios(id)
);

drop table photographers;
delete from reservations;
delete from payment_history;
select * from payments;
select * from payment_history;


-- Tabel Payments (untuk mencatat pembayaran)
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT NOT NULL,
    payment_method ENUM('credit_card', 'bank_transfer') NOT NULL, -- Metode pembayaran
    payment_status ENUM('pending', 'completed', 'failed') DEFAULT 'pending', -- Status pembayaran
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2) NOT NULL, -- Jumlah yang dibayar
    transaction_id VARCHAR(255), -- ID transaksi unik dari gateway pembayaran
    FOREIGN KEY (reservation_id) REFERENCES reservations(id)
);

-- Tabel Pembayaran History
CREATE TABLE payment_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,        -- Jumlah pembayaran
    payment_method VARCHAR(50) NOT NULL,   -- Metode pembayaran (misalnya: "credit_card", "bank_transfer", "paypal")
    payment_status ENUM('pending', 'successful', 'failed') DEFAULT 'pending',  -- Status pembayaran
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Tanggal pembayaran
    FOREIGN KEY (reservation_id) REFERENCES reservations(id)
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

-- Data -------------------------------------------------------------------

INSERT INTO studios (name, capacity, location) VALUES
('Studio A', 20, 'Jl. Studio No. 1, Jakarta'),
('Studio B', 10, 'Jl. Foto No. 10, Bandung');


INSERT INTO equipments (name, type, quantity) VALUES
('Kamera DSLR', 'Kamera', 10),
('Lampu Studio', 'Lampu', 5),
('Backdrop', 'Peralatan', 3);

INSERT INTO photographers (name, contact, specialty) VALUES
('John Doe', '081234567890', 'Fashion Photography'),
('Jane Smith', '081987654321', 'Product Photography');

INSERT INTO reservations (user_id, studio_id, start_time, end_time) VALUES
(11, 1, '2024-12-10 10:00:00', '2024-12-10 12:00:00'),
(11, 2, '2024-12-12 14:00:00', '2024-12-12 16:00:00');

INSERT INTO equipment_rentals (user_id, equipment_id, rent_start, rent_end) VALUES
(2, 1, '2024-12-10 09:00:00', '2024-12-10 12:00:00'),
(3, 2, '2024-12-12 13:00:00', '2024-12-12 16:00:00');

INSERT INTO photographer_bookings (user_id, photographer_id, booking_start, booking_end) VALUES
(2, 1, '2024-12-10 10:00:00', '2024-12-10 12:00:00'),
(3, 2, '2024-12-12 14:00:00', '2024-12-12 16:00:00');


-- auth ------------------------------------------------------------------- 

CREATE OR REPLACE PROCEDURE registerUser(
    IN p_username VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_role VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; 
    END;

    START TRANSACTION;

    IF EXISTS (SELECT 1 FROM users WHERE username = p_username) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username already exists';
    END IF;

    IF EXISTS (SELECT 1 FROM users WHERE email = p_email) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already exists';
    END IF;

    INSERT INTO users (username, email, password, role)
    VALUES (p_username, p_email, p_password, p_role);

    COMMIT;
END;



CREATE OR REPLACE PROCEDURE loginUser(
    IN p_username VARCHAR(255),
    IN p_password VARCHAR(255)
)
BEGIN
    DECLARE user_id INT;
    DECLARE user_role VARCHAR(50);
    DECLARE stored_password VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        ROLLBACK;

    START TRANSACTION;

    SELECT id, password, role INTO user_id, stored_password, user_role
    FROM users
    WHERE username = p_username;

    IF user_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid credentials';
    END IF;

    COMMIT;

    SELECT user_id AS id, user_role AS role, stored_password AS password;
END;



CREATE OR REPLACE PROCEDURE getUserById(IN user_id INT)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    ROLLBACK;

  START TRANSACTION;

  SELECT id, username, email, password, role, created_at
  FROM users
  WHERE id = user_id;

  COMMIT;
END;



CREATE OR REPLACE PROCEDURE deleteUserById(IN userId INT)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    ROLLBACK;

  START TRANSACTION;

  DELETE FROM users WHERE id = userId;

  COMMIT;
END;



CREATE OR REPLACE PROCEDURE getUserByEmail(IN user_email VARCHAR(255))
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    ROLLBACK;

  START TRANSACTION;

  SELECT id, username, email, role, created_at
  FROM users
  WHERE email = user_email;

  COMMIT;
END;




CREATE OR REPLACE PROCEDURE forgotPassword(
    IN p_email VARCHAR(255),
    IN p_new_password VARCHAR(255)
)
BEGIN
    DECLARE user_id INT;
    DECLARE user_email VARCHAR(255);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        ROLLBACK;

    START TRANSACTION;

    -- Mencari pengguna berdasarkan email
    SELECT id, email INTO user_id, user_email
    FROM users
    WHERE email = p_email;

    -- Jika pengguna tidak ditemukan, berikan error
    IF user_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email not found';
    END IF;

    -- Mengupdate password pengguna
    UPDATE users
    SET password = p_new_password
    WHERE id = user_id;

    COMMIT;
END;



CREATE OR REPLACE PROCEDURE editProfile(
    IN p_user_id INT,
    IN p_username VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        ROLLBACK;

    START TRANSACTION;

    -- Update username jika diberikan
    IF p_username IS NOT NULL THEN
        UPDATE users
        SET username = p_username
        WHERE id = p_user_id;
    END IF;

    -- Update email jika diberikan
    IF p_email IS NOT NULL THEN
        UPDATE users
        SET email = p_email
        WHERE id = p_user_id;
    END IF;

    -- Update password jika diberikan
    IF p_password IS NOT NULL THEN
        UPDATE users
        SET password = p_password
        WHERE id = p_user_id;
    END IF;

    COMMIT;
END ;





-- user -------------------------------------------------------------------

CREATE OR REPLACE VIEW studios_view AS
SELECT 
    s.id AS studio_id, 
    s.name AS studio_name, 
    s.capacity AS studio_capacity,
    s.location AS studio_location, 
    s.hourly_rate AS studio_hourly_rate,
    DATE_FORMAT(s.created_at, '%Y-%m-%d %H:%i:%s') AS studio_created_at
FROM studios s;



CREATE OR REPLACE VIEW equipments_view AS
SELECT 
    e.id AS equipment_id, 
    e.name AS equipment_name, 
    e.type AS equipment_type, 
    e.quantity AS equipment_quantity,
    e.hourly_rate AS equipment_hourly_rate,
    e.created_at AS equipment_created_at
FROM equipments e;



CREATE OR REPLACE VIEW photographers_view AS
SELECT 
    p.id AS photographer_id, 
    p.name AS photographer_name, 
    p.specialty AS photographer_specialty,
    p.hourly_rate AS photographer_hourly_rate,
    p.created_at AS photographer_created_at
FROM photographers p;



CREATE or replace VIEW photographers_view_for_admin AS
SELECT 
    p.id AS photographer_id, 
    p.name AS photographer_name, 
    p.contact AS photographer_contact, 
    p.specialty AS photographer_specialty,
    p.hourly_rate AS photographer_hourly_rate,
    p.created_at AS photographer_created_at
FROM photographers p;



CREATE or replace PROCEDURE get_all_reservations()
BEGIN
  SELECT 
    s.name AS studio_name, 
    r.start_time, 
    r.end_time
  FROM reservations r
  JOIN studios s ON r.studio_id = s.id;
END ;



CREATE OR REPLACE VIEW user_reservations_view AS
SELECT r.id AS reservation_id, 
       r.user_id,   
       u.username, 
       s.name AS studio_name, 
       r.start_time, 
       r.end_time, 
       r.total_cost, 
       r.status, 
       r.created_at,
       p.payment_status
FROM reservations r
JOIN users u ON r.user_id = u.id
JOIN studios s ON r.studio_id = s.id
LEFT JOIN payments p ON p.reservation_id = r.id;



CREATE FUNCTION getTotalCost(studioId INT, startTime DATETIME, endTime DATETIME) 
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
  DECLARE hourlyRate DECIMAL(10, 2);
  DECLARE durationHours DECIMAL(10, 2);

  -- Get the hourly rate of the studio
  SELECT hourly_rate INTO hourlyRate 
  FROM studios 
  WHERE id = studioId;

  -- Calculate the duration of the reservation in hours
  SET durationHours = TIMESTAMPDIFF(MINUTE, startTime, endTime) / 60;

  -- Calculate total cost
  RETURN hourlyRate * durationHours;
END;

CREATE TRIGGER beforePaymentInsert
BEFORE INSERT ON payment_history
FOR EACH ROW
BEGIN
  -- Calculate the total cost based on the reservation
  DECLARE totalCost DECIMAL(10, 2);

  -- Get the total cost from the reservation and update the payment table
  SET totalCost = getTotalCost((SELECT studio_id FROM reservations WHERE id = NEW.reservation_id), 
                               (SELECT start_time FROM reservations WHERE id = NEW.reservation_id), 
                               (SELECT end_time FROM reservations WHERE id = NEW.reservation_id));
  
  -- Update the total cost in the payment record
  SET NEW.amount = totalCost;
END;




CREATE TRIGGER after_reservation_insert
AFTER INSERT ON reservations
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (action, timestamp, user_id)
  VALUES ('Reservation Created', NOW(), NEW.user_id);
END;



CREATE OR REPLACE PROCEDURE reserve_studio (
  IN userId INT,
  IN studioName VARCHAR(255),
  IN startTime DATETIME,
  IN endTime DATETIME
)
BEGIN
  DECLARE studioId INT;
  DECLARE isAvailable BOOLEAN;
  DECLARE hourlyRate DECIMAL(10, 2);
  DECLARE totalCost DECIMAL(10, 2);
  
  -- Get the studio ID and hourly rate from the name
  SELECT id, hourly_rate INTO studioId, hourlyRate
  FROM studios
  WHERE name = studioName;
  
  -- Check availability
  SELECT COUNT(*) = 0 INTO isAvailable
  FROM reservations
  WHERE studio_id = studioId
    AND (start_time < endTime AND end_time > startTime);
  
  -- Calculate the total cost based on the duration (in hours)
  SET totalCost = TIMESTAMPDIFF(HOUR, startTime, endTime) * hourlyRate;

  -- Reserve the studio if available
  IF isAvailable THEN
    -- Insert reservation with calculated total_cost
    INSERT INTO reservations (user_id, studio_id, start_time, end_time, total_cost)
    VALUES (userId, studioId, startTime, endTime, totalCost);

    -- Return the reservation details
    SELECT 
      studioName AS reserved_studio_name,
      startTime AS reservation_start_time,
      endTime AS reservation_end_time,
      totalCost AS reservation_total_cost,
      'pending' AS status;  -- Return the default status if not explicitly set
  ELSE
    -- Signal an error if studio is already reserved for the time
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Studio is already reserved';
  END IF;
END;






-- Stored Procedure untuk Memproses Pembayaran
create or replace PROCEDURE process_payment(
    IN reservationId INT,
    IN amount DECIMAL(10, 2),
    IN paymentMethod VARCHAR(50)
)
BEGIN
    DECLARE payment_status ENUM('pending', 'completed', 'failed');

    -- Proses pembayaran dan update status pembayaran
    UPDATE payments
    SET payment_status = 'completed', amount = amount
    WHERE reservation_id = reservationId;

    -- Ambil status pembayaran setelah update
    SELECT payment_status
    FROM payments
    WHERE reservation_id = reservationId
    LIMIT 1;
    
END;










-- Trigger untuk memperbarui status reservasi ketika status pembayaran diperbarui
CREATE OR REPLACE TRIGGER update_reservation_status_after_payment
AFTER INSERT ON payment_history
FOR EACH ROW
BEGIN
  -- Jika pembayaran berhasil, ubah status reservasi menjadi 'confirmed'
  IF NEW.payment_status = 'successful' THEN
    UPDATE reservations
    SET status = 'confirmed'
    WHERE id = NEW.reservation_id;
  -- Jika pembayaran gagal, ubah status reservasi menjadi 'failed'
  ELSEIF NEW.payment_status = 'failed' THEN
    UPDATE reservations
    SET status = 'failed'
    WHERE id = NEW.reservation_id;
  END IF;
END;



CREATE OR REPLACE VIEW payment_report AS
SELECT
    p.id AS payment_id,
    p.payment_date,
    s.name AS studio_name,
    p.amount,
    p.payment_method,
    p.payment_status,
    s.capacity AS studio_capacity,
    s.location AS studio_location,
    u.username AS user_name,
    u.email AS user_email
FROM
    payments p
JOIN
    reservations r ON p.reservation_id = r.id
JOIN
    studios s ON r.studio_id = s.id
JOIN
    users u ON r.user_id = u.id;






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

CREATE or replace PROCEDURE get_all_reservations_for_admin()
BEGIN
  SELECT 
    r.id AS reservation_id,
    r.user_id, 
    u.username, 
    r.studio_id, 
    s.name AS studio_name, 
    r.start_time, 
    r.end_time
  FROM reservations r
  JOIN studios s ON r.studio_id = s.id
  JOIN users u ON r.user_id = u.id;
end;


CREATE OR REPLACE PROCEDURE add_studio (
    IN studioName VARCHAR(255),
    IN studioCapacity INT,
    IN studioLocation VARCHAR(255),
    IN studioHourlyRate DECIMAL(10, 2)
)
BEGIN
    -- Tangani error dengan ROLLBACK
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; 
    END;

    -- Mulai transaksi
    START TRANSACTION;

    -- Insert studio baru
    INSERT INTO studios (name, capacity, location, hourly_rate)
    VALUES (studioName, studioCapacity, studioLocation, studioHourlyRate);

    -- Commit transaksi
    COMMIT;
END;



CREATE TRIGGER after_studio_insert
AFTER INSERT ON studios
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (action, timestamp, user_id)
  VALUES ('Studio Added', NOW(), NEW.admin_id);
END ;



CREATE OR REPLACE PROCEDURE update_studio(
  IN studioId INT,
  IN newStudioName VARCHAR(255),
  IN newStudioCapacity INT,
  IN newStudioLocation VARCHAR(255),
  IN newStudioHourlyRate DECIMAL(10, 2)
)
BEGIN
  DECLARE studioCount INT;
  DECLARE exit handler FOR SQLEXCEPTION
  BEGIN
    -- Rollback jika terjadi kesalahan
    ROLLBACK; 
  END;

  -- Mulai transaksi
  START TRANSACTION;

  -- Cek apakah studio dengan nama baru sudah ada, kecuali untuk studio yang sedang diupdate
  SELECT COUNT(*) INTO studioCount
  FROM studios
  WHERE name = newStudioName AND id != studioId;

  IF studioCount > 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'A studio with the new name already exists.';
  END IF;

  -- Update data studio berdasarkan ID
  UPDATE studios
  SET 
    name = newStudioName, 
    capacity = newStudioCapacity, 
    location = newStudioLocation,
    hourly_rate = newStudioHourlyRate
  WHERE id = studioId;

  -- Commit transaksi jika tidak ada masalah
  COMMIT;
END;







DELIMITER $$
CREATE TRIGGER after_studio_update
AFTER UPDATE ON studios
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (action, timestamp, user_id)
  VALUES ('Studio Updated', NOW(), NEW.admin_id);
END$$
DELIMITER ;




CREATE OR REPLACE PROCEDURE delete_studio(
  IN studioId INT
)
BEGIN
  DECLARE exit handler FOR SQLEXCEPTION
  BEGIN
    ROLLBACK; -- Rollback transaction if an error occurs
  END;

  START TRANSACTION;

  -- Hapus studio berdasarkan ID
  DELETE FROM studios
  WHERE id = studioId;

  -- Commit transaction jika tidak ada masalah
  COMMIT;
END;




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




CREATE OR REPLACE PROCEDURE add_equipment (
  IN equipmentName VARCHAR(255),
  IN equipmentType VARCHAR(255),
  IN equipmentQuantity INT,
  IN equipmentHourlyRate DECIMAL(10, 2)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
  END;

  START TRANSACTION;
  INSERT INTO equipments (name, type, quantity, hourly_rate)
  VALUES (equipmentName, equipmentType, equipmentQuantity, equipmentHourlyRate);
  COMMIT;
END;




DELIMITER $$
CREATE TRIGGER after_equipment_insert
AFTER INSERT ON equipment
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (action, timestamp, user_id)
  VALUES ('Equipment Added', NOW(), NEW.admin_id);
END$$

DELIMITER ;

CREATE OR REPLACE PROCEDURE update_equipment(
  IN equipmentName VARCHAR(255),
  IN newEquipmentName VARCHAR(255),
  IN newEquipmentType VARCHAR(255),
  IN newEquipmentQuantity INT,
  IN newEquipmentHourlyRate DECIMAL(10, 2)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
  END;

  START TRANSACTION;
  UPDATE equipments
  SET 
    name = newEquipmentName, 
    type = newEquipmentType, 
    quantity = newEquipmentQuantity,
    hourly_rate = newEquipmentHourlyRate
  WHERE name = equipmentName;
  COMMIT;
END;


DELIMITER $$
CREATE TRIGGER after_equipment_update
AFTER UPDATE ON equipment
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (action, timestamp, user_id)
  VALUES ('Equipment Updated', NOW(), NEW.admin_id);
END$$




CREATE OR REPLACE PROCEDURE delete_equipment(
  IN equipmentName VARCHAR(255)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
  END;

  -- Mulai transaksi
  START TRANSACTION;

  -- Hapus peralatan berdasarkan nama
  DELETE FROM equipments
  WHERE name = equipmentName;

  -- Commit transaksi jika berhasil
  COMMIT;
END;





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




CREATE OR REPLACE PROCEDURE add_photographer (
  IN photographerName VARCHAR(255),
  IN photographerContact VARCHAR(255),
  IN photographerSpecialty VARCHAR(255),
  IN photographerHourlyRate DECIMAL(10, 2)
)
BEGIN
  DECLARE photographerExists INT DEFAULT 0;

  -- Mengecek apakah fotografer dengan nama yang sama sudah ada
  SELECT COUNT(*) INTO photographerExists
  FROM photographers
  WHERE name = photographerName;

  -- Jika sudah ada, keluarkan error
  IF photographerExists > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Photographer with this name already exists';
  END IF;

  -- Mulai transaksi
  START TRANSACTION;

  -- Menambahkan fotografer ke tabel photographers
  INSERT INTO photographers (name, contact, specialty, hourly_rate)
  VALUES (photographerName, photographerContact, photographerSpecialty, photographerHourlyRate);

  -- Commit transaksi jika berhasil
  COMMIT;
END;






DELIMITER $$
CREATE TRIGGER after_photographer_insert
AFTER INSERT ON photographers
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (action, timestamp, user_id)
  VALUES ('Photographer Added', NOW(), NEW.admin_id);
END$$
DELIMITER ;

CREATE OR REPLACE PROCEDURE update_photographer (
  IN photographerName VARCHAR(255),
  IN newPhotographerName VARCHAR(255),
  IN newPhotographerContact VARCHAR(255),
  IN newPhotographerSpecialty VARCHAR(255),
  IN newPhotographerHourlyRate DECIMAL(10, 2)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
  END;

  -- Mulai transaksi
  START TRANSACTION;

  -- Memperbarui data fotografer berdasarkan nama fotografer yang lama
  UPDATE photographers
  SET name = newPhotographerName, 
      contact = newPhotographerContact, 
      specialty = newPhotographerSpecialty,
      hourly_rate = newPhotographerHourlyRate
  WHERE name = photographerName;

  -- Commit transaksi jika berhasil
  COMMIT;
END;




DELIMITER $$
CREATE TRIGGER after_photographer_update
AFTER UPDATE ON photographers
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (action, timestamp, user_id)
  VALUES ('Photographer Updated', NOW(), NEW.admin_id);
END$$
DELIMITER ;


CREATE OR REPLACE PROCEDURE delete_photographer (
  IN photographerName VARCHAR(255)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
  END;

  -- Mulai transaksi
  START TRANSACTION;

  -- Menghapus fotografer berdasarkan nama
  DELETE FROM photographers
  WHERE name = photographerName;

  -- Commit transaksi jika berhasil
  COMMIT;
END;



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