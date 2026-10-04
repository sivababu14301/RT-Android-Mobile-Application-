import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../models/order_model.dart';
import '../screens/orders/order_details_screen.dart';
import 'order_status_chip.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.goldBorder.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(order.id.length - 6).toUpperCase()}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                OrderStatusChip(status: order.status),
              ],
            ),
            const Divider(color: Colors.white12, height: 24),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    order.orderItems[0].imageUrl,
                    width: 60,
                    height: 60,
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
                        order.orderItems[0].name,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (order.orderItems.length > 1)
                        Text(
                          '+ ${order.orderItems.length - 1} more items',
                          style: const TextStyle(color: AppColors.grey, fontSize: 12),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(order.createdAt),
                        style: const TextStyle(color: AppColors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${order.totalPrice.toInt()}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.arrow_forward_ios, color: AppColors.gold, size: 14),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
