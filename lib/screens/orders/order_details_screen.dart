import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/invoice_service.dart';
import '../../widgets/order_status_chip.dart';
import '../tracking/order_tracking_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  void _showCancelConfirmation(BuildContext context, OrderModel displayOrder) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Order?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to cancel this order?',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('KEEP ORDER', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final token = context.read<UserProvider>().user?.token;
              if (token != null) {
                final result = await context.read<OrderProvider>().requestOrderCancellation(displayOrder.id, token);
                if (context.mounted) {
                  if (result['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] ?? 'Your cancellation request has been sent to the admin for approval.'),
                        backgroundColor: AppColors.gold,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] ?? 'Order cancellation is not allowed as order processing has already started.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
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
            displayOrder = order; // Fallback
          }

          final String cleanStatus = displayOrder.status.trim().toLowerCase();
          final bool isPending = cleanStatus == 'pending' || cleanStatus == 'order placed';
          final bool isCancellationRequested = cleanStatus == 'cancellation requested';
          final bool isCancelled = cleanStatus == 'cancelled';

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
                          'Order ID: #${displayOrder.id.length > 6 ? displayOrder.id.substring(displayOrder.id.length - 6).toUpperCase() : displayOrder.id.toUpperCase()}',
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

                // Pending Cancellation Info Card
                if (isCancellationRequested) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.gold, width: 1.2),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.hourglass_top, color: AppColors.gold, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your cancellation request has been sent to the admin for approval.',
                            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Rejection Reason Info Card
                if (displayOrder.cancellationRejectionReason.isNotEmpty && isPending) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.red, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.red, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cancellation Request Rejected: ${displayOrder.cancellationRejectionReason}',
                            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Track Order Button
                if (!isCancelled)
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
                if (!isCancelled) const SizedBox(height: 16),

                // Download Tax Invoice PDF Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Generating PDF Invoice...'),
                            backgroundColor: AppColors.gold,
                            duration: Duration(seconds: 1),
                          ),
                        );
                        final pdfFile = await InvoiceService.generateInvoicePdf(displayOrder);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Invoice saved: ${pdfFile.path.split('/').last}'),
                              backgroundColor: AppColors.gold,
                              action: SnackBarAction(
                                label: 'OPEN',
                                textColor: Colors.black,
                                onPressed: () => InvoiceService.openPdf(pdfFile.path),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to generate invoice: $e'), backgroundColor: AppColors.error),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    icon: const Icon(Icons.file_download_outlined, color: Colors.black),
                    label: const Text('DOWNLOAD TAX INVOICE (PDF)', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ),

                const SizedBox(height: 32),
                
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
                                  const Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 30),
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

                // Show Cancel Order button ONLY when order is strictly in "Pending" / "Order Placed" status
                if (isPending)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () => _showCancelConfirmation(context, displayOrder),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                      label: const Text('CANCEL ORDER', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
