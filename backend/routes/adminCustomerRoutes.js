const express = require('express');
const router = express.Router();
const {
  getCustomers,
  getCustomerById,
  getCustomerOrders,
  getCustomerMeasurements
} = require('../controllers/adminController');
const { protect, admin } = require('../middleware/authMiddleware');

// Base URL: /api/admin/customers

router.get('/', protect, admin, getCustomers);
router.get('/:id', protect, admin, getCustomerById);
router.get('/:id/orders', protect, admin, getCustomerOrders);
router.get('/:id/measurements', protect, admin, getCustomerMeasurements);

module.exports = router;
