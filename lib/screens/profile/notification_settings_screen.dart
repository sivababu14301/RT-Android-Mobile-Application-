import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../widgets/custom_button.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _orderUpdates = true;
  bool _promoOffers = true;
  bool _festivalOffers = true;
  bool _newArrivals = true;
  bool _measurementReminders = true;
  bool _reviewReminders = true;
  bool _generalNotifications = true;

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings updated successfully.'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification Settings',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildNotificationCard(
              icon: Icons.inventory_2_outlined,
              title: 'Order Updates',
              description: 'Receive notifications about order confirmation, tailoring progress, shipping, and delivery.',
              value: _orderUpdates,
              onChanged: (val) => setState(() => _orderUpdates = val),
            ),
            _buildNotificationCard(
              icon: Icons.local_offer_outlined,
              title: 'Promotional Offers',
              description: 'Receive notifications about discounts, seasonal sales, and exclusive offers.',
              value: _promoOffers,
              onChanged: (val) => setState(() => _promoOffers = val),
            ),
            _buildNotificationCard(
              icon: Icons.celebration_outlined,
              title: 'Festival Offers',
              description: 'Get notified about Diwali, Pongal, Eid, Christmas, New Year, and other special festival offers.',
              value: _festivalOffers,
              onChanged: (val) => setState(() => _festivalOffers = val),
            ),
            _buildNotificationCard(
              icon: Icons.new_releases_outlined,
              title: 'New Arrivals',
              description: 'Receive notifications when new shirts, pants, suits, and fabrics are added.',
              value: _newArrivals,
              onChanged: (val) => setState(() => _newArrivals = val),
            ),
            _buildNotificationCard(
              icon: Icons.straighten_outlined,
              title: 'Measurement Reminders',
              description: 'Receive reminders to update your saved body measurements.',
              value: _measurementReminders,
              onChanged: (val) => setState(() => _measurementReminders = val),
            ),
            _buildNotificationCard(
              icon: Icons.star_outline,
              title: 'Review Reminders',
              description: 'Get reminders to rate and review your completed orders.',
              value: _reviewReminders,
              onChanged: (val) => setState(() => _reviewReminders = val),
            ),
            _buildNotificationCard(
              icon: Icons.notifications_none_outlined,
              title: 'General Notifications',
              description: 'Receive important announcements and application updates.',
              value: _generalNotifications,
              onChanged: (val) => setState(() => _generalNotifications = val),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'SAVE SETTINGS',
              onPressed: _saveSettings,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.gold, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.gold,
            activeTrackColor: AppColors.gold.withOpacity(0.3),
            inactiveThumbColor: AppColors.grey,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }
}
