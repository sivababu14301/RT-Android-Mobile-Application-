import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../providers/notification_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';
import '../../models/notification_model.dart';
import '../tracking/order_tracking_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<UserProvider>().user?.token;
      if (token != null) {
        context.read<NotificationProvider>().fetchNotifications(token);
      }
    });
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
          'Notifications',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.notifications.isEmpty) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () => _confirmClearAll(context),
                icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.gold, size: 20),
                label: const Text(
                  'CLEAR ALL',
                  style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          if (provider.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: () async {
                    final token = context.read<UserProvider>().user?.token;
                    if (token != null) {
                      await provider.fetchNotifications(token);
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: provider.notifications.length,
                    itemBuilder: (context, index) {
                      final item = provider.notifications[index];
                      return _buildNotificationCard(item);
                    },
                  ),
                ),
              ),
              if (provider.notifications.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "You're all caught up!",
                    style: TextStyle(color: AppColors.grey, fontSize: 14),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel item) {
    final token = context.read<UserProvider>().user?.token;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isRead ? Colors.transparent : AppColors.gold.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.getIcon, color: AppColors.gold, size: 24),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (!item.isRead)
              const CircleAvatar(
                radius: 4,
                backgroundColor: AppColors.gold,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              item.message,
              style: const TextStyle(color: AppColors.grey, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              DateFormat('dd MMM yyyy, hh:mm a').format(item.createdAt),
              style: TextStyle(
                color: AppColors.grey.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          if (!item.isRead && token != null) {
            context.read<NotificationProvider>().markAsRead(item.id, token);
          }
          _showNotificationDetail(item);
        },
      ),
    );
  }

  void _showNotificationDetail(NotificationModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item.getIcon, color: AppColors.gold),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white12),
            const SizedBox(height: 20),
            Text(
              item.message,
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Received on: ${DateFormat('dd MMM yyyy, hh:mm a').format(item.createdAt)}',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 20),
            if (item.orderId != null && item.orderId!.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderTrackingScreen(orderId: item.orderId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.track_changes, size: 18),
                  label: const Text('TRACK ORDER PROGRESS', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.grey),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All Notifications?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final token = context.read<UserProvider>().user?.token;
              if (token != null) {
                final success = await context.read<NotificationProvider>().clearAllNotifications(token);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All notifications cleared successfully'),
                      backgroundColor: AppColors.gold,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black,
            ),
            child: const Text('CLEAR ALL', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none_outlined, size: 100, color: AppColors.gold),
            const SizedBox(height: 24),
            const Text(
              'No Notifications Yet',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You\'ll receive order updates and offers here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey, fontSize: 16),
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'CONTINUE SHOPPING',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
