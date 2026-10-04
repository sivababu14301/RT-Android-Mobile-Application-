import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String? orderId;
  final String title;
  final String message;
  final String type;
  final String sender;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    this.orderId,
    required this.title,
    required this.message,
    this.type = 'order_status',
    required this.sender,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      orderId: json['orderId'] is Map ? (json['orderId']['_id'] ?? json['orderId']['id']) : json['orderId']?.toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'order_status',
      sender: json['sender'] ?? 'system',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orderId': orderId,
      'title': title,
      'message': message,
      'type': type,
      'sender': sender,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  IconData get getIcon {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('ready') || lowerTitle.contains('delivery')) return Icons.local_shipping_outlined;
    if (lowerTitle.contains('stitch')) return Icons.content_cut;
    if (lowerTitle.contains('confirm')) return Icons.check_circle_outline;
    if (lowerTitle.contains('order')) return Icons.inventory_2_outlined;
    if (lowerTitle.contains('offer') || lowerTitle.contains('discount')) return Icons.celebration_outlined;
    return Icons.notifications_outlined;
  }
}
