const jwt = require('jsonwebtoken');

const authenticate = (req, res, next) => {
  const token = req.cookies.authToken || req.headers['authorization']?.split(' ')[1]; 

  if (!token) {
    return res.status(401).json({ error: 'Please login first. Dont have an account? Register new account.' });
  }

  try {
    const decodedToken = jwt.verify(token, process.env.JWT_SECRET);
    console.log('Decoded Token:', decodedToken);  
    req.user = decodedToken;
    next();
  } catch (err) {
    console.error('JWT Verification Error:', err); 
    res.status(403).json({ error: 'Please login first. Dont have an account? Register new account.' });
  }
};

const authorizeAdmin = (req, res, next) => {
  if (req.user.role === 'admin') {
    next();
  } else {
    res.status(403).json({ error: 'Access denied: Admins only' });
  }
};

module.exports = { authenticate, authorizeAdmin };