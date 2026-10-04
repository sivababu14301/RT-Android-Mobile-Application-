import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/notification_model.dart';

class NotificationService {
  static String get _baseUrl => ApiConfig.baseUrl;

  late final Dio _dio;

  NotificationService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    _dio.interceptors.add(ApiConfig.retryInterceptor);
  }

  Future<List<NotificationModel>> getNotifications(String token) async {
    try {
      final response = await _dio.get(
        'notifications',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List notificationsJson = response.data['notifications'];
        return notificationsJson.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  Future<int> getUnreadCount(String token) async {
    try {
      final response = await _dio.get(
        'notifications/unread-count',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> markAsRead(String notificationId, String token) async {
    try {
      final response = await _dio.put(
        'notifications/$notificationId/read',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> sendAdminNotification({
    required String userId,
    required String title,
    required String message,
    required String token,
  }) async {
    try {
      final bool isBroadcast = userId == 'all' || userId.toLowerCase() == 'all';
      final response = await _dio.post(
        'admin/notifications',
        data: {
          'userId': isBroadcast ? 'all' : userId,
          'targetType': isBroadcast ? 'all' : 'single',
          'sendToAll': isBroadcast,
          'title': title,
          'message': message,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => true,
        ),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data is Map ? response.data['message'] : 'Message sent successfully'
        };
      } else {
        return {
          'success': false,
          'message': response.data != null && response.data is Map
              ? response.data['message'] ?? 'Failed to send message'
              : 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<bool> clearAllNotifications(String token) async {
    try {
      final response = await _dio.delete(
        'notifications/clear-all',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error clearing all notifications: $e');
      return false;
    }
  }
}
