import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/order_status_chip.dart';
import '../tracking/order_tracking_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  void _showCancelConfirmation(BuildContext context, OrderModel displayOrder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Order?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO, KEEP IT', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final token = context.read<UserProvider>().user?.token;
              if (token != null) {
                final success = await context.read<OrderProvider>().cancelOrder(displayOrder.id, token);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order Cancelled Successfully'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('YES, CANCEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
          'Order Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          // Find the latest version of this order from the provider
          OrderModel displayOrder;
          try {
            displayOrder = provider.orders.firstWhere((o) => o.id == order.id);
          } catch (e) {
            displayOrder = order; // Fallback to initial order
          }

          final bool isCancellable = displayOrder.status == 'Pending' || displayOrder.status == 'Confirmed';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ID: #${displayOrder.id.substring(displayOrder.id.length - 6).toUpperCase()}',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Placed on ${DateFormat('dd MMM yyyy, hh:mm a').format(displayOrder.createdAt)}',
                          style: const TextStyle(color: AppColors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    OrderStatusChip(status: displayOrder.status),
                  ],
                ),
                const Divider(color: Colors.white12, height: 40),
                
                // Track Order Button
                if (displayOrder.status != 'Cancelled')
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OrderTrackingScreen(order: displayOrder)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold.withValues(alpha: 0.1),
                        side: const BorderSide(color: AppColors.gold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      icon: const Icon(Icons.track_changes, color: AppColors.gold),
                      label: const Text('TRACK ORDER PROGRESS', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (displayOrder.status != 'Cancelled') const SizedBox(height: 32),
                
                ...displayOrder.orderItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              item.imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error, color: AppColors.gold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Qty: ${item.quantity} | Size: ${item.size ?? "N/A"} | Color: ${item.color ?? "N/A"}',
                                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${(item.price * item.quantity).toInt()}',
                            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )),
                const Divider(color: Colors.white12, height: 40),
                const Text(
                  'Delivery Address',
                  style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayOrder.shippingAddress.fullName, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${displayOrder.shippingAddress.doorNumber}, ${displayOrder.shippingAddress.street}, ${displayOrder.shippingAddress.area}, ${displayOrder.shippingAddress.city}', style: const TextStyle(color: AppColors.grey, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Mobile: ${displayOrder.shippingAddress.mobile}', style: const TextStyle(color: AppColors.grey, fontSize: 14)),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 40),
                const Text(
                  'Payment Information',
                  style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(displayOrder.paymentMethod, style: const TextStyle(color: AppColors.grey)),
                      Text(
                        displayOrder.isPaid ? 'PAID' : 'PENDING',
                        style: TextStyle(color: displayOrder.isPaid ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      '₹${displayOrder.totalPrice.toInt()}',
                      style: const TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                if (isCancellable)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () => _showCancelConfirmation(context, displayOrder),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('CANCEL ORDER', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
