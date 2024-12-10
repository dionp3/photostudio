create database photostudio;

use photostudio;

-- --------------------------------------------------------------------------------------------------------------------------------------

create user 'dionp6'@'localhost' identified by 'Dp061203';
grant execute on `photostudio`.* to 'dionp6'@'localhost';
flush privileges;

-- --------------------------------------------------------------------------------------------------------------------------------------

CREATE or replace TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE studios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    capacity INT NOT NULL DEFAULT 0,
    location VARCHAR(255) NOT NULL,
    hourly_rate DECIMAL(10, 2) NOT NULL, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE equipments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(255) NOT NULL,
    quantity INT DEFAULT 1,
    hourly_rate DECIMAL(10, 2) NOT NULL, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE photographers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact VARCHAR(255) NOT NULL,
    specialty VARCHAR(255),
    hourly_rate DECIMAL(10, 2) NOT NULL, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE studio_reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    studio_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    total_cost DECIMAL(10, 2) NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    reservation_status ENUM('pending', 'confirmed', 'cancelled', 'completed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (studio_id) REFERENCES studios(id) ON DELETE CASCADE
);

CREATE TABLE equipment_rentals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    equipment_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    quantity INT DEFAULT 1,
    total_cost DECIMAL(10, 2) NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    rental_status ENUM('pending', 'confirmed', 'cancelled', 'completed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (equipment_id) REFERENCES equipments(id) ON DELETE CASCADE
);

CREATE TABLE photographer_bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    photographer_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    total_cost DECIMAL(10, 2) NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    booking_status ENUM('pending', 'confirmed', 'cancelled', 'completed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (photographer_id) REFERENCES photographers(id)
);

CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL, 
    transaction_type ENUM('studio_reservation', 'equipment_rental', 'photographer_booking') NOT NULL, 
    payment_amount DECIMAL(10, 2) NOT NULL, 
    payment_method ENUM('credit_card', 'cash', 'bank_transfer') NOT NULL, 
    payment_status ENUM('pending', 'completed', 'failed') DEFAULT 'pending', 
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    FOREIGN KEY (transaction_id) REFERENCES studio_reservations(id) ON DELETE CASCADE, 
    FOREIGN KEY (transaction_id) REFERENCES equipment_rentals(id) ON DELETE CASCADE, 
    FOREIGN KEY (transaction_id) REFERENCES photographer_bookings(id) ON DELETE CASCADE 
);



-- Data --------------------------------------------------------------------------------------------------------------------------------------



-- auth --------------------------------------------------------------------------------------------------------------------------------------

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
        RESIGNAL;
    END;

    START TRANSACTION;

    IF p_username IS NULL OR CHAR_LENGTH(p_username) < 5 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Username must be at least 5 characters';
    END IF;

    IF p_email IS NULL OR p_email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid email format';
    END IF;

    IF p_password IS NULL OR CHAR_LENGTH(p_password) < 8 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Password must be at least 8 characters';
    END IF;

    IF EXISTS (SELECT 1 FROM users WHERE username = p_username) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Username already exists';
    END IF;

    IF EXISTS (SELECT 1 FROM users WHERE email = p_email) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Email already exists';
    END IF;

    INSERT INTO users (username, email, password, role)
    VALUES (p_username, p_email, p_password, p_role);

    COMMIT;
END;



CREATE OR REPLACE PROCEDURE loginUser(IN usernameInput VARCHAR(255), IN passwordInput VARCHAR(255))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;  
    END;

    START TRANSACTION;  

    SELECT id, username, email, role
    FROM users
    WHERE username = usernameInput AND password = passwordInput;

    COMMIT;  
END;



create or replace PROCEDURE getUserById(IN userId INT)
BEGIN
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    SELECT id, username, email, password, role, created_at
    FROM users
    WHERE id = userId;

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



CREATE OR REPLACE PROCEDURE editProfile(
    IN p_userId INT,
    IN p_username VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;  
        RESIGNAL;  
    END;

    START TRANSACTION;

    IF p_username IS NULL OR CHAR_LENGTH(p_username) < 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username must be at least 5 characters';
    END IF;

    IF p_email IS NULL OR p_email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid email format';
    END IF;

    IF EXISTS (SELECT 1 FROM users WHERE username = p_username AND id != p_userId) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username already exists';
    END IF;

    IF EXISTS (SELECT 1 FROM users WHERE email = p_email AND id != p_userId) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email already exists';
    END IF;

    UPDATE users
    SET 
        username = p_username,
        email = p_email,
        password = CASE
            WHEN p_password IS NOT NULL THEN SHA2(p_password, 256) 
            ELSE password 
        END
    WHERE id = p_userId;

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

    SELECT id, email INTO user_id, user_email
    FROM users
    WHERE email = p_email;

    IF user_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email not found';
    END IF;

    UPDATE users
    SET password = p_new_password
    WHERE id = user_id;

    COMMIT;
END;




-- user --------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE getStudios()
BEGIN
  START TRANSACTION;

  SELECT 
    studio_id, 
    studio_name, 
    studio_capacity, 
    studio_location, 
    studio_hourly_rate, 
    studio_created_at 
  FROM studios_view;

  COMMIT;
END;


CREATE OR REPLACE PROCEDURE getEquipments()
BEGIN
  START TRANSACTION;

  SELECT 
    equipment_id, 
    equipment_name, 
    equipment_type, 
    equipment_quantity, 
    equipment_hourly_rate, 
    equipment_created_at 
  FROM equipments_view;

  COMMIT;
END;

CREATE OR REPLACE PROCEDURE getPhotographers()
BEGIN
  START TRANSACTION;

  SELECT 
    photographer_id, 
    photographer_name, 
    photographer_specialty, 
    photographer_hourly_rate, 
    photographer_created_at 
  FROM photographers_view;

  COMMIT;
END;



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
    DATE_FORMAT(e.created_at, '%Y-%m-%d %H:%i:%s') AS equipment_created_at
FROM equipments e;



CREATE OR REPLACE VIEW photographers_view AS
SELECT 
    p.id AS photographer_id, 
    p.name AS photographer_name, 
    p.specialty AS photographer_specialty,
    p.hourly_rate AS photographer_hourly_rate,
    p.created_at AS photographer_created_at
FROM photographers p;



CREATE OR REPLACE PROCEDURE get_all_reservations()
BEGIN
  SELECT 
    r.id AS reservation_id,
    s.id AS studio_id, 
    s.name AS studio_name, 
    r.start_time, 
    r.end_time,
    r.reservation_status
  FROM studio_reservations r
  JOIN studios s ON r.studio_id = s.id;
END ;



CREATE OR REPLACE PROCEDURE get_user_studio_reservations(IN user_id INT)
BEGIN
    SELECT 
        r.id AS reservation_id,
        r.user_id,
        u.username AS user_name,
        r.studio_id,
        s.name AS studio_name,
        r.start_time,
        r.end_time,
        r.total_cost,
        r.payment_status,
        r.reservation_status,
        r.created_at AS reservation_created_at
    FROM studio_reservations r
    JOIN users u ON r.user_id = u.id
    LEFT JOIN studios s ON r.studio_id = s.id
    WHERE r.user_id = user_id
    ORDER BY r.created_at DESC;
END ;



CREATE OR REPLACE PROCEDURE get_user_equipment_rentals(IN user_id INT)
BEGIN
    SELECT 
        er.id AS rental_id,
        er.user_id,
        u.username AS user_name,
        er.equipment_id,
        e.name AS equipment_name,
        er.start_time,
        er.end_time,
        er.quantity,
        er.total_cost,
        er.payment_status,
        er.rental_status,
        er.created_at AS rental_created_at
    FROM equipment_rentals er
    JOIN users u ON er.user_id = u.id
    LEFT JOIN equipments e ON er.equipment_id = e.id
    WHERE er.user_id = user_id
    ORDER BY er.created_at DESC;
END ;



CREATE OR REPLACE PROCEDURE get_user_photographer_bookings(IN user_id INT)
BEGIN
    SELECT 
        pb.id AS booking_id,
        pb.user_id,
        u.username AS user_name,
        pb.photographer_id,
        p.name AS photographer_name,
        pb.start_time,
        pb.end_time,
        pb.total_cost,
        pb.payment_status,
        pb.booking_status,
        pb.created_at AS booking_created_at
    FROM photographer_bookings pb
    JOIN users u ON pb.user_id = u.id
    LEFT JOIN photographers p ON pb.photographer_id = p.id
    WHERE pb.user_id = user_id
    ORDER BY pb.created_at DESC;
END ;



CREATE OR REPLACE PROCEDURE CreateStudioReservation(
  IN p_user_id INT,
  IN p_studio_id INT,
  IN p_start_time DATETIME,
  IN p_end_time DATETIME,
  OUT p_reservation_id INT,
  OUT p_total_cost DECIMAL(10, 2)
)
BEGIN
  DECLARE v_hourly_rate DECIMAL(10, 2);
  DECLARE v_duration_in_hours DECIMAL(10, 2);
  DECLARE v_total_cost DECIMAL(10, 2);

  SELECT hourly_rate INTO v_hourly_rate
  FROM studios
  WHERE id = p_studio_id;

  IF v_hourly_rate IS NULL OR v_hourly_rate <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid hourly rate';
  END IF;

  SET v_duration_in_hours = TIMESTAMPDIFF(SECOND, p_start_time, p_end_time) / 3600;

  IF v_duration_in_hours <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'End time must be after start time';
  END IF;

  SET v_total_cost = v_hourly_rate * v_duration_in_hours;

  IF v_total_cost <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid total cost calculation';
  END IF;

  IF EXISTS (SELECT 1 FROM studio_reservations
             WHERE studio_id = p_studio_id
             AND (p_start_time < end_time AND p_end_time > start_time)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Studio is already reserved for the selected time range';
  END IF;

  INSERT INTO studio_reservations (user_id, studio_id, start_time, end_time, total_cost, payment_status, reservation_status)
  VALUES (p_user_id, p_studio_id, p_start_time, p_end_time, v_total_cost, 'pending', 'pending');

  SET p_reservation_id = LAST_INSERT_ID();
  SET p_total_cost = v_total_cost;
END ;



CREATE OR REPLACE PROCEDURE processStudioPaymentProcedure(
    IN p_reservation_id INT,
    IN p_payment_amount DECIMAL(10, 2),
    OUT p_payment_status ENUM('pending', 'completed', 'failed'),
    OUT p_reservation_status ENUM('pending', 'confirmed', 'cancelled', 'completed')
)
BEGIN
    DECLARE v_total_cost DECIMAL(10, 2);
    DECLARE v_payment_status ENUM('pending', 'completed', 'failed');
    DECLARE v_reservation_status ENUM('pending', 'confirmed', 'cancelled', 'completed');
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT total_cost, payment_status, reservation_status
    INTO v_total_cost, v_payment_status, v_reservation_status
    FROM studio_reservations
    WHERE id = p_reservation_id;

    IF v_total_cost IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reservation not found';
    END IF;

    IF v_payment_status = 'completed' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment already completed';
    END IF;

    IF v_reservation_status = 'cancelled' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reservation has been cancelled';
    END IF;

    IF p_payment_amount != v_total_cost THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment amount does not match total cost';
    END IF;

    UPDATE studio_reservations
    SET payment_status = 'completed',
        reservation_status = 'confirmed'
    WHERE id = p_reservation_id;

    COMMIT;

    SET p_payment_status = 'completed';
    SET p_reservation_status = 'confirmed';

END;



CREATE FUNCTION calculate_total_cost(p_studio_id INT, p_start_time DATETIME, p_end_time DATETIME)
RETURNS DECIMAL(10,2)
BEGIN
  DECLARE v_hourly_rate DECIMAL(10, 2);
  DECLARE v_duration_in_hours DECIMAL(10, 2);
  DECLARE v_total_cost DECIMAL(10, 2);

  SELECT hourly_rate INTO v_hourly_rate
  FROM studios
  WHERE id = p_studio_id;

  SET v_duration_in_hours = TIMESTAMPDIFF(SECOND, p_start_time, p_end_time) / 3600;

  SET v_total_cost = v_hourly_rate * v_duration_in_hours;

  RETURN v_total_cost;
END;



CREATE TRIGGER check_studio_availability
BEFORE INSERT ON studio_reservations
FOR EACH ROW
BEGIN
  IF EXISTS (SELECT 1 FROM studio_reservations
             WHERE studio_id = NEW.studio_id
             AND (NEW.start_time < end_time AND NEW.end_time > start_time)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Studio is already reserved for the selected time range';
  END IF;
END;



CREATE TRIGGER update_reservation_status
AFTER UPDATE ON studio_reservations
FOR EACH ROW
BEGIN
  IF NEW.payment_status = 'completed' AND NEW.reservation_status = 'pending' THEN
    UPDATE studio_reservations
    SET reservation_status = 'confirmed'
    WHERE id = NEW.id;
  END IF;
END;



CREATE OR REPLACE VIEW user_reservations_view AS
SELECT 
    r.id AS reservation_id,
    r.user_id,
    u.username AS user_name,
    r.studio_id,
    s.name AS studio_name,
    r.start_time,
    r.end_time,
    r.total_cost,
    r.payment_status,
    r.reservation_status,
    r.created_at AS reservation_created_at
FROM reservations r
JOIN users u ON r.user_id = u.id
JOIN studios s ON r.studio_id = s.id;

CREATE OR REPLACE VIEW all_reservations_view AS
SELECT 
    r.id AS reservation_id,
    r.user_id,
    u.username AS user_name,
    'studio' AS service_type,
    r.studio_id AS service_id,
    s.name AS service_name,
    r.start_time,
    r.end_time,
    r.total_cost,
    r.payment_status,
    r.reservation_status AS service_status,
    r.created_at AS service_created_at
FROM reservations r
JOIN users u ON r.user_id = u.id
JOIN studios s ON r.studio_id = s.id
UNION ALL
SELECT 
    er.id AS reservation_id,
    er.user_id,
    u.username AS user_name,
    'equipment' AS service_type,
    er.equipment_id AS service_id,
    e.name AS service_name,
    er.start_time,
    er.end_time,
    er.total_cost,
    er.payment_status,
    er.rental_status AS service_status,
    er.created_at AS service_created_at
FROM equipment_rentals er
JOIN users u ON er.user_id = u.id
JOIN equipments e ON er.equipment_id = e.id
UNION ALL
SELECT 
    pb.id AS reservation_id,
    pb.user_id,
    u.username AS user_name,
    'photographer' AS service_type,
    pb.photographer_id AS service_id,
    p.name AS service_name,
    pb.start_time,
    pb.end_time,
    pb.total_cost,
    pb.payment_status,
    pb.booking_status AS service_status,
    pb.created_at AS service_created_at
FROM photographer_bookings pb
JOIN users u ON pb.user_id = u.id
JOIN photographers p ON pb.photographer_id = p.id;

CREATE TRIGGER update_service_status
AFTER UPDATE ON payments
FOR EACH ROW
BEGIN
    IF NEW.service_type = 'studio' AND NEW.payment_status = 'completed' THEN
        UPDATE reservations
        SET reservation_status = 'confirmed'
        WHERE id = NEW.service_id;
    ELSEIF NEW.service_type = 'studio' AND NEW.payment_status = 'failed' THEN
        UPDATE reservations
        SET reservation_status = 'cancelled'
        WHERE id = NEW.service_id;
    END IF;

    IF NEW.service_type = 'equipment' AND NEW.payment_status = 'completed' THEN
        UPDATE equipment_rentals
        SET rental_status = 'confirmed'
        WHERE id = NEW.service_id;
    ELSEIF NEW.service_type = 'equipment' AND NEW.payment_status = 'failed' THEN
        UPDATE equipment_rentals
        SET rental_status = 'cancelled'
        WHERE id = NEW.service_id;
    END IF;

    IF NEW.service_type = 'photographer' AND NEW.payment_status = 'completed' THEN
        UPDATE photographer_bookings
        SET booking_status = 'confirmed'
        WHERE id = NEW.service_id;
    ELSEIF NEW.service_type = 'photographer' AND NEW.payment_status = 'failed' THEN
        UPDATE photographer_bookings
        SET booking_status = 'cancelled'
        WHERE id = NEW.service_id;
    END IF;
END;

CREATE TRIGGER after_payment_update
AFTER UPDATE ON studio_reservations
FOR EACH ROW
BEGIN
  IF NEW.payment_status = 'paid' AND OLD.payment_status != 'paid' THEN
    UPDATE studio_reservations
    SET reservation_status = 'confirmed'
    WHERE id = NEW.id;
  END IF;
END ;

CREATE FUNCTION getTotalCost(studioId INT, startTime DATETIME, endTime DATETIME) 
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
  DECLARE hourlyRate DECIMAL(10, 2);
  DECLARE durationHours DECIMAL(10, 2);

  SELECT hourly_rate INTO hourlyRate 
  FROM studios 
  WHERE id = studioId;

  SET durationHours = TIMESTAMPDIFF(MINUTE, startTime, endTime) / 60;

  RETURN hourlyRate * durationHours;
END;

CREATE TRIGGER beforePaymentInsert
BEFORE INSERT ON payment_history
FOR EACH ROW
BEGIN
  DECLARE totalCost DECIMAL(10, 2);

  SET totalCost = getTotalCost((SELECT studio_id FROM reservations WHERE id = NEW.reservation_id), 
                               (SELECT start_time FROM reservations WHERE id = NEW.reservation_id), 
                               (SELECT end_time FROM reservations WHERE id = NEW.reservation_id));
  
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
  
  SELECT id, hourly_rate INTO studioId, hourlyRate
  FROM studios
  WHERE name = studioName;
  
  SELECT COUNT(*) = 0 INTO isAvailable
  FROM reservations
  WHERE studio_id = studioId
    AND (start_time < endTime AND end_time > startTime);
  
  SET totalCost = TIMESTAMPDIFF(HOUR, startTime, endTime) * hourlyRate;

  IF isAvailable THEN
    INSERT INTO reservations (user_id, studio_id, start_time, end_time, total_cost)
    VALUES (userId, studioId, startTime, endTime, totalCost);

    SELECT 
      studioName AS reserved_studio_name,
      startTime AS reservation_start_time,
      endTime AS reservation_end_time,
      totalCost AS reservation_total_cost,
      'pending' AS status;  
  ELSE
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Studio is already reserved';
  END IF;
END;

create or replace PROCEDURE process_payment(
    IN reservationId INT,
    IN amount DECIMAL(10, 2),
    IN paymentMethod VARCHAR(50)
)
BEGIN
    DECLARE payment_status ENUM('pending', 'completed', 'failed');

    UPDATE payments
    SET payment_status = 'completed', amount = amount
    WHERE reservation_id = reservationId;

    SELECT payment_status
    FROM payments
    WHERE reservation_id = reservationId
    LIMIT 1;
    
END;

CREATE OR REPLACE TRIGGER update_reservation_status_after_payment
AFTER INSERT ON payment_history
FOR EACH ROW
BEGIN
  IF NEW.payment_status = 'successful' THEN
    UPDATE reservations
    SET status = 'confirmed'
    WHERE id = NEW.reservation_id;
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

CREATE VIEW payment_details AS
SELECT
    p.id AS payment_id,
    p.transaction_id,
    p.transaction_type,
    CASE
        WHEN p.transaction_type = 'studio_reservation' THEN sr.start_time
        WHEN p.transaction_type = 'equipment_rental' THEN er.start_time
        WHEN p.transaction_type = 'photographer_booking' THEN pb.start_time
    END AS transaction_start_time,
    p.payment_amount,
    p.payment_method,
    p.payment_status,
    p.payment_date
FROM payments p
LEFT JOIN studio_reservations sr ON p.transaction_id = sr.id AND p.transaction_type = 'studio_reservation'
LEFT JOIN equipment_rentals er ON p.transaction_id = er.id AND p.transaction_type = 'equipment_rental'
LEFT JOIN photographer_bookings pb ON p.transaction_id = pb.id AND p.transaction_type = 'photographer_booking';

CREATE TRIGGER update_transaction_status AFTER UPDATE ON payments
FOR EACH ROW
BEGIN
    IF NEW.payment_status = 'completed' THEN
        IF NEW.transaction_type = 'studio_reservation' THEN
            UPDATE studio_reservations SET reservation_status = 'completed' WHERE id = NEW.transaction_id;
        ELSEIF NEW.transaction_type = 'equipment_rental' THEN
            UPDATE equipment_rentals SET rental_status = 'completed' WHERE id = NEW.transaction_id;
        ELSEIF NEW.transaction_type = 'photographer_booking' THEN
            UPDATE photographer_bookings SET booking_status = 'completed' WHERE id = NEW.transaction_id;
        END IF;
    END IF;
END;

CREATE TRIGGER after_payment_successful
AFTER UPDATE ON equipment_rentals
FOR EACH ROW
BEGIN
  IF NEW.payment_status = 'completed' THEN
    INSERT INTO payment_history (rental_id, payment_amount, payment_method, payment_date)
    VALUES (NEW.id, NEW.total_cost, 'bank_transfer', NOW()); 
  END IF;
END;

CREATE PROCEDURE process_payment(
    IN p_transaction_id INT,
    IN p_transaction_type ENUM('studio_reservation', 'equipment_rental', 'photographer_booking'),
    IN p_payment_amount DECIMAL(10, 2),
    IN p_payment_method ENUM('credit_card', 'cash', 'bank_transfer')
)
BEGIN
    DECLARE v_payment_status ENUM('pending', 'completed', 'failed');

    SET v_payment_status = 'pending';

    INSERT INTO payments (transaction_id, transaction_type, payment_amount, payment_method, payment_status)
    VALUES (p_transaction_id, p_transaction_type, p_payment_amount, p_payment_method, v_payment_status);

    IF v_payment_status = 'pending' THEN
        UPDATE payments SET payment_status = 'completed' WHERE transaction_id = p_transaction_id;

        IF p_transaction_type = 'studio_reservation' THEN
            UPDATE studio_reservations SET payment_status = 'completed' WHERE id = p_transaction_id;
        ELSEIF p_transaction_type = 'equipment_rental' THEN
            UPDATE equipment_rentals SET rental_status = 'completed' WHERE id = p_transaction_id;
        ELSEIF p_transaction_type = 'photographer_booking' THEN
            UPDATE photographer_bookings SET booking_status = 'completed' WHERE id = p_transaction_id;
        END IF;
    END IF;

END ;



-- admin --------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE get_all_reservations_for_admin()
BEGIN
  SELECT 
    r.id AS reservation_id,
    r.user_id, 
    u.username, 
    r.studio_id, 
    s.name AS studio_name, 
    r.start_time, 
    r.end_time,
    r.total_cost,
    r.payment_status,
    r.reservation_status,
    r.created_at AS reservation_created_at
  FROM studio_reservations r
  JOIN studios s ON r.studio_id = s.id
  JOIN users u ON r.user_id = u.id;
END ;



CREATE OR REPLACE PROCEDURE add_studio (
    IN studioName VARCHAR(255),
    IN studioCapacity INT,
    IN studioLocation VARCHAR(255),
    IN studioHourlyRate DECIMAL(10, 2)
)
BEGIN
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; 
    END;

    START TRANSACTION;

    INSERT INTO studios (name, capacity, location, hourly_rate)
    VALUES (studioName, studioCapacity, studioLocation, studioHourlyRate);

    COMMIT;
END;



CREATE OR REPLACE PROCEDURE update_studio(
    IN p_studio_id INT,
    IN p_new_name VARCHAR(255),
    IN p_new_capacity INT,
    IN p_new_location VARCHAR(255),
    IN p_new_hourly_rate DECIMAL(10, 2)
)
BEGIN
    DECLARE v_existing_studio_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; 
    END;

    START TRANSACTION;

    SELECT id INTO v_existing_studio_id
    FROM studios
    WHERE id = p_studio_id;

    IF v_existing_studio_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Studio not found';
    END IF;

    UPDATE studios
    SET name = p_new_name,
        capacity = p_new_capacity,
        location = p_new_location,
        hourly_rate = p_new_hourly_rate
    WHERE id = p_studio_id;

    COMMIT;
END;



CREATE OR REPLACE PROCEDURE delete_studio(
  IN studioId INT
)
BEGIN
  DECLARE exit handler FOR SQLEXCEPTION
  BEGIN
    ROLLBACK; 
  END;

  START TRANSACTION;

  DELETE FROM studios
  WHERE id = studioId;

  COMMIT;
END;



CREATE OR REPLACE PROCEDURE add_equipment(
  IN equipmentName VARCHAR(255),
  IN equipmentType VARCHAR(255),
  IN equipmentQuantity INT,
  IN equipmentHourlyRate DECIMAL(10, 2)
)
BEGIN
  DECLARE v_existing_equipment INT;

  SELECT COUNT(*) INTO v_existing_equipment
  FROM equipments
  WHERE name = equipmentName;

  IF v_existing_equipment > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Equipment with this name already exists';
  END IF;

  START TRANSACTION;

  INSERT INTO equipments (name, type, quantity, hourly_rate)
  VALUES (equipmentName, equipmentType, equipmentQuantity, equipmentHourlyRate);

  COMMIT;
END;



CREATE OR REPLACE PROCEDURE update_equipment(
  IN equipmentName VARCHAR(255),
  IN newEquipmentName VARCHAR(255),
  IN newEquipmentType VARCHAR(255),
  IN newEquipmentQuantity INT,
  IN newEquipmentHourlyRate DECIMAL(10, 2)
)
BEGIN
  DECLARE v_existing_equipment INT;
  
  SELECT COUNT(*) INTO v_existing_equipment
  FROM equipments
  WHERE name = equipmentName;

  IF v_existing_equipment = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Equipment to update does not exist';
  END IF;

  IF newEquipmentQuantity <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantity must be greater than 0';
  END IF;

  IF newEquipmentHourlyRate <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hourly rate must be greater than 0';
  END IF;

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



CREATE OR REPLACE PROCEDURE delete_equipment(
  IN equipmentName VARCHAR(255)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
  END;

  START TRANSACTION;

  DELETE FROM equipments
  WHERE name = equipmentName;

  COMMIT;
END;



CREATE OR REPLACE PROCEDURE get_photographers()
BEGIN
  SELECT 
    photographer_id, 
    photographer_name, 
    photographer_contact, 
    photographer_specialty, 
    photographer_hourly_rate, 
    photographer_created_at
  FROM photographers_view_for_admin;
END;



CREATE or replace VIEW photographers_view_for_admin AS
SELECT 
    p.id AS photographer_id, 
    p.name AS photographer_name, 
    p.contact AS photographer_contact, 
    p.specialty AS photographer_specialty,
    p.hourly_rate AS photographer_hourly_rate,
    p.created_at AS photographer_created_at
FROM photographers p;



CREATE OR REPLACE PROCEDURE add_photographer (
  IN photographerName VARCHAR(255),
  IN photographerContact VARCHAR(255),
  IN photographerSpecialty VARCHAR(255),
  IN photographerHourlyRate DECIMAL(10, 2)
)
BEGIN
  DECLARE photographerExists INT DEFAULT 0;

  SELECT COUNT(*) INTO photographerExists
  FROM photographers
  WHERE name = photographerName;

  IF photographerExists > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Photographer with this name already exists';
  END IF;

  START TRANSACTION;

  INSERT INTO photographers (name, contact, specialty, hourly_rate)
  VALUES (photographerName, photographerContact, photographerSpecialty, photographerHourlyRate);

  COMMIT;
END;



CREATE OR REPLACE PROCEDURE update_photographer (
  IN photographerName VARCHAR(255),
  IN newPhotographerName VARCHAR(255),
  IN newPhotographerContact VARCHAR(255),
  IN newPhotographerSpecialty VARCHAR(255),
  IN newPhotographerHourlyRate DECIMAL(10, 2)
)
BEGIN
  DECLARE v_existing_photographer INT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
  END;

  START TRANSACTION;

  SELECT COUNT(*) INTO v_existing_photographer
  FROM photographers
  WHERE name = photographerName;

  IF v_existing_photographer = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Photographer not found';
  END IF;

  UPDATE photographers
  SET name = newPhotographerName, 
      contact = newPhotographerContact, 
      specialty = newPhotographerSpecialty,
      hourly_rate = newPhotographerHourlyRate
  WHERE name = photographerName;

  COMMIT;
END;



CREATE OR REPLACE PROCEDURE delete_photographer (
  IN photographerName VARCHAR(255)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
  END;

  START TRANSACTION;

  DELETE FROM photographers
  WHERE name = photographerName;

  COMMIT;
END;

