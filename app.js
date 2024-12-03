const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const bodyParser = require("body-parser");
const userRoutes = require("./src/routes/userRoutes");
const adminRoutes = require("./src/routes/adminRoutes");
const authenticateJWT = require("./src/middleware/auth");  // Middleware JWT

dotenv.config();

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Rute untuk pengguna
app.use("/api/users", userRoutes);

// Rute untuk admin (menggunakan autentikasi JWT)
app.use("/api/admin", authenticateJWT, adminRoutes);

app.get("/", (req, res) => {
  res.send("API berjalan dengan baik!");
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
