const express = require('express');
const router = express.Router();
const {
  createRazorpayOrder,
  verifyRazorpayPayment,
} = require('../controllers/paymentController');
const { protect } = require('../middleware/authMiddleware');

console.log('💳 Payment routes initialized: /api/payment/razorpay/order & /api/payment/razorpay/verify');

// Primary & Fallback routes for POST /api/payment/razorpay/order
router.post('/razorpay/order', protect, createRazorpayOrder);
router.post('/order', protect, createRazorpayOrder);

// Primary & Fallback routes for POST /api/payment/razorpay/verify
router.post('/razorpay/verify', protect, verifyRazorpayPayment);
router.post('/verify', protect, verifyRazorpayPayment);

module.exports = router;
