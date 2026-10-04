import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/admin/admin_provider.dart';
import '../../providers/admin/admin_customer_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/custom_button.dart';

class AdminNotificationCustomerListScreen extends StatefulWidget {
  final UserModel? initialCustomer;

  const AdminNotificationCustomerListScreen({super.key, this.initialCustomer});

  @override
  State<AdminNotificationCustomerListScreen> createState() => _AdminNotificationCustomerListScreenState();
}

class _AdminNotificationCustomerListScreenState extends State<AdminNotificationCustomerListScreen> {
  // 'all' or 'specific'
  String _sendMode = 'specific';
  UserModel? _selectedCustomer;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController(text: 'Message from Raymaans Tailors');
  final TextEditingController _messageController = TextEditingController();

  String _searchQuery = '';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCustomer != null) {
      _selectedCustomer = widget.initialCustomer;
      _sendMode = 'specific';
    }

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
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    if (_sendMode == 'specific' && _selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer to send the message'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final token = context.read<AdminProvider>().admin?.token;
      if (token == null) throw 'Authentication error';

      final String targetUserId = _sendMode == 'all' ? 'all' : _selectedCustomer!.id;

      final result = await context.read<NotificationProvider>().sendAdminMessage(
        userId: targetUserId,
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        token: token,
      );

      if (mounted) {
        if (result['success'] == true) {
          final String msg = result['message'] ??
              (_sendMode == 'all'
                  ? 'Broadcast message sent to all customers!'
                  : 'Message sent to ${_selectedCustomer?.fullName}!');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: AppColors.success),
          );

          _messageController.clear();
          if (_sendMode == 'specific') {
            setState(() => _selectedCustomer = null);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to send message'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
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
          'Send Message',
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Audience Selector Tabs
                  _buildSegmentedToggle(),

                  const SizedBox(height: 24),

                  if (_sendMode == 'all') ...[
                    // ALL CUSTOMERS MODE BANNER
                    _buildBroadcastBanner(provider.customers.length),
                  ] else ...[
                    // SPECIFIC CUSTOMER MODE SELECTOR
                    if (_selectedCustomer != null)
                      _buildSelectedCustomerCard()
                    else
                      _buildCustomerPickerSection(provider, filteredCustomers),
                  ],

                  const SizedBox(height: 28),

                  // Message Fields Section
                  const Text('Message Title', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'e.g. Special Offer / Order Update',
                      hintStyle: const TextStyle(color: AppColors.grey),
                      filled: true,
                      fillColor: AppColors.card,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.gold),
                      ),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
                  ),

                  const SizedBox(height: 20),

                  const Text('Message Body', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type your message to user here...',
                      hintStyle: const TextStyle(color: AppColors.grey),
                      filled: true,
                      fillColor: AppColors.card,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.gold),
                      ),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a message' : null,
                  ),

                  const SizedBox(height: 32),

                  _isSending
                      ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                      : CustomButton(
                          text: _sendMode == 'all'
                              ? 'SEND TO ALL CUSTOMERS'
                              : (_selectedCustomer != null
                                  ? 'SEND TO ${_selectedCustomer!.fullName.toUpperCase()}'
                                  : 'SELECT A CUSTOMER FIRST'),
                          onPressed: _handleSend,
                        ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSegmentedToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _sendMode = 'specific'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _sendMode == 'specific' ? AppColors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '👤 SPECIFIC CUSTOMER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _sendMode == 'specific' ? Colors.black : Colors.white60,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _sendMode = 'all'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _sendMode == 'all' ? AppColors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '📢 ALL CUSTOMERS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _sendMode == 'all' ? Colors.black : Colors.white60,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastBanner(int totalCustomers) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.campaign, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Broadcast to All Users',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  'This message will be sent to all $totalCustomers registered customers.',
                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.gold.withValues(alpha: 0.2),
            backgroundImage: NetworkImage(_selectedCustomer!.getProfileImage),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedCustomer!.fullName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(_selectedCustomer!.email, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.change_circle_outlined, color: AppColors.gold),
            tooltip: 'Change Customer',
            onPressed: () => setState(() => _selectedCustomer = null),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerPickerSection(AdminCustomerProvider provider, List<UserModel> filteredCustomers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Customer', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search customer by name, email or mobile...',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            prefixIcon: const Icon(Icons.search, color: AppColors.gold, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: provider.isLoading && provider.customers.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
              : (filteredCustomers.isEmpty
                  ? const Center(child: Text('No customers found', style: TextStyle(color: AppColors.grey)))
                  : ListView.builder(
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];
                        final isSelected = _selectedCustomer?.id == customer.id;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                            backgroundImage: NetworkImage(customer.getProfileImage),
                          ),
                          title: Text(
                            customer.fullName,
                            style: TextStyle(
                              color: isSelected ? AppColors.gold : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            '${customer.email} • ${customer.mobile}',
                            style: const TextStyle(color: AppColors.grey, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            color: isSelected ? AppColors.gold : Colors.white24,
                            size: 20,
                          ),
                          onTap: () {
                            setState(() => _selectedCustomer = customer);
                          },
                        );
                      },
                    )),
        ),
      ],
    );
  }
}
