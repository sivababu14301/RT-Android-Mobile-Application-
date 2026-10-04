import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../models/order_model.dart';
import '../../widgets/order_status_chip.dart';
import 'invoice_details_screen.dart';

class PaymentDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const PaymentDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final String shortId = order.id.length >= 6 ? order.id.substring(order.id.length - 6).toUpperCase() : order.id.toUpperCase();
    final bool isPaid = order.isPaid || order.status.toLowerCase() == 'delivered' || order.status.toLowerCase() == 'confirmed';

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
          'Payment Details',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isPaid ? Colors.green : Colors.amber).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPaid ? Icons.check_circle_outline : Icons.hourglass_empty,
                      size: 48,
                      color: isPaid ? Colors.green : AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPaid ? 'PAYMENT SUCCESSFUL' : 'PAYMENT PENDING',
                    style: TextStyle(
                      color: isPaid ? Colors.green : AppColors.gold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${order.totalPrice.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Order #$shortId',
                    style: const TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment Metadata
            const Text(
              'TRANSACTION INFORMATION',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Order Reference', '#$shortId'),
                  const Divider(color: Colors.white10, height: 20),
                  _buildDetailRow('Payment Method', order.paymentMethod),
                  const Divider(color: Colors.white10, height: 20),
                  _buildDetailRow('Date & Time', DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt)),
                  const Divider(color: Colors.white10, height: 20),
                  _buildDetailRow(
                    'Payment Status',
                    isPaid ? 'PAID' : 'PENDING / COD',
                    valueColor: isPaid ? Colors.green : AppColors.gold,
                  ),
                  const Divider(color: Colors.white10, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Order Status', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                      OrderStatusChip(status: order.status),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Items Purchased
            const Text(
              'ITEMS PURCHASED',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: order.orderItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(width: 50, height: 50, color: Colors.black26, child: const Icon(Icons.broken_image, color: AppColors.gold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('Qty: ${item.quantity}  •  Size: ${item.size ?? "Fit"}', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text('₹${(item.price * item.quantity).toInt()}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Amount Breakdown
            const Text(
              'PAYMENT BREAKDOWN',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Items Price', '₹${order.itemsPrice.toInt()}'),
                  const SizedBox(height: 10),
                  _buildDetailRow('Delivery Fee', order.shippingPrice > 0 ? '₹${order.shippingPrice.toInt()}' : 'FREE'),
                  const Divider(color: Colors.white10, height: 24),
                  _buildDetailRow('Total Amount', '₹${order.totalPrice.toInt()}', valueColor: AppColors.gold, isBold: true),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InvoiceDetailsScreen(order: order),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.receipt_long, color: Colors.black),
                label: const Text('VIEW TAX INVOICE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 15 : 13,
          ),
        ),
      ],
    );
  }
}
