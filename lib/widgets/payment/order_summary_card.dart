import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';

class OrderSummaryCard extends StatelessWidget {
  final List<CartItemModel> cartItems;
  final double subtotal;
  final double deliveryCharge;
  final double discount;

  const OrderSummaryCard({
    super.key,
    required this.cartItems,
    required this.subtotal,
    this.deliveryCharge = 0.0,
    this.discount = 0.0,
  });

  double get grandTotal => subtotal + deliveryCharge - discount;

  @override
  Widget build(BuildContext context) {
    if (cartItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.1)),
        ),
        child: const Center(
          child: Text('No items in cart', style: TextStyle(color: AppColors.grey)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...cartItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final String fullUrl = Product.formatImageUrl(item.product.imageUrl);
            final double itemTotalPrice = item.product.price * item.quantity;

            return Column(
              children: [
                if (index > 0) const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: Colors.black,
                        width: 60,
                        height: 60,
                        child: Image.network(
                          fullUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.black12,
                            child: const Icon(Icons.shopping_bag_outlined, color: AppColors.gold, size: 24),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Qty: ${item.quantity}  |  Size: ${item.size ?? "N/A"}',
                            style: const TextStyle(color: AppColors.grey, fontSize: 12),
                          ),
                          if (item.color != null && item.color!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Color: ${item.color}',
                              style: const TextStyle(color: AppColors.grey, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      '₹${itemTotalPrice.toInt()}',
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ],
            );
          }),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white10),
          ),
          _buildPriceRow('Subtotal', '₹${subtotal.toInt()}'),
          const SizedBox(height: 8),
          _buildPriceRow(
            'Delivery Charge',
            deliveryCharge == 0 ? 'FREE' : '₹${deliveryCharge.toInt()}',
            valueColor: deliveryCharge == 0 ? Colors.green : Colors.white,
          ),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow('Discount', '-₹${discount.toInt()}', valueColor: AppColors.gold),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white10),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${grandTotal.toInt()}',
                style: const TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
