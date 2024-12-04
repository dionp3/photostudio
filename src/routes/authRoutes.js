const express = require("express");
const db = require("../config/db");

const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const router = express.Router();

// Register
router.post("/registers", async (req, res) => {
    const { nama, email, password } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);

    try {
        const result = await db.query("SELECT * FROM register_user($1, $2, $3)", [nama, email, hashedPassword]);
        const user = result.rows[0];  // Mengambil user yang baru didaftarkan
        res.status(201).json(user);  // Mengembalikan data user yang telah didaftarkan
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Login endpoint
router.post("/login", async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ error: "Email and password are required." });
    }

    try {
        // Panggil stored procedure login_user
        const result = await db.query("SELECT * FROM login_user($1)", [email]);
    
        // Jika user tidak ditemukan
        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Invalid email or password." });
        }

        const user = result.rows[0];

        // Validasi password menggunakan bcrypt
        const isValidPassword = await bcrypt.compare(password, user.password);
        if (!isValidPassword) {
            return res.status(401).json({ error: "Invalid email or password." });
        }

        // Generate JWT token
        const token = jwt.sign(
            { id: user.id, role: user.role },
            process.env.JWT_SECRET, // Pastikan variabel ini ada di file `.env`
            { expiresIn: "1h" }
        );

        // Response ke client
        return res.status(200).json({
            message: "Login successful",
            token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role
            }
        });
    } catch (err) {
        console.error("Error during login:", err.message);
        return res.status(500).json({ error: "An error occurred during login." });
    }
});

module.exports = router;
