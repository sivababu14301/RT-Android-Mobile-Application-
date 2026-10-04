import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class AddEditOfferScreen extends StatefulWidget {
  final Map<String, dynamic>? offer;
  const AddEditOfferScreen({super.key, this.offer});

  @override
  State<AddEditOfferScreen> createState() => _AddEditOfferScreenState();
}

class _AddEditOfferScreenState extends State<AddEditOfferScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _discountController;
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isActive = true;

  final DateFormat _formatter = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.offer?['title'] ?? '');
    _descController = TextEditingController(text: widget.offer?['description'] ?? '');
    _discountController = TextEditingController(text: widget.offer?['discount'] ?? '');
    
    if (widget.offer != null) {
      _isActive = widget.offer!['status'] == 'Active';
      // In a real app, parse the date strings back to DateTime objects
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold,
              onPrimary: Colors.black,
              surface: AppColors.card,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.offer != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEdit ? 'Edit Offer' : 'Add New Offer',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('OFFER BANNER IMAGE', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.2)),
                  image: widget.offer != null ? DecorationImage(
                    image: NetworkImage(widget.offer!['imageUrl']),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.4), BlendMode.darken),
                  ) : null,
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, color: AppColors.gold, size: 32),
                    SizedBox(height: 8),
                    Text('Change Offer Image', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('OFFER DETAILS', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Offer Name',
              prefixIcon: Icons.local_offer_outlined,
              controller: _nameController,
            ),
            CustomTextField(
              hintText: 'Discount (e.g., 20% OFF)',
              prefixIcon: Icons.percent_rounded,
              controller: _discountController,
            ),
            CustomTextField(
              hintText: 'Short Description',
              prefixIcon: Icons.description_outlined,
              controller: _descController,
            ),
            
            const SizedBox(height: 16),
            const Text('OFFER VALIDITY (TIMING)', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDateTile('Start Date', _startDate, () => _selectDate(context, true))),
                const SizedBox(width: 16),
                Expanded(child: _buildDateTile('End Date', _endDate, () => _selectDate(context, false))),
              ],
            ),
            
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Active Status', style: TextStyle(color: Colors.white, fontSize: 14)),
                  Switch(
                    value: _isActive,
                    onChanged: (val) => setState(() => _isActive = val),
                    activeThumbColor: AppColors.gold,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: isEdit ? 'UPDATE OFFER' : 'CREATE OFFER',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEdit ? 'Offer updated successfully!' : 'Offer created!'), backgroundColor: Colors.green),
                );
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTile(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 10)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_month, color: AppColors.gold, size: 14),
                const SizedBox(width: 8),
                Text(_formatter.format(date), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
