const express = require('express');
const router = express.Router();
const {
  registerUser,
  loginUser,
  forgotPassword,
  verifyRememberAccess,
  resetPassword
} = require('../controllers/authController');

// Public routes
router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/forgot-password', forgotPassword);
router.post('/verify-remember-access', verifyRememberAccess);
router.post('/reset-password', resetPassword);

module.exports = router;
