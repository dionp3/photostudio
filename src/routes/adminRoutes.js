const express = require("express");
const db = require("../config/db");
const authenticateToken = require("../middleware/auth");

const router = express.Router();

// Middleware khusus admin
const authorizeAdmin = (req, res, next) => {
    if (req.user.role !== "admin") {
        return res.status(403).json({ error: "Forbidden" });
    }
    next();
};

// Fungsi untuk menambah studio
router.post('/studio', async (req, res) => {
    const { nama, fasilitas, biaya, kapasitas, id_admin } = req.body;
    try {
        const result = await pool.query('SELECT tambah_studio($1, $2, $3, $4, $5)', [nama, fasilitas, biaya, kapasitas, id_admin]);
        res.status(201).json({ message: 'Studio berhasil ditambahkan' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Terjadi kesalahan saat menambahkan studio' });
    }
});

// Fungsi untuk mengedit studio
router.put('/studio/:id', async (req, res) => {
    const { id } = req.params;
    const { nama, fasilitas, biaya, kapasitas } = req.body;
    try {
        const result = await pool.query('SELECT edit_studio($1, $2, $3, $4, $5)', [id, nama, fasilitas, biaya, kapasitas]);
        res.status(200).json({ message: 'Studio berhasil diperbarui' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Terjadi kesalahan saat memperbarui studio' });
    }
});

// Fungsi untuk menghapus studio
router.delete('/studio/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query('SELECT hapus_studio($1)', [id]);
        res.status(200).json({ message: 'Studio berhasil dihapus' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Terjadi kesalahan saat menghapus studio' });
    }
});

// Fungsi untuk menambah peralatan
router.post('/peralatan', async (req, res) => {
    const { nama, biaya, ketersediaan, kapasitas, id_admin } = req.body;
    try {
        const result = await pool.query('SELECT tambah_peralatan($1, $2, $3, $4, $5)', [nama, biaya, ketersediaan, kapasitas, id_admin]);
        res.status(201).json({ message: 'Peralatan berhasil ditambahkan' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Terjadi kesalahan saat menambahkan peralatan' });
    }
});

// Fungsi untuk mengedit peralatan
router.put('/peralatan/:id', async (req, res) => {
    const { id } = req.params;
    const { nama, biaya, ketersediaan, kapasitas } = req.body;
    try {
        const result = await pool.query('SELECT edit_peralatan($1, $2, $3, $4, $5)', [id, nama, biaya, ketersediaan, kapasitas]);
        res.status(200).json({ message: 'Peralatan berhasil diperbarui' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Terjadi kesalahan saat memperbarui peralatan' });
    }
});

// Fungsi untuk menghapus peralatan
router.delete('/peralatan/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query('SELECT hapus_peralatan($1)', [id]);
        res.status(200).json({ message: 'Peralatan berhasil dihapus' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Terjadi kesalahan saat menghapus peralatan' });
    }
});

// Fungsi untuk menambah photographer
router.post('/photographer', async (req, res) => {
    const { nama, biaya, ketersediaan, kapasitas, no_telp, id_admin } = req.body;
    try {
        const result = await pool.query('SELECT tambah_photographer($1, $2, $3, $4, $5, $6)', [nama, biaya, ketersediaan, kapasitas, no_telp, id_admin]);
        res.status(201).json({ message: 'Photographer berhasil ditambahkan' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Terjadi kesalahan saat menambahkan photographer' });
    }
});

// Fungsi untuk mengedit photographer
router.put('/photographer/:id', async (req, res) => {
    const { id } = req.params;
    const { nama, biaya, ketersediaan, kapasitas, no_telp } = req.body;
    try {
        const result = await pool.query('SELECT edit_photographer($1, $2, $3, $4, $5, $6)', [id, nama, biaya, ketersediaan, kapasitas, no_telp]);
        res.status(200).json({ message: 'Photographer berhasil diperbarui' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Terjadi kesalahan saat memperbarui photographer' });
    }
});

// Fungsi untuk menghapus photographer
router.delete('/photographer/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query('SELECT hapus_photographer($1)', [id]);
        res.status(200).json({ message: 'Photographer berhasil dihapus' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Terjadi kesalahan saat menghapus photographer' });
    }
});

module.exports = router;
