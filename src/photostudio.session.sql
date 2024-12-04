CREATE DATABASE photostudio;

\c photostudio;

-- Tabel Users
CREATE TABLE Users (
    ID_User SERIAL PRIMARY KEY,
    Nama VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Role VARCHAR(20) NOT NULL CHECK (Role IN ('Admin', 'Client'))
);

-- Tabel Studio
CREATE TABLE Studio (
    ID_Studio SERIAL PRIMARY KEY,
    Fasilitas TEXT NOT NULL,
    Biaya DECIMAL(10, 2) NOT NULL,
    Ketersediaan BOOLEAN NOT NULL DEFAULT TRUE,
    Kapasitas INT NOT NULL
);

CREATE TABLE Peralatan (
    ID_Peralatan SERIAL PRIMARY KEY,
    Nama VARCHAR(100) NOT NULL,
    Biaya NUMERIC(10, 2) NOT NULL,
    Ketersediaan BOOLEAN NOT NULL,
    Kapasitas INT NOT NULL,
    ID_Admin INT NOT NULL,
    FOREIGN KEY (ID_Admin) REFERENCES Admin(ID_Admin) ON DELETE CASCADE
);

-- Tabel Photographer
CREATE TABLE Photographer (
    ID_Photographer SERIAL PRIMARY KEY,
    Nama VARCHAR(100) NOT NULL,
    Biaya DECIMAL(10, 2) NOT NULL,
    Ketersediaan BOOLEAN NOT NULL DEFAULT TRUE,
    Kapasitas INT NOT NULL,
    No_Telp VARCHAR(15) NOT NULL
);

-- Tabel Reservasi
CREATE TABLE Reservasi (
    ID_Reservasi SERIAL PRIMARY KEY,
    ID_Client INT REFERENCES Client(ID_Client) ON DELETE CASCADE,
    ID_Studio INT REFERENCES Studio(ID_Studio) ON DELETE CASCADE,
    Tanggal_Reservasi DATE NOT NULL,
    Waktu_Mulai TIME NOT NULL,
    Waktu_Selesai TIME NOT NULL
);

-- Tabel Pesan (untuk Photographer)
CREATE TABLE Pesan (
    ID_Sewa SERIAL PRIMARY KEY,
    ID_Client INT REFERENCES Client(ID_Client) ON DELETE CASCADE,
    ID_Photographer INT REFERENCES Photographer(ID_Photographer) ON DELETE CASCADE,
    Tanggal_Pesan DATE NOT NULL,
    Durasi_Pesan INTERVAL NOT NULL
);

-- Tabel Pembayaran
CREATE TABLE Pembayaran (
    ID_Pembayaran SERIAL PRIMARY KEY,
    ID_Client INT REFERENCES Client(ID_Client) ON DELETE CASCADE,
    Total_Pembayaran DECIMAL(10, 2) NOT NULL,
    Jenis_Pembayaran VARCHAR(50) NOT NULL,
    Tanggal_Pembayaran TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Relasi Kelola (Admin mengelola Studio dan Photographer)
ALTER TABLE Studio ADD COLUMN ID_Admin INT REFERENCES Admin(ID_Admin) ON DELETE SET NULL;
ALTER TABLE Photographer ADD COLUMN ID_Admin INT REFERENCES Admin(ID_Admin) ON DELETE SET NULL;

-- Menambahkan Admin
INSERT INTO Users (Nama, Email, Password, Role)
VALUES
('Admin Satu', 'admin1@example.com', 'hashed_password_1', 'Admin'),
('Admin Dua', 'admin2@example.com', 'hashed_password_2', 'Admin');

-- Menambahkan Client
INSERT INTO Users (Nama, Email, Password, Role)
VALUES
('User Satu', 'user1@example.com', 'hashed_password_3', 'Client'),
('User Dua', 'user2@example.com', 'hashed_password_4', 'Client');


-- Tabel Studio
INSERT INTO Studio (Fasilitas, Biaya, Ketersediaan, Kapasitas, ID_Admin)
VALUES
('AC, Sound System, Lighting', 500000.00, TRUE, 50, 1),
('Green Screen, Lighting', 300000.00, TRUE, 30, 1),
('Basic Studio, Lighting', 200000.00, TRUE, 20, 2);

-- Tabel Peralatan
INSERT INTO Peralatan (Nama, Biaya, Ketersediaan, Kapasitas, ID_Admin)
VALUES
('Kamera DSLR', 150000.00, TRUE, 10, 1),
('Tripod Profesional', 50000.00, TRUE, 20, 1),
('Lighting Kit', 200000.00, TRUE, 5, 2),
('Reflector', 30000.00, TRUE, 15, 2),
('Green Screen', 100000.00, FALSE, 2, 1),
('Mic Wireless', 120000.00, TRUE, 8, 2);

-- Tabel Photographer
INSERT INTO Photographer (Nama, Biaya, Ketersediaan, Kapasitas, No_Telp, ID_Admin)
VALUES
('Alice Photographer', 100000.00, TRUE, 1, '081333444555', 1),
('Bob Photographer', 150000.00, TRUE, 1, '081666777888', 1),
('Charlie Photographer', 200000.00, TRUE, 1, '081999000111', 2);

-- Tabel Reservasi
INSERT INTO Reservasi (ID_Client, ID_Studio, Tanggal_Reservasi, Waktu_Mulai, Waktu_Selesai)
VALUES
(1, 1, '2024-12-05', '09:00:00', '11:00:00'),
(2, 2, '2024-12-06', '14:00:00', '16:00:00'),
(3, 3, '2024-12-07', '10:00:00', '12:00:00');

-- Tabel Pesan (untuk Photographer)
INSERT INTO Pesan (ID_Client, ID_Photographer, Tanggal_Pesan, Durasi_Pesan)
VALUES
(1, 1, '2024-12-05', '2 hours'),
(2, 2, '2024-12-06', '3 hours'),
(3, 3, '2024-12-07', '4 hours');

-- Tabel Pembayaran
INSERT INTO Pembayaran (ID_Client, Total_Pembayaran, Jenis_Pembayaran)
VALUES
(1, 700000.00, 'Credit Card'),
(2, 450000.00, 'Bank Transfer'),
(3, 600000.00, 'Cash');

-- Stored Procedure: register_user
CREATE OR REPLACE FUNCTION register_user(
    p_name VARCHAR,
    p_email VARCHAR,
    p_password VARCHAR
) RETURNS TABLE(id INT, name VARCHAR, email VARCHAR, password VARCHAR) AS
$$
BEGIN
    -- Insert user into the users table
    INSERT INTO users (name, email, password)
    VALUES (p_name, p_email, p_password)
    RETURNING id, name, email, password;
END;
$$ LANGUAGE plpgsql;

-- Stored Procedure: login_user
CREATE OR REPLACE FUNCTION login_user(
    p_email VARCHAR,
    p_password VARCHAR
) RETURNS TABLE(id INT, name VARCHAR, email VARCHAR, password VARCHAR, role VARCHAR) AS
$$
BEGIN
    -- Check if user exists with the given email and password
    RETURN QUERY
    SELECT id, name, email, password, role
    FROM users
    WHERE email = p_email AND password = p_password;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_studio()
RETURNS TABLE(id SERIAL, fasilitas VARCHAR, biaya DECIMAL, ketersediaan BOOLEAN, kapasitas INTEGER, id_admin INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT id, fasilitas, biaya, ketersediaan, kapasitas, id_admin
    FROM studio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reservasi_studio(
    p_id_client INT,
    p_id_studio INT,
    p_tanggal_reservasi DATE,
    p_waktu_mulai TIME,
    p_waktu_selesai TIME
)
RETURNS VOID AS $$
BEGIN
    BEGIN
        -- Mulai transaksi
        START TRANSACTION;

        -- Cek ketersediaan studio
        IF NOT EXISTS (
            SELECT 1 FROM Studio WHERE ID_Studio = p_id_studio AND Ketersediaan = TRUE
        ) THEN
            RAISE EXCEPTION 'Studio tidak tersedia!';
        END IF;

        -- Masukkan data reservasi
        INSERT INTO Reservasi (ID_Client, ID_Studio, Tanggal_Reservasi, Waktu_Mulai, Waktu_Selesai)
        VALUES (p_id_client, p_id_studio, p_tanggal_reservasi, p_waktu_mulai, p_waktu_selesai);

        -- Tandai studio sebagai tidak tersedia
        UPDATE Studio
        SET Ketersediaan = FALSE
        WHERE ID_Studio = p_id_studio;

        -- Commit transaksi jika semua berhasil
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback jika ada error
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_peralatan()
RETURNS TABLE(id SERIAL, nama VARCHAR, biaya DECIMAL, ketersediaan BOOLEAN, kapasitas INTEGER, id_admin INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT id, nama, biaya, ketersediaan, kapasitas, id_admin
    FROM peralatan;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sewa_peralatan(
    p_id_client INT,
    p_id_peralatan INT,
    p_jumlah INT
)
RETURNS VOID AS $$
BEGIN
    BEGIN
        -- Mulai transaksi
        START TRANSACTION;

        -- Cek ketersediaan peralatan
        IF NOT EXISTS (
            SELECT 1 FROM Peralatan WHERE ID_Peralatan = p_id_peralatan AND Ketersediaan = TRUE AND Kapasitas >= p_jumlah
        ) THEN
            RAISE EXCEPTION 'Peralatan tidak tersedia atau jumlah melebihi kapasitas!';
        END IF;

        -- Kurangi kapasitas peralatan
        UPDATE Peralatan
        SET Kapasitas = Kapasitas - p_jumlah,
            Ketersediaan = CASE WHEN Kapasitas - p_jumlah > 0 THEN TRUE ELSE FALSE END
        WHERE ID_Peralatan = p_id_peralatan;

        -- Tambahkan pembayaran
        INSERT INTO Pembayaran (ID_Client, Total_Pembayaran, Jenis_Pembayaran)
        VALUES (p_id_client, (SELECT Biaya * p_jumlah FROM Peralatan WHERE ID_Peralatan = p_id_peralatan), 'Sewa Peralatan');

        -- Commit transaksi jika semua berhasil
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback jika ada error
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_photographer()
RETURNS TABLE(id SERIAL, nama VARCHAR, biaya DECIMAL, ketersediaan BOOLEAN, kapasitas INTEGER, no_telp VARCHAR, id_admin INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT id, nama, biaya, ketersediaan, kapasitas, no_telp, id_admin
    FROM photographer;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pesan_photographer(
    p_id_client INT,
    p_id_photographer INT,
    p_tanggal_pesan DATE,
    p_durasi_pesan INTERVAL
)
RETURNS VOID AS $$
BEGIN
    BEGIN
        -- Mulai transaksi
        START TRANSACTION;

        -- Cek ketersediaan photographer
        IF NOT EXISTS (
            SELECT 1 FROM Photographer WHERE ID_Photographer = p_id_photographer AND Ketersediaan = TRUE
        ) THEN
            RAISE EXCEPTION 'Photographer tidak tersedia!';
        END IF;

        -- Tambahkan pemesanan photographer
        INSERT INTO Pesan (ID_Client, ID_Photographer, Tanggal_Pesan, Durasi_Pesan)
        VALUES (p_id_client, p_id_photographer, p_tanggal_pesan, p_durasi_pesan);

        -- Ubah status ketersediaan
        UPDATE Photographer
        SET Ketersediaan = FALSE
        WHERE ID_Photographer = p_id_photographer;

        -- Commit transaksi jika semua berhasil
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback jika ada error
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION tambah_studio(
    p_fasilitas TEXT,
    p_biaya NUMERIC,
    p_ketersediaan BOOLEAN,
    p_kapasitas INT,
    p_id_admin INT
)
RETURNS VOID AS $$
BEGIN
    BEGIN
        START TRANSACTION;

        INSERT INTO Studio (Fasilitas, Biaya, Ketersediaan, Kapasitas, ID_Admin)
        VALUES (p_fasilitas, p_biaya, p_ketersediaan, p_kapasitas, p_id_admin);

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION edit_studio(
    p_id_studio INT,
    p_fasilitas TEXT,
    p_biaya NUMERIC,
    p_ketersediaan BOOLEAN,
    p_kapasitas INT
)
RETURNS VOID AS $$
BEGIN
    BEGIN
        START TRANSACTION;

        UPDATE Studio
        SET Fasilitas = p_fasilitas,
            Biaya = p_biaya,
            Ketersediaan = p_ketersediaan,
            Kapasitas = p_kapasitas
        WHERE ID_Studio = p_id_studio;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION hapus_studio(p_id_studio INT)
RETURNS VOID AS $$
BEGIN
    BEGIN
        START TRANSACTION;

        DELETE FROM Studio WHERE ID_Studio = p_id_studio;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION tambah_peralatan(
    p_nama TEXT,
    p_biaya NUMERIC,
    p_ketersediaan BOOLEAN,
    p_kapasitas INT,
    p_id_admin INT
)
RETURNS VOID AS $$
BEGIN
    BEGIN
        START TRANSACTION;

        INSERT INTO Peralatan (Nama, Biaya, Ketersediaan, Kapasitas, ID_Admin)
        VALUES (p_nama, p_biaya, p_ketersediaan, p_kapasitas, p_id_admin);

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION edit_peralatan(
    p_id_peralatan INT,
    p_nama TEXT,
    p_biaya NUMERIC,
    p_ketersediaan BOOLEAN,
    p_kapasitas INT
)
RETURNS VOID AS $$
BEGIN
    BEGIN
        START TRANSACTION;

        UPDATE Peralatan
        SET Nama = p_nama,
            Biaya = p_biaya,
            Ketersediaan = p_ketersediaan,
            Kapasitas = p_kapasitas
        WHERE ID_Peralatan = p_id_peralatan;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION hapus_peralatan(p_id_peralatan INT)
RETURNS VOID AS $$
BEGIN
    BEGIN
        START TRANSACTION;

        DELETE FROM Peralatan WHERE ID_Peralatan = p_id_peralatan;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION tambah_photographer(
    p_nama TEXT,
    p_biaya NUMERIC,
    p_ketersediaan BOOLEAN,
    p_kapasitas INT,
    p_no_telp TEXT,
    p_id_admin INT
)
RETURNS VOID AS $$
BEGIN
    BEGIN
        START TRANSACTION;

        INSERT INTO Photographer (Nama, Biaya, Ketersediaan, Kapasitas, No_Telp, ID_Admin)
        VALUES (p_nama, p_biaya, p_ketersediaan, p_kapasitas, p_no_telp, p_id_admin);

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION edit_photographer(
    p_id_photographer INT,
    p_nama TEXT,
    p_biaya NUMERIC,
    p_ketersediaan BOOLEAN,
    p_kapasitas INT,
    p_no_telp TEXT
)
RETURNS VOID AS $$
BEGIN
    BEGIN
        START TRANSACTION;

        UPDATE Photographer
        SET Nama = p_nama,
            Biaya = p_biaya,
            Ketersediaan = p_ketersediaan,
            Kapasitas = p_kapasitas,
            No_Telp = p_no_telp
        WHERE ID_Photographer = p_id_photographer;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION hapus_photographer(p_id_photographer INT)
RETURNS VOID AS $$
BEGIN
    BEGIN
        START TRANSACTION;

        DELETE FROM Photographer WHERE ID_Photographer = p_id_photographer;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;
