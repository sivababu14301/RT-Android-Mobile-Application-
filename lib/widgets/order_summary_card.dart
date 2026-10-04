import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/cart_model.dart';

class OrderSummaryCard extends StatelessWidget {
  final List<CartItem>? items;
  final double? total;

  const OrderSummaryCard({
    super.key,
    this.items,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    // If no items are passed, show a dummy placeholder for the demo UI
    if (items == null || items!.isEmpty) {
      return _buildPlaceholder();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          ...items!.map((item) => Padding(
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
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.white10,
                      child: const Icon(Icons.broken_image_outlined, color: AppColors.gold, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text('Qty: ${item.quantity}', style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                    ],
                  ),
                ),
                Text(
                  '₹${item.total.toInt()}',
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )),
          const Divider(color: Colors.white10, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(
                '₹${total?.toInt() ?? 0}',
                style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 70,
              height: 70,
              color: Colors.white10,
              child: const Icon(Icons.shopping_bag_outlined, color: AppColors.gold),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Tailored Item',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text('Order Preview', style: TextStyle(color: AppColors.grey, fontSize: 13)),
              ],
            ),
          ),
          const Text(
            '₹1,199',
            style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
