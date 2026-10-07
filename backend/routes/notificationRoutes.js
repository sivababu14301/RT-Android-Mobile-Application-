const express = require('express');
const router = express.Router();
const {
  getNotifications,
  getUnreadCount,
  markAsRead,
  clearAllNotifications,
  sendAdminNotification
} = require('../controllers/notificationController');
const { protect, admin } = require('../middleware/authMiddleware');

router.get('/', protect, getNotifications);
router.get('/unread-count', protect, getUnreadCount);
router.put('/:id/read', protect, markAsRead);
router.delete('/clear-all', protect, clearAllNotifications);
router.post('/', protect, admin, sendAdminNotification);

module.exports = router;
