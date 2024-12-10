const jwt = require('jsonwebtoken');

const authenticate = (req, res, next) => {
  const token = req.cookies['authToken'];
  if (!token) {
    return res.status(401).json({ error: 'Please login. Don\'t have an account? Register.' });
  }
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; 
    next();
  } catch (error) {
    res.status(403).json({ error: 'Invalid token' });
  }
};

const authorizeAdmin = (req, res, next) => {
  if (req.user && req.user.role === 'admin') {
    next();
  } else {
    res.status(403).json({ error: 'Access denied: Admins only' });
  }
};

module.exports = { authenticate, authorizeAdmin };