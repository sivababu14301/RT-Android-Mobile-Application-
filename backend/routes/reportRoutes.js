const express = require('express');
const router = express.Router();
const {
  getSummary,
  getRevenueTrend,
  getOrdersTrend,
  getTopProducts,
  getSalesSummary,
  getPaymentMethodsReport
} = require('../controllers/reportController');
const { protect, admin } = require('../middleware/authMiddleware');

router.use(protect);
router.use(admin);

// Summary overview
router.get('/summary', getSummary);

// Map to exact names requested by user
router.get('/revenue', getSummary); // Return the revenue summary
router.get('/sales-summary', getSalesSummary);
router.get('/payment-methods', getPaymentMethodsReport);
router.get('/top-products', getTopProducts);

// Trend data
router.get('/revenue-trend', getRevenueTrend);
router.get('/orders-trend', getOrdersTrend);

module.exports = router;
