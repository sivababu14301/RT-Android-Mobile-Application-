import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../models/order_model.dart';
import '../screens/orders/order_details_screen.dart';
import 'order_status_chip.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({super.key, required this.order});

  Widget _buildImagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: AppColors.gold,
        size: 28,
      ),
    );
  }

  Widget _buildOrderItemImage(String rawUrl) {
    if (rawUrl.trim().isEmpty) {
      return _buildImagePlaceholder();
    }

    if (rawUrl.startsWith('data:image/')) {
      try {
        final base64Str = rawUrl.split(',').last.trim();
        final bytes = base64Decode(base64Str);
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            bytes,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
          ),
        );
      } catch (_) {
        return _buildImagePlaceholder();
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        rawUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = order.orderItems.isNotEmpty;
    final firstItem = hasItems ? order.orderItems[0] : null;
    final String firstItemName = firstItem != null && firstItem.name.isNotEmpty ? firstItem.name : 'Custom Tailored Order';
    final String imageUrl = firstItem != null ? firstItem.imageUrl : '';

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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.2)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.length > 6 ? order.id.substring(order.id.length - 6).toUpperCase() : order.id.toUpperCase()}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                OrderStatusChip(status: order.status),
              ],
            ),
            const Divider(color: Colors.white12, height: 24),
            Row(
              children: [
                _buildOrderItemImage(imageUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItemName,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (order.orderItems.length > 1) ...[
                        const SizedBox(height: 2),
                        Text(
                          '+ ${order.orderItems.length - 1} more items',
                          style: const TextStyle(color: AppColors.grey, fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: AppColors.grey, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(order.createdAt),
                            style: const TextStyle(color: AppColors.grey, fontSize: 12),
                          ),
                        ],
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
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white10,
                      child: Icon(Icons.arrow_forward_ios, color: AppColors.gold, size: 11),
                    ),
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
