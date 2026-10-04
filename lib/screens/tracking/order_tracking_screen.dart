import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel? order;
  final String? orderId;

  const OrderTrackingScreen({super.key, this.order, this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshOrder();
    });
  }

  Future<void> _refreshOrder() async {
    final token = context.read<UserProvider>().user?.token;
    if (token != null) {
      await context.read<OrderProvider>().fetchMyOrders(token);
    }
  }

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Order Placed',
      'subtitle': 'Your order has been placed successfully.',
      'aliases': ['Order Placed', 'Pending'],
    },
    {
      'title': 'Order Confirmed',
      'subtitle': 'Tailor has accepted and confirmed your order.',
      'aliases': ['Order Confirmed', 'Confirmed'],
    },
    {
      'title': 'Stitching',
      'subtitle': 'Your garment is being stitched by master tailors.',
      'aliases': ['Stitching'],
    },
    {
      'title': 'Ready',
      'subtitle': 'Stitching complete & quality checked.',
      'aliases': ['Ready'],
    },
    {
      'title': 'Out for Delivery',
      'subtitle': 'Package is on the way to your delivery address.',
      'aliases': ['Out for Delivery', 'Out_for_delivery'],
    },
    {
      'title': 'Delivered',
      'subtitle': 'Order delivered! Enjoy your perfect custom fit.',
      'aliases': ['Delivered'],
    },
  ];

  int _getStepIndex(String status) {
    final lowerStatus = status.trim().toLowerCase();
    if (lowerStatus == 'cancelled') return -1;
    for (int i = 0; i < _steps.length; i++) {
      final List<String> aliases = List<String>.from(_steps[i]['aliases']);
      if (aliases.any((a) => a.toLowerCase() == lowerStatus)) {
        return i;
      }
    }
    return 0; // Default to Order Placed
  }

  StatusHistoryItem? _getHistoryForAliases(OrderModel order, List<String> aliases) {
    if (order.statusHistory.isEmpty) return null;
    for (final item in order.statusHistory) {
      if (aliases.any((alias) => alias.trim().toLowerCase() == item.status.trim().toLowerCase())) {
        return item;
      }
    }
    return null;
  }

  String? _getFormattedTimestamp(OrderModel order, List<String> aliases, bool isCompletedOrCurrent) {
    final historyItem = _getHistoryForAliases(order, aliases);
    if (historyItem != null) {
      String datePart = historyItem.date;
      try {
        if (datePart.contains('-')) {
          final parsedDate = DateTime.parse(datePart);
          datePart = DateFormat('dd MMM yyyy').format(parsedDate);
        }
      } catch (_) {}
      return '$datePart, ${historyItem.time}';
    }

    if (aliases.contains('Order Placed') || aliases.contains('Pending')) {
      if (isCompletedOrCurrent) {
        return DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);
      }
    }
    return null;
  }

  String _getFormattedStatusWithEmoji(String status) {
    switch (status.trim().toLowerCase()) {
      case 'pending':
      case 'order placed':
        return '📦 Order Placed';
      case 'confirmed':
      case 'order confirmed':
        return '✅ Order Confirmed';
      case 'stitching':
        return '🧵 Stitching';
      case 'ready':
        return '🔔 Ready';
      case 'out for delivery':
      case 'out_for_delivery':
        return '🚚 Out for Delivery';
      case 'delivered':
        return '🏠 Delivered';
      case 'cancelled':
        return '❌ Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetId = widget.orderId ?? widget.order?.id;

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
          'Track Order',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          OrderModel displayOrder;
          try {
            displayOrder = orderProvider.orders.firstWhere((o) => o.id == targetId);
          } catch (e) {
            displayOrder = widget.order!;
          }

          final String currentStatus = displayOrder.status;
          final int currentIndex = _getStepIndex(currentStatus);
          final bool isCancelled = currentStatus.toLowerCase() == 'cancelled';

          return RefreshIndicator(
            onRefresh: _refreshOrder,
            color: AppColors.gold,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expected Delivery Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isCancelled ? Colors.red.withValues(alpha: 0.3) : AppColors.goldBorder.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Expected Delivery',
                              style: TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            Icon(
                              isCancelled ? Icons.event_busy : Icons.local_shipping_outlined,
                              color: isCancelled ? Colors.red : AppColors.gold,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isCancelled
                              ? 'Delivery Cancelled'
                              : DateFormat('EEEE, dd MMMM yyyy').format(displayOrder.createdAt.add(const Duration(days: 5))),
                          style: TextStyle(
                            color: isCancelled ? Colors.red : AppColors.gold,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(color: Colors.white10, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Current Status', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                            Text(
                              _getFormattedStatusWithEmoji(currentStatus),
                              style: TextStyle(
                                color: isCancelled ? Colors.red : AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Order Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        _buildHeaderRow('Order ID', '#${displayOrder.id.substring(displayOrder.id.length >= 6 ? displayOrder.id.length - 6 : 0).toUpperCase()}'),
                        const SizedBox(height: 12),
                        _buildHeaderRow('Order Date', DateFormat('dd MMM yyyy, hh:mm a').format(displayOrder.createdAt)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'Live Order Timeline',
                    style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Vertical Timeline Steps
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      final List<String> aliases = List<String>.from(step['aliases']);
                      
                      final bool isCompleted = !isCancelled && index < currentIndex;
                      final bool isCurrent = !isCancelled && index == currentIndex;
                      final bool isCompletedOrCurrent = isCompleted || isCurrent;
                      final bool isLast = index == _steps.length - 1;

                      final String? timestamp = _getFormattedTimestamp(displayOrder, aliases, isCompletedOrCurrent);

                      return _buildTimelineStep(
                        title: step['title'],
                        subtitle: step['subtitle'],
                        timestamp: timestamp,
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                        isLast: isLast,
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
        Text(value, style: TextStyle(color: valueColor ?? AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required String? timestamp,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    final Color borderColor = isCompleted || isCurrent
        ? AppColors.gold
        : Colors.white24;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.gold : (isCurrent ? AppColors.gold.withValues(alpha: 0.2) : Colors.transparent),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.black)
                  : (isCurrent
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.gold),
                          ),
                        )
                      : null),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: timestamp != null ? 65 : 50,
                color: isCompleted ? AppColors.gold : Colors.white12,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isCompleted || isCurrent ? AppColors.white : Colors.white38,
                  fontSize: 15,
                  fontWeight: isCompleted || isCurrent ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isCompleted || isCurrent ? AppColors.grey : Colors.white24,
                  fontSize: 12,
                ),
              ),
              if (timestamp != null && timestamp.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: isCurrent ? AppColors.gold : Colors.white54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timestamp,
                      style: TextStyle(
                        color: isCurrent ? AppColors.gold : Colors.white54,
                        fontSize: 12,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
