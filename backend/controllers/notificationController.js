const Notification = require('../models/Notification');
const User = require('../models/User');
const mongoose = require('mongoose');

// @desc    Get all notifications for logged in user
// @route   GET /api/notifications
// @access  Private
exports.getNotifications = async (req, res) => {
  try {
    const rawUserId = req.user.id || req.user._id;
    const notifications = await Notification.find({
      $or: [
        { userId: rawUserId },
        { userId: rawUserId.toString() },
        ...(mongoose.Types.ObjectId.isValid(rawUserId) ? [{ userId: new mongoose.Types.ObjectId(rawUserId) }] : [])
      ]
    }).sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: notifications.length,
      notifications
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server Error',
      error: error.message
    });
  }
};

// @desc    Mark notification as read
// @route   PUT /api/notifications/:id/read
// @access  Private
exports.markAsRead = async (req, res) => {
  try {
    let notification = await Notification.findById(req.params.id);

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found'
      });
    }

    if (notification.userId.toString() !== req.user.id.toString()) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized'
      });
    }

    notification.isRead = true;
    await notification.save();

    res.status(200).json({
      success: true,
      notification
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server Error',
      error: error.message
    });
  }
};

// @desc    Mark all notifications as read
// @route   PUT /api/notifications/read-all
// @access  Private
exports.markAllAsRead = async (req, res) => {
  try {
    const rawUserId = req.user.id || req.user._id;
    await Notification.updateMany(
      {
        $or: [
          { userId: rawUserId },
          { userId: rawUserId.toString() },
          ...(mongoose.Types.ObjectId.isValid(rawUserId) ? [{ userId: new mongoose.Types.ObjectId(rawUserId) }] : [])
        ],
        isRead: false
      },
      { $set: { isRead: true } }
    );

    res.status(200).json({
      success: true,
      message: 'All notifications marked as read'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server Error: ' + error.message
    });
  }
};

// @desc    Send notification to a specific user or all users (Admin only)
// @route   POST /api/admin/notifications
// @access  Private/Admin
exports.sendNotification = async (req, res) => {
  try {
    const { userId, targetType, title, message, sendToAll } = req.body;

    if (!title || !message) {
      return res.status(400).json({
        success: false,
        message: 'Please provide title and message'
      });
    }

    const isBroadcast =
      targetType === 'all' ||
      sendToAll === true ||
      !userId ||
      userId === 'all' ||
      userId === 'ALL' ||
      userId.toString().toLowerCase() === 'all';

    if (isBroadcast) {
      const users = await User.find({});
      if (users.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'No users found'
        });
      }

      const notifications = users.map(user => ({
        userId: user._id,
        title,
        message,
        sender: 'admin',
        isRead: false,
        createdAt: new Date()
      }));

      await Notification.insertMany(notifications);

      return res.status(201).json({
        success: true,
        message: `Message broadcasted to all ${users.length} users successfully!`
      });
    } else {
      if (!mongoose.Types.ObjectId.isValid(userId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid user ID format'
        });
      }

      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'Customer not found'
        });
      }

      const notification = await Notification.create({
        userId,
        title,
        message,
        sender: 'admin'
      });

      return res.status(201).json({
        success: true,
        notification,
        message: `Message sent to ${user.fullName || user.email} successfully!`
      });
    }
  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).json({
      success: false,
      message: 'Server Error: ' + error.message
    });
  }
};

// @desc    Get unread count for logged in user
// @route   GET /api/notifications/unread-count
// @access  Private
exports.getUnreadCount = async (req, res) => {
  try {
    const rawUserId = req.user.id || req.user._id;
    const count = await Notification.countDocuments({
      $or: [
        { userId: rawUserId },
        { userId: rawUserId.toString() },
        ...(mongoose.Types.ObjectId.isValid(rawUserId) ? [{ userId: new mongoose.Types.ObjectId(rawUserId) }] : [])
      ],
      isRead: false
    });

    res.status(200).json({
      success: true,
      count
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server Error',
      error: error.message
    });
  }
};

// @desc    Clear all notifications for logged in user
// @route   DELETE /api/notifications/clear-all
// @access  Private
exports.clearAllNotifications = async (req, res) => {
  try {
    const rawUserId = req.user.id || req.user._id;
    const deleteResult = await Notification.deleteMany({
      $or: [
        { userId: rawUserId },
        { userId: rawUserId.toString() },
        ...(mongoose.Types.ObjectId.isValid(rawUserId) ? [{ userId: new mongoose.Types.ObjectId(rawUserId) }] : [])
      ]
    });

    console.log(`✅ DELETED NOTIFICATIONS FOR USER ${rawUserId}: ${deleteResult.deletedCount}`);

    res.status(200).json({
      success: true,
      deletedCount: deleteResult.deletedCount,
      message: 'All notifications cleared successfully'
    });
  } catch (error) {
    console.error('❌ CLEAR ALL NOTIFICATIONS ERROR:', error);
    res.status(500).json({
      success: false,
      message: 'Server Error: ' + error.message
    });
  }
};
