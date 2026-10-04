import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../widgets/custom_button.dart';

class UpdateOrderStatusScreen extends StatefulWidget {
  final String currentStatus;
  const UpdateOrderStatusScreen({super.key, this.currentStatus = 'Pending'});

  @override
  State<UpdateOrderStatusScreen> createState() => _UpdateOrderStatusScreenState();
}

class _UpdateOrderStatusScreenState extends State<UpdateOrderStatusScreen> {
  late String _selectedStatus;
  final List<String> _statuses = [
    'Order Placed',
    'Order Confirmed',
    'Stitching',
    'Ready',
    'Out for Delivery',
    'Delivered',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    final lower = widget.currentStatus.trim().toLowerCase();
    if (lower == 'pending') {
      _selectedStatus = 'Order Placed';
    } else if (lower == 'confirmed') {
      _selectedStatus = 'Order Confirmed';
    } else {
      _selectedStatus = widget.currentStatus;
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
        title: const Text('Update Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change order progress status',
              style: TextStyle(color: AppColors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _statuses.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedStatus == _statuses[index];
                return GestureDetector(
                  onTap: () => setState(() => _selectedStatus = _statuses[index]),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? AppColors.gold : AppColors.goldBorder.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? AppColors.gold : AppColors.grey,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _statuses[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.grey,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'UPDATE ORDER STATUS',
              onPressed: () {
                Navigator.pop(context, _selectedStatus);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
