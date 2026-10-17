import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/offer_model.dart';
import '../models/notification_model.dart';
import '../screens/customer/offers_screen.dart';
import '../screens/notifications/notification_screen.dart';
import '../screens/tracking/order_tracking_screen.dart';

class LocalNotificationService {
  static final LocalNotificationService instance = LocalNotificationService._internal();
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static const String _channelId = 'raymaans_tailors_offers';
  static const String _channelName = 'Raymaans Tailors Notifications';
  static const String _channelDescription = 'Local notifications for order updates and exclusive offers from Raymaans Tailors';

  static const String _prefsKeyShownOffers = 'seen_offer_notification_ids';
  static const String _prefsKeyShownInAppNotifs = 'seen_inapp_notification_ids';

  GlobalKey<NavigatorState>? _navigatorKey;

  void setNavigatorKey(GlobalKey<NavigatorState> navKey) {
    _navigatorKey = navKey;
  }

  /// Initialize Local Notification Plugin & Create Android High Importance Channel
  Future<void> initialize() async {
    try {
      const AndroidInitializationSettings androidInitSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings =
          InitializationSettings(android: androidInitSettings);

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            _handleNotificationTap(response.payload!);
          }
        },
      );

      // Request Android 13+ Notification Permission
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // Create Android High Importance Notification Channel
      const AndroidNotificationChannel androidChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      debugPrint("✅ [LOCAL NOTIFICATIONS] Initialized successfully.");
    } catch (e) {
      debugPrint("❌ [LOCAL NOTIFICATIONS INIT ERROR]: $e");
    }
  }

  /// Check fetched active offers against locally saved shown offer IDs
  /// Triggers ONE local notification for any new/unseen offer.
  Future<void> checkAndNotifyNewOffers(List<OfferModel> offers) async {
    try {
      if (offers.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      List<String> shownOfferIds = prefs.getStringList(_prefsKeyShownOffers) ?? [];

      bool updated = false;

      for (var offer in offers) {
        if (offer.isEffectivelyActive && !shownOfferIds.contains(offer.id)) {
          debugPrint("🔔 [LOCAL NOTIFICATION] New unseen offer detected: ${offer.offerName}");

          await _showOfferNotification(offer);

          shownOfferIds.add(offer.id);
          updated = true;
        }
      }

      if (updated) {
        await prefs.setStringList(_prefsKeyShownOffers, shownOfferIds);
      }
    } catch (e) {
      debugPrint("❌ [CHECK OFFERS ERROR]: $e");
    }
  }

  /// Check fetched in-app MongoDB notifications against locally saved shown notification IDs
  /// Triggers ONE local notification for any unread/unseen notification.
  Future<void> checkAndNotifyInAppNotifications(List<NotificationModel> notifications) async {
    try {
      if (notifications.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      List<String> shownNotifIds = prefs.getStringList(_prefsKeyShownInAppNotifs) ?? [];

      bool updated = false;

      for (var notif in notifications) {
        if (!notif.isRead && !shownNotifIds.contains(notif.id)) {
          debugPrint("🔔 [LOCAL NOTIFICATION] New unseen in-app notification: ${notif.title}");

          await _showInAppLocalNotification(notif);

          shownNotifIds.add(notif.id);
          updated = true;
        }
      }

      if (updated) {
        await prefs.setStringList(_prefsKeyShownInAppNotifs, shownNotifIds);
      }
    } catch (e) {
      debugPrint("❌ [CHECK INAPP NOTIFS ERROR]: $e");
    }
  }

  Future<void> _showOfferNotification(OfferModel offer) async {
    try {
      final int notificationId = offer.id.hashCode;
      final String title = 'Raymaans Tailors';
      final String body = '🎉 New Exclusive Offer! Check out ${offer.offerName} (${offer.discount}).';

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        notificationId,
        title,
        body,
        details,
        payload: 'type=offer&offer_id=${offer.id}',
      );
    } catch (e) {
      debugPrint("❌ [SHOW NOTIFICATION ERROR]: $e");
    }
  }

  Future<void> _showInAppLocalNotification(NotificationModel notif) async {
    try {
      final int notificationId = notif.id.hashCode;
      final String title = notif.title.isNotEmpty ? notif.title : 'Raymaans Tailors';
      final String body = notif.message;

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

      String payload = 'notif_id=${notif.id}&type=${notif.type}';
      if (notif.orderId != null && notif.orderId!.isNotEmpty) {
        payload += '&orderId=${notif.orderId}';
      }

      await _localNotifications.show(
        notificationId,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint("❌ [SHOW INAPP NOTIFICATION ERROR]: $e");
    }
  }

  void _handleNotificationTap(String payload) {
    debugPrint("🖱️ [NOTIFICATION TAP] Payload: $payload");
    if (_navigatorKey?.currentState == null) return;

    if (payload.contains('orderId=')) {
      final match = RegExp(r'orderId=([^&]+)').firstMatch(payload);
      if (match != null && match.group(1) != null) {
        final orderId = match.group(1)!;
        _navigatorKey!.currentState!.push(
          MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(orderId: orderId),
          ),
        );
        return;
      }
    }

    if (payload.contains('offer')) {
      _navigatorKey!.currentState!.push(
        MaterialPageRoute(
          builder: (context) => const OffersScreen(),
        ),
      );
      return;
    }

    // Default: Open Notifications screen
    _navigatorKey!.currentState!.push(
      MaterialPageRoute(
        builder: (context) => const NotificationScreen(),
      ),
    );
  }
}
