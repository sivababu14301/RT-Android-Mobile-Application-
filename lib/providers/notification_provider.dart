import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service = NotificationService();
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _service.getNotifications(token);
      _unreadCount = await _service.getUnreadCount(token);
    } catch (e) {
      debugPrint('Error in NotificationProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id, String token) async {
    final success = await _service.markAsRead(id, token);
    if (success) {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          title: _notifications[index].title,
          message: _notifications[index].message,
          sender: _notifications[index].sender,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        if (_unreadCount > 0) _unreadCount--;
        notifyListeners();
      }
    }
  }

  Future<bool> clearAllNotifications(String token) async {
    final success = await _service.clearAllNotifications(token);
    if (success) {
      _notifications = [];
      _unreadCount = 0;
      notifyListeners();
    }
    return success;
  }

  Future<Map<String, dynamic>> sendAdminMessage({
    required String userId,
    required String title,
    required String message,
    required String token,
  }) async {
    return await _service.sendAdminNotification(
      userId: userId,
      title: title,
      message: message,
      token: token,
    );
  }
}
