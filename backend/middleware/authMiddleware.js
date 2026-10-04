const jwt = require('jsonwebtoken');
const User = require('../models/User');

/**
 * Middleware to protect routes by verifying JWT
 */
const protect = async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    try {
      // Get token from header
      token = req.headers.authorization.split(' ')[1];

      // Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // Get user from the token and attach to request object
      req.user = await User.findById(decoded.id).select('-password');

      if (!req.user) {
        return res.status(401).json({ success: false, message: 'User not found' });
      }

      // Explicitly return next() to avoid hanging requests or flow issues
      return next();
    } catch (error) {
      console.error('Auth Middleware Error:', error);
      return res.status(401).json({ success: false, message: 'Not authorized, token failed' });
    }
  }

  if (!token) {
    return res.status(401).json({ success: false, message: 'Not authorized, no token provided' });
  }
};

/**
 * Middleware for admin access verification
 */
const admin = (req, res, next) => {
  if (req.user) {
    console.log('--- ADMIN AUTHORIZATION CHECK ---');
    console.log('Authenticated user ID:', req.user._id);
    console.log('Authenticated user role:', req.user.role);
  }

  if (req.user && req.user.role === 'admin') {
    return next();
  } else {
    console.log('❌ AUTHORIZATION FAILED: User is not an admin');
    return res.status(403).json({ success: false, message: 'Not authorized as an admin' });
  }
};

module.exports = { protect, admin };
