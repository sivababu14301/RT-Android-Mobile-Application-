import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../providers/admin/admin_provider.dart';
import '../../providers/admin/admin_customer_provider.dart';
import 'customer_profile_screen.dart';

class AdminCustomerListScreen extends StatefulWidget {
  const AdminCustomerListScreen({super.key});

  @override
  State<AdminCustomerListScreen> createState() => _AdminCustomerListScreenState();
}

class _AdminCustomerListScreenState extends State<AdminCustomerListScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AdminProvider>().admin?.token;
      if (token != null) {
        context.read<AdminCustomerProvider>().fetchCustomers(token);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Customer Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<AdminCustomerProvider>(
        builder: (context, provider, child) {
          final filteredCustomers = provider.customers.where((c) {
            final query = _searchQuery.toLowerCase();
            return c.fullName.toLowerCase().contains(query) ||
                   c.email.toLowerCase().contains(query) ||
                   c.mobile.contains(query);
          }).toList();

          return Column(
            children: [
              _buildStatsHeader(provider.customers.length),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by Name, Email or Mobile',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                    suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: provider.isLoading && provider.customers.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                    : provider.error != null
                        ? Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)))
                        : RefreshIndicator(
                            onRefresh: () async {
                              final token = context.read<AdminProvider>().admin?.token;
                              if (token != null) {
                                await provider.fetchCustomers(token);
                              }
                            },
                            color: AppColors.gold,
                            child: filteredCustomers.isEmpty
                                ? const Center(child: Text('No customers found', style: TextStyle(color: AppColors.grey)))
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: filteredCustomers.length,
                                    itemBuilder: (context, index) {
                                      return _buildCustomerItem(context, filteredCustomers[index]);
                                    },
                                  ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsHeader(int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Registered Users', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
              Text(total.toString(), style: const TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Icons.people_alt, color: Colors.black26, size: 50),
        ],
      ),
    );
  }

  Widget _buildCustomerItem(BuildContext context, dynamic customer) {
    final dateFormat = DateFormat('dd MMM yyyy');
    
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
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.gold,
                backgroundImage: NetworkImage(customer.getProfileImage),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('📞 ${customer.mobile}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    Text('📧 ${customer.email}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    if (customer.createdAt != null)
                      Text('📅 Joined: ${dateFormat.format(customer.createdAt!)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                children: [
                  const Text('Orders', style: TextStyle(color: AppColors.grey, fontSize: 10)),
                  Text(customer.totalOrders.toString(), style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18)),
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
                  MaterialPageRoute(
                    builder: (context) => CustomerProfileScreen(customer: customer),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('View Full Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
