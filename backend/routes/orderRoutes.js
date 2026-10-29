const express = require('express');
const router = express.Router();
const {
  addOrderItems,
  getOrderById,
  updateOrderToPaid,
  getMyOrders,
  getOrders,
  updateOrderStatus,
  requestOrderCancellation,
  approveOrderCancellation,
  rejectOrderCancellation,
} = require('../controllers/orderController');
const { protect, admin } = require('../middleware/authMiddleware');

router.route('/')
  .post(protect, addOrderItems)
  .get(protect, admin, getOrders);

router.route('/my-orders').get(protect, getMyOrders);

router.route('/:id').get(protect, getOrderById);

router.route('/:id/pay').put(protect, updateOrderToPaid);

router.route('/:id/status').put(protect, admin, updateOrderStatus);

// Customer Cancellation Request
router.route('/:id/cancel-request').put(protect, requestOrderCancellation);

// Admin Cancellation Approval & Rejection
router.route('/:id/approve-cancellation').put(protect, admin, approveOrderCancellation);
router.route('/:id/reject-cancellation').put(protect, admin, rejectOrderCancellation);

module.exports = router;
