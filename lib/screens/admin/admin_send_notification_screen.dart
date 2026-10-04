import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/admin/admin_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/custom_button.dart';

class AdminSendNotificationScreen extends StatefulWidget {
  final UserModel customer;
  const AdminSendNotificationScreen({super.key, required this.customer});

  @override
  State<AdminSendNotificationScreen> createState() => _AdminSendNotificationScreenState();
}

class _AdminSendNotificationScreenState extends State<AdminSendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: 'Message from Raymaans Tailors');
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final token = context.read<AdminProvider>().admin?.token;
      if (token == null) throw 'Authentication error';

      final result = await context.read<NotificationProvider>().sendAdminMessage(
        userId: widget.customer.id,
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        token: token,
      );

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message sent successfully!'), backgroundColor: AppColors.success),
          );
          Navigator.pop(context);
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
        title: Text(
          'Message to ${widget.customer.fullName}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerBrief(),
              const SizedBox(height: 30),
              const Text('Title', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter title...',
                  hintStyle: const TextStyle(color: AppColors.grey),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 24),
              const Text('Message', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _messageController,
                maxLines: 8,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type your message here...',
                  hintStyle: const TextStyle(color: AppColors.grey),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter a message' : null,
              ),
              const SizedBox(height: 40),
              _isSending
                  ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                  : CustomButton(
                      text: 'SEND MESSAGE',
                      onPressed: _handleSend,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerBrief() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.gold.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.gold.withOpacity(0.2),
            backgroundImage: NetworkImage(widget.customer.getProfileImage),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.customer.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(widget.customer.email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
