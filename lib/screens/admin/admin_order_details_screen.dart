import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../models/order_model.dart';
import '../../models/measurement_model.dart';
import '../../providers/admin/admin_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/admin/admin_customer_provider.dart';
import '../../widgets/order_status_chip.dart';
import 'update_order_status_screen.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const AdminOrderDetailsScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailsScreen> createState() => _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final orderProvider = context.read<OrderProvider>();
    final token = context.read<AdminProvider>().admin?.token;
    
    if (token == null) return;

    try {
      final order = orderProvider.orders.firstWhere((o) => o.id == widget.orderId);
      context.read<AdminCustomerProvider>().fetchCustomerDetails(token, order.userId);
    } catch (e) {
      debugPrint('Error finding order for measurements: $e');
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
        title: const Text('Order Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Consumer2<OrderProvider, AdminCustomerProvider>(
        builder: (context, orderProvider, customerProvider, child) {
          OrderModel order;
          try {
            order = orderProvider.orders.firstWhere((o) => o.id == widget.orderId);
          } catch (e) {
            return const Center(child: Text('Order not found', style: TextStyle(color: Colors.white)));
          }

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
                        Text('Order ID: #${order.id.substring(order.id.length - 6).toUpperCase()}', 
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Placed on ${DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt)}', 
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    OrderStatusChip(status: order.status),
                  ],
                ),
                const Divider(color: Colors.white12, height: 40),
                
                _buildSectionTitle('Customer Information'),
                _buildInfoCard([
                  _buildInfoRow('Name', order.shippingAddress.fullName),
                  _buildInfoRow('Phone', order.shippingAddress.mobile),
                  _buildInfoRow('Address', '${order.shippingAddress.doorNumber}, ${order.shippingAddress.street}, ${order.shippingAddress.area}, ${order.shippingAddress.city}'),
                ]),
                
                const SizedBox(height: 24),
                _buildSectionTitle('Items'),
                Column(
                  children: order.orderItems.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: _buildInfoCard([
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.image.startsWith('http') ? item.image : 'http://10.0.2.2:5000${item.image}',
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
                                Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text('Size: ${item.size ?? "N/A"} | Color: ${item.color ?? "N/A"}', 
                                    style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                                Text('Qty: ${item.quantity} x ₹${item.price.toInt()}', 
                                    style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ]),
                  )).toList(),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('MEASUREMENTS'),
                customerProvider.isLoading
                    ? const Center(child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(color: AppColors.gold),
                      ))
                    : _buildMeasurementsSection(customerProvider.selectedCustomerMeasurements),

                const SizedBox(height: 24),
                _buildSectionTitle('Payment Summary'),
                _buildInfoCard([
                  _buildInfoRow('Subtotal', '₹${order.itemsPrice.toInt()}'),
                  _buildInfoRow('Shipping', order.shippingPrice == 0 ? 'FREE' : '₹${order.shippingPrice.toInt()}'),
                  const Divider(color: Colors.white10),
                  _buildInfoRow('Total Amount', '₹${order.totalPrice.toInt()}', isBold: true),
                  _buildInfoRow('Payment Method', order.paymentMethod),
                  _buildInfoRow('Payment Status', order.isPaid ? 'PAID' : 'PENDING'),
                ]),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final String? newStatus = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UpdateOrderStatusScreen(currentStatus: order.status)),
                      );
                      
                      if (newStatus != null && context.mounted) {
                        final token = context.read<AdminProvider>().admin?.token;
                        if (token != null) {
                          final success = await context.read<OrderProvider>().updateStatus(order.id, newStatus, token);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Order status updated to $newStatus'), backgroundColor: Colors.green),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('UPDATE ORDER STATUS', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMeasurementsSection(List<MeasurementModel> measurements) {
    if (measurements.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('No measurements available for this customer', style: TextStyle(color: Colors.grey, fontSize: 13)),
      );
    }

    return Column(
      children: measurements.map((m) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: _buildInfoCard([
          Row(
            children: [
              Icon(
                m.type == 'tshirt' || m.type == 't-shirt'
                    ? Icons.dry_cleaning
                    : m.type == 'shirt'
                        ? Icons.checkroom
                        : Icons.accessibility_new,
                color: AppColors.gold,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text('${m.type.toUpperCase()} MEASUREMENTS', 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const Divider(color: Colors.white10),
          if (m.type == 'tshirt' || m.type == 't-shirt') ...[
            _buildMeasurementRow('Chest', '${m.chest ?? 0}"'),
            _buildMeasurementRow('Shoulder', '${m.shoulder ?? 0}"'),
            _buildMeasurementRow('Sleeve Length', '${m.sleeveLength ?? 0}"'),
            _buildMeasurementRow('T-Shirt Length', '${m.shirtLength ?? 0}"'),
            _buildMeasurementRow('Neck', '${m.neck ?? 0}"'),
          ] else if (m.type == 'shirt') ...[
            _buildMeasurementRow('Chest', '${m.chest ?? 0}"'),
            _buildMeasurementRow('Shoulder', '${m.shoulder ?? 0}"'),
            _buildMeasurementRow('Sleeve Length', '${m.sleeveLength ?? 0}"'),
            _buildMeasurementRow('Shirt Length', '${m.shirtLength ?? 0}"'),
            _buildMeasurementRow('Waist', '${m.waist ?? 0}"'),
            _buildMeasurementRow('Neck', '${m.neck ?? 0}"'),
          ] else if (m.type == 'pant') ...[
            _buildMeasurementRow('Waist', '${m.pantWaist ?? 0}"'),
            _buildMeasurementRow('Hip', '${m.hip ?? 0}"'),
            _buildMeasurementRow('Thigh', '${m.thigh ?? 0}"'),
            _buildMeasurementRow('Pant Length', '${m.pantLength ?? 0}"'),
            _buildMeasurementRow('Inseam', '${m.inseam ?? 0}"'),
          ] else ...[
            // Custom or Mixed
             ...m.customMeasurements?.entries.map((e) => _buildMeasurementRow(e.key, '${e.value}"')).toList() ?? [],
          ]
        ]),
      )).toList(),
    );
  }

  Widget _buildMeasurementRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: TextStyle(
            color: isBold ? AppColors.gold : Colors.white, 
            fontSize: isBold ? 15 : 13, 
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500
          )),
        ],
      ),
    );
  }
}
