const express = require("express");
const db = require("../config/db");

const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const authenticateToken = require("../middleware/auth");
const router = express.Router();



// Fungsi untuk melihat daftar studio menggunakan stored procedure
router.get('/studio', async (req, res) => {
    try {
        const result = await db.query('SELECT * FROM get_studio()');
        res.status(200).json(result.rows); // Mengirimkan data sebagai response JSON
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Terjadi kesalahan saat mengambil daftar studio' });
    }
});

// Fungsi untuk melakukan reservasi studio
router.post('/reservasi', async (req, res) => {
    const { id_studio, id_client, tanggal_reservasi, waktu_mulai, waktu_selesai } = req.body;
    try {
        const result = await db.query('SELECT reservasi_studio($1, $2, $3, $4, $5)', [id_studio, id_client, tanggal_reservasi, waktu_mulai, waktu_selesai]);
        res.status(201).json({ message: 'Reservasi studio berhasil' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Terjadi kesalahan saat melakukan reservasi' });
    }
});

// Fungsi untuk melihat daftar peralatan menggunakan stored procedure
router.get('/peralatan', async (req, res) => {
    try {
        const result = await db.query('SELECT * FROM get_peralatan()');
        res.status(200).json(result.rows); // Mengirimkan data sebagai response JSON
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Terjadi kesalahan saat mengambil daftar peralatan' });
    }
});

// Fungsi untuk sewa peralatan
router.post('/sewa', async (req, res) => {
    const { id_peralatan, id_client, durasi_sewa } = req.body;
    try {
        const result = await db.query('SELECT sewa_peralatan($1, $2, $3)', [id_peralatan, id_client, durasi_sewa]);
        res.status(201).json({ message: 'Peralatan berhasil disewa' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Terjadi kesalahan saat menyewa peralatan' });
    }
});

// Fungsi untuk melihat daftar photographer menggunakan stored procedure
router.get('/photographer', async (req, res) => {
    try {
        const result = await db.query('SELECT * FROM get_photographer()');
        res.status(200).json(result.rows); // Mengirimkan data sebagai response JSON
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Terjadi kesalahan saat mengambil daftar photographer' });
    }
});

// Fungsi untuk pesan photographer
router.post('/pesan', async (req, res) => {
    const { id_photographer, id_client, tanggal_pesan, durasi_pesan } = req.body;
    try {
        const result = await db.query('SELECT pesan_photographer($1, $2, $3, $4)', [id_photographer, id_client, tanggal_pesan, durasi_pesan]);
        res.status(201).json({ message: 'Photographer berhasil dipesan' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Terjadi kesalahan saat memesan photographer' });
    }
});

// Fungsi untuk pembayaran
router.post('/pembayaran', async (req, res) => {
    const { id_transaksi, jumlah_bayar, metode_bayar, id_client } = req.body;
    try {
        const result = await db.query('SELECT pembayaran($1, $2, $3, $4)', [id_transaksi, jumlah_bayar, metode_bayar, id_client]);
        res.status(201).json({ message: 'Pembayaran berhasil' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Terjadi kesalahan saat melakukan pembayaran' });
    }
});

module.exports = router;
