import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/order_status_chip.dart';
import 'payment_details_screen.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders();
    });
  }

  Future<void> _fetchOrders() async {
    final token = context.read<UserProvider>().user?.token;
    if (token != null) {
      await context.read<OrderProvider>().fetchMyOrders(token);
    }
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
          'Payment History',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          final orders = orderProvider.orders;

          if (orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: _fetchOrders,
              color: AppColors.gold,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.payment_outlined,
                            size: 80,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'No Payment Records',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'You do not have any payment transactions yet. Once you place orders, payment records will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _fetchOrders,
            color: AppColors.gold,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildPaymentCard(context, order);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, OrderModel order) {
    final String shortId = order.id.length >= 6 ? order.id.substring(order.id.length - 6).toUpperCase() : order.id.toUpperCase();
    final firstItem = order.orderItems.isNotEmpty ? order.orderItems.first : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentDetailsScreen(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #$shortId',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                OrderStatusChip(status: order.status),
              ],
            ),
            const Divider(color: Colors.white12, height: 24),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: firstItem != null
                      ? Image.network(
                          firstItem.imageUrl,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(width: 55, height: 55, color: Colors.black26, child: const Icon(Icons.broken_image, color: AppColors.gold)),
                        )
                      : Container(width: 55, height: 55, color: Colors.black26, child: const Icon(Icons.payment, color: AppColors.gold)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItem?.name ?? 'Tailoring Order',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (order.orderItems.length > 1)
                        Text(
                          '+ ${order.orderItems.length - 1} more items',
                          style: const TextStyle(color: AppColors.grey, fontSize: 11),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.gold, size: 11),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(order.createdAt),
                            style: const TextStyle(color: AppColors.grey, fontSize: 11),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.credit_card, color: AppColors.gold, size: 11),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              order.paymentMethod,
                              style: const TextStyle(color: AppColors.gold, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
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
