const pool = require('../config/db');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { sendResetPasswordEmail } = require('../utils/emailService');



const register = async (req, res) => {
  const { username, email, password, role = 'user' } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    await pool.query('CALL registerUser(?, ?, ?, ?)', [username, email, hashedPassword, role]);
    res.status(201).json({ message: 'User registered successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};



const registerAdmin = async (req, res) => {
  const { username, email, password, role = 'admin' } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    await pool.query('CALL registerUser(?, ?, ?, ?)', [username, email, hashedPassword, role]);
    res.status(201).json({ message: 'Admin registered successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};



const login = async (req, res) => {
  const { username, password } = req.body;

  try {
    const [rows] = await pool.query('Call loginUser(?, ?)', [username, password]);

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Account not found' });
    }

    const user = rows[0];
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Invalid password' });
    }

    const token = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );

    res.cookie('authToken', token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      maxAge: 3600000,
      sameSite: 'strict',
    });

    res.json({ message: 'Login successful' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
};



const logout = (req, res) => {
  const authToken = req.cookies.authToken;

  if (!authToken) {
    return res.status(400).json({ message: 'You are already logged out' });
  }

  res.clearCookie('authToken', {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'Strict',
  });

  res.status(200).json({ message: 'Logged out successfully' });
};



const profile = async (req, res) => {
  const { id } = req.user;

  try {
    const [rows] = await pool.query('CALL getUserById(?)', [id]);

    if (rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const { password, ...userProfile } = rows[0];
    res.json({ data: userProfile });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
};



const deleteAccount = async (req, res) => {
  const { id } = req.user;

  try {
    await pool.query('CALL deleteUserById(?)', [id]);

    res.clearCookie('authToken');
    res.status(200).json({ message: 'Account deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete account' });
  }
};



const requestForgotPassword = async (req, res) => {
  const { email } = req.body;

  try {
    const [rows] = await pool.query('CALL getUserByEmail(?)', [email]);

    if (rows.length === 0) {
      return res.status(200).json({ message: 'If this email exists, a reset link has been sent.' });
    }

    const user = rows[0];
    const resetToken = jwt.sign({ email: user.email }, process.env.JWT_SECRET, { expiresIn: '15m' });

    await sendResetPasswordEmail(user.email, resetToken);
    res.status(200).json({ message: 'Reset link sent to your email.' });
  } catch (error) {
    console.error('Error in requestForgotPassword:', error);
    res.status(500).json({ error: 'Failed to process request' });
  }
};



const forgotPassword = async (req, res) => {
  const { token, newPassword } = req.body;

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    await pool.query('CALL forgotPassword(?, ?)', [decoded.email, hashedPassword]);
    res.status(200).json({ message: 'Password has been reset successfully.' });
  } catch (error) {
    console.error('Error in forgotPassword:', error);
    res.status(400).json({ error: 'Invalid or expired token' });
  }
};



const editProfile = async (req, res) => {
  const { username, email, password } = req.body;
  const userId = req.user.id;

  try {
    let hashedPassword = null;

    if (password) {
      hashedPassword = await bcrypt.hash(password, 10);
    }

    await pool.query('CALL editProfile(?, ?, ?, ?)', [userId, username, email, hashedPassword]);

    res.status(200).json({
      message: 'Profile updated successfully.',
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to update profile' });
  }
};



module.exports = {
  register,
  registerAdmin,
  login,
  logout,
  profile,
  deleteAccount,
  requestForgotPassword,
  forgotPassword,
  editProfile,
};
