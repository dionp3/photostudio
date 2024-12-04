const jwt = require("jsonwebtoken");

// Middleware untuk memverifikasi token JWT
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1]; // Mengambil token setelah "Bearer"

    if (!token) {
        return res.status(401).json({ error: "Access denied" });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ error: "Invalid token" });
        }
        req.user = user; // Menyimpan data user ke req untuk digunakan di endpoint lain
        next();
    });
};

// Middleware tambahan untuk memastikan hanya admin yang dapat mengakses endpoint tertentu
const authorizeAdmin = (req, res, next) => {
    if (!req.user || req.user.role !== "Admin") {
        return res.status(403).json({ error: "Access restricted to admins only" });
    }
    next();
};

module.exports = {
    authenticateToken,
    authorizeAdmin,
};