import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/admin/admin_provider.dart';
import '../../widgets/order_status_chip.dart';
import 'admin_order_details_screen.dart';

class AdminOrderManagementScreen extends StatefulWidget {
  const AdminOrderManagementScreen({super.key});

  @override
  State<AdminOrderManagementScreen> createState() => _AdminOrderManagementScreenState();
}

class _AdminOrderManagementScreenState extends State<AdminOrderManagementScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Confirmed', 'Stitching', 'Ready', 'Delivered', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders();
    });
  }

  void _fetchOrders() {
    final token = context.read<AdminProvider>().admin?.token;
    if (token != null) {
      context.read<OrderProvider>().fetchAllOrders(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final allOrders = orderProvider.orders;
    
    final filteredOrders = _selectedFilter == 'All' 
        ? allOrders 
        : allOrders.where((o) => o.status == _selectedFilter).toList();

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
          'Order Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by Order ID...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedFilter == _filters[index];
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = _filters[index]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.gold : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _fetchOrders(),
              color: AppColors.gold,
              child: orderProvider.isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                  : filteredOrders.isEmpty
                      ? const Center(child: Text('No orders found', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return _buildOrderCard(context, order);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final firstItem = order.orderItems[0];
    final displayImage = firstItem.image;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #${order.id.substring(order.id.length - 6).toUpperCase()}', 
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              OrderStatusChip(status: order.status),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  displayImage.startsWith('http') ? displayImage : 'http://10.0.2.2:5000$displayImage',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.black12,
                    child: const Icon(Icons.error, color: AppColors.gold, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.shippingAddress.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('${firstItem.name} ${order.orderItems.length > 1 ? "+${order.orderItems.length - 1} more" : ""}', 
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}', 
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${order.totalPrice.toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(order.paymentMethod, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminOrderDetailsScreen(orderId: order.id)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
