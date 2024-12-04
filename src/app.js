const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const bodyParser = require("body-parser");
const authRoutes = require("./routes/authRoutes");
const userRoutes = require("./routes/userRoutes");
const adminRoutes = require("./routes/adminRoutes");
const { authenticateToken, authorizeAdmin } = require("./middleware/auth"); // Middleware JWT

dotenv.config();

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Rute untuk autentikasi
app.use("/api/auth", authRoutes);

// Rute untuk pengguna
app.use("/api/user", userRoutes);

// Rute untuk admin (dengan autentikasi JWT)
app.use("/api/admin", adminRoutes);

// Root endpoint
app.get("/", (res) => {
  res.send("API berjalan dengan baik!");
});

// Menangani rute yang tidak ditemukan
app.use((req, res) => {
  res.status(404).json({ message: "Rute tidak ditemukan." });
});

// Menangani kesalahan umum
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: "Terjadi kesalahan pada server." });
});

// Menjalankan server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server berjalan pada port ${PORT}`);
});
