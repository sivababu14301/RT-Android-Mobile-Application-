import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../widgets/custom_button.dart';

class AssignTailorScreen extends StatefulWidget {
  const AssignTailorScreen({super.key});

  @override
  State<AssignTailorScreen> createState() => _AssignTailorScreenState();
}

class _AssignTailorScreenState extends State<AssignTailorScreen> {
  String? _selectedTailor;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 3));

  final List<String> _tailors = [
    'Master Ahmad (Suits Specialist)',
    'Master Rajesh (Shirts & Pants)',
    'Master Kumar (Uniforms)',
    'Master Selvam (Premium Stitching)',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
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
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
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
        title: const Text('Assign Tailor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a tailor for this order',
              style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTailor,
                  hint: const Text('Select Tailor', style: TextStyle(color: AppColors.grey)),
                  isExpanded: true,
                  dropdownColor: AppColors.card,
                  style: const TextStyle(color: Colors.white),
                  items: _tailors.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() => _selectedTailor = newValue);
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Expected Completion Date',
              style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: AppColors.gold),
                  ],
                ),
              ),
            ),
            const Spacer(),
            CustomButton(
              text: 'ASSIGN TAILORING WORK',
              onPressed: () {
                if (_selectedTailor == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a tailor')),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order assigned to $_selectedTailor')),
                );
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
