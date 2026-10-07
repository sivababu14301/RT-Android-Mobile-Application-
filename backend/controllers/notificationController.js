const Notification = require('../models/Notification');
const User = require('../models/User');

// @desc    Get user notifications
// @route   GET /api/notifications
// @access  Private
exports.getNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ userId: req.user._id })
      .sort({ createdAt: -1 })
      .limit(50);
    return res.status(200).json({ success: true, notifications });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get unread notifications count
// @route   GET /api/notifications/unread-count
// @access  Private
exports.getUnreadCount = async (req, res) => {
  try {
    const count = await Notification.countDocuments({
      userId: req.user._id,
      isRead: false
    });
    return res.status(200).json({ success: true, count });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Mark notification as read
// @route   PUT /api/notifications/:id/read
// @access  Private
exports.markAsRead = async (req, res) => {
  try {
    const notification = await Notification.findById(req.params.id);
    if (!notification) {
      return res.status(404).json({ success: false, message: 'Notification not found' });
    }
    notification.isRead = true;
    await notification.save();
    return res.status(200).json({ success: true, notification });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Clear all notifications for user
// @route   DELETE /api/notifications/clear-all
// @access  Private
exports.clearAllNotifications = async (req, res) => {
  try {
    await Notification.deleteMany({ userId: req.user._id });
    return res.status(200).json({ success: true, message: 'Notifications cleared' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Send admin notification
// @route   POST /api/admin/notifications
// @access  Private/Admin
exports.sendAdminNotification = async (req, res) => {
  try {
    const { userId, sendToAll, title, message } = req.body;

    if (sendToAll || userId === 'all') {
      const users = await User.find({ role: 'customer' }).select('_id');
      const notifs = users.map(u => ({
        userId: u._id,
        title,
        message,
        type: 'admin_broadcast',
        sender: 'admin'
      }));
      await Notification.insertMany(notifs);
    } else {
      await Notification.create({
        userId,
        title,
        message,
        type: 'admin_direct',
        sender: 'admin'
      });
    }

    return res.status(201).json({ success: true, message: 'Notification sent successfully' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};
