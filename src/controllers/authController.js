const pool = require('../config/db');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { sendResetPasswordEmail } = require('../utils/emailService');



const register = async (req, res) => {
  const { username, email, password, role = 'user' } = req.body;

  try {
    await pool.query('CALL registerUser(?, ?, ?, ?)', [username, email, password, role]);
    res.status(201).json({ message: 'User registered successfully' });
  } catch (err) {
    if (err.sqlState === '45000') {
      res.status(400).json({ error: err.sqlMessage });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
};



const registerAdmin = async (req, res) => {
  const { username, email, password, role = 'admin' } = req.body;

  try {
    await pool.query('CALL registerUser(?, ?, ?, ?)', [username, email, password, role]);
    res.status(201).json({ message: 'User registered successfully' });
  } catch (err) {
    if (err.sqlState === '45000') {
      res.status(400).json({ error: err.sqlMessage }); 
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
};



const login = async (req, res) => {
  const { username, password } = req.body;

  try {
    const [rows] = await pool.query('CALL loginUser(?, ?)', [username, password]);

    if (rows.length === 0) {
      return res.status(401).json({ error: 'Invalid username or password' });
    }

    const user = rows[0]?.[0];  

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

    res.json({
      message: 'Login successful',
      user: {
        id: user.id,
        username: user.username,
        email: user.email, 
        role: user.role,
      },
      token,  
    });

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
  try {
    const { id, role } = req.user;

    if (!id) {
      return res.status(400).json({ error: 'Invalid user ID' });
    }

    const [results] = await pool.query('CALL getUserById(?)', [id]);

    if (!results || !results[0] || results[0].length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const userProfile = rows[0]?.[0];
    
    res.status(200).json({ data: userProfile });
  } catch (err) {
    console.error('Error in profile method:', err);

    if (err.code === 'ER_TABLEACCESS_DENIED_ERROR') {
      return res.status(403).json({ error: 'Access to the table is denied' });
    }

    res.status(500).json({ error: 'Internal server error' });
  }
};



const getProfile = async (req, res) => {
  const userId = req.user.id;

  try {
    const [rows] = await pool.query('CALL GetUserById(?)', [userId]);
    console.log('User ID from token:', req.user.id);


    if (rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = rows[0]; 
    
    return res.json({ user });
  } catch (error) {
    console.error('Error fetching user profile:', error);
    
    return res.status(500).json({ error: 'Internal server error' });
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
    await pool.query('CALL editProfile(?, ?, ?, ?)', [
      userId,
      username,
      email,
      password || null, 
    ]);

    res.status(200).json({
      message: 'Profile updated successfully.',
    });
  } catch (error) {
    if (error.sqlState === '45000') {
      return res.status(400).json({ error: error.sqlMessage });
    }
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
  getProfile,
  deleteAccount,
  requestForgotPassword,
  forgotPassword,
  editProfile,
};
