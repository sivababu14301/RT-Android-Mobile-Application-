import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/admin/admin_provider.dart';
import '../../providers/admin/admin_customer_provider.dart';
import '../../widgets/admin/admin_menu_tile.dart';
import 'admin_measurement_view_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  final UserModel customer;

  const CustomerProfileScreen({super.key, required this.customer});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AdminProvider>().admin?.token;
      if (token != null) {
        context.read<AdminCustomerProvider>().fetchCustomerDetails(token, widget.customer.id);
      }
    });
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
        title: Text(
          '${widget.customer.fullName}\'s Profile',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<AdminCustomerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.selectedCustomerOrders.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.gold,
                  backgroundImage: NetworkImage(widget.customer.getProfileImage),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.customer.fullName,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.customer.email,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 32),
                _buildInfoCard(),
                const SizedBox(height: 24),
                AdminMenuTile(
                  title: 'Order History (${provider.selectedCustomerOrders.length})',
                  icon: Icons.receipt_long_outlined,
                  onTap: () {
                    // Navigate to a filtered view or show in a list
                    _showOrdersModal(context, provider.selectedCustomerOrders);
                  },
                ),
                AdminMenuTile(
                  title: 'Saved Measurements (${provider.selectedCustomerMeasurements.length})',
                  icon: Icons.straighten_outlined,
                  onTap: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminMeasurementViewScreen(
                          customer: widget.customer,
                          measurements: provider.selectedCustomerMeasurements,
                        ),
                      ),
                    );
                  },
                ),
                AdminMenuTile(
                  title: 'Shipping Address',
                  icon: Icons.location_on_outlined,
                  onTap: () => _showAddressModal(context),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showOrdersModal(BuildContext context, List orders) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Order History', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: orders.isEmpty
              ? const Center(child: Text('No orders found', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return ListTile(
                      title: Text('Order #${order.id.substring(order.id.length - 6).toUpperCase()}', style: const TextStyle(color: Colors.white)),
                      subtitle: Text('Status: ${order.status}', style: TextStyle(color: _getStatusColor(order.status))),
                      trailing: Text('₹${order.totalAmount.toInt()}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                      onTap: () {
                         // Could navigate to detail
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  void _showAddressModal(BuildContext context) {
    final address = widget.customer.address;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shipping Address', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (address == null || address.fullAddress.isEmpty)
              const Text('No address saved', style: TextStyle(color: Colors.grey))
            else ...[
              Text(address.fullName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(address.mobile, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Text(address.fullAddress, style: const TextStyle(color: Colors.white, height: 1.5)),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.amber;
      case 'confirmed': return Colors.blue;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.white70;
    }
  }

  Widget _buildInfoCard() {
    final dateFormat = DateFormat('dd MMM yyyy');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildDetailRow('Mobile Number', widget.customer.mobile),
          const Divider(color: Colors.white10, height: 20),
          _buildDetailRow('Role', widget.customer.role?.toUpperCase() ?? 'CUSTOMER'),
          const Divider(color: Colors.white10, height: 20),
          _buildDetailRow('Total Orders', widget.customer.totalOrders.toString()),
          if (widget.customer.createdAt != null) ...[
            const Divider(color: Colors.white10, height: 20),
            _buildDetailRow('Registration Date', dateFormat.format(widget.customer.createdAt!)),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
