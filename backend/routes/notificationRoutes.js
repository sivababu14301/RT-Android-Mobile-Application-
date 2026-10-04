const express = require('express');
const router = express.Router();
const {
  getNotifications,
  markAsRead,
  markAllAsRead,
  getUnreadCount,
  sendNotification,
  clearAllNotifications
} = require('../controllers/notificationController');
const { protect, admin } = require('../middleware/authMiddleware');

// User routes
router.get('/', protect, getNotifications);
router.get('/unread-count', protect, getUnreadCount);
router.put('/read-all', protect, markAllAsRead);
router.put('/:id/read', protect, markAsRead);
router.delete('/clear-all', protect, clearAllNotifications);
router.delete('/', protect, clearAllNotifications);

// Admin routes
router.post('/', protect, admin, sendNotification);
router.post('/admin-send', protect, admin, sendNotification); // fallback

module.exports = router;
