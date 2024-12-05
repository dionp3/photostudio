const pool = require('../config/db');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');


// Register User dengan role
const register = async (req, res) => {
  const { username, password, role = 'user' } = req.body; // Role default 'user' jika tidak ada
  try {
    // Hash password menggunakan bcrypt
    const hashedPassword = await bcrypt.hash(password, 10); // 10 adalah jumlah salt rounds

    // Memanggil stored procedure registerUser dengan parameter username, hashedPassword, dan role
    await pool.query('CALL registerUser(?, ?, ?)', [username, hashedPassword, role]);
    res.status(201).json({ message: 'User registered successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Login User
const login = async (req, res) => {
  const { username, password } = req.body;
  try {
    // Memanggil stored procedure loginUser untuk memverifikasi username
    const [rows] = await pool.query('CALL loginUser(?, ?)', [username, password]);

    // Jika login gagal (misalnya username tidak ditemukan)
    if (rows[0].error) {
      return res.status(401).json({ error: rows[0].error });
    }

    const user = rows[0];
    
    // Verifikasi password dengan bcrypt
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Membuat token JWT yang mencakup id dan role
    const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '1h' });
    res.json({ token }); // Mengembalikan token ke pengguna
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = { register, login };
