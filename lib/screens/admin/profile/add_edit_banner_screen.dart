import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class AddEditBannerScreen extends StatefulWidget {
  final Map<String, dynamic>? banner;
  const AddEditBannerScreen({super.key, this.banner});

  @override
  State<AddEditBannerScreen> createState() => _AddEditBannerScreenState();
}

class _AddEditBannerScreenState extends State<AddEditBannerScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _btnTextController;
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;

  final DateFormat _formatter = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.banner?['title'] ?? '');
    _descController = TextEditingController(text: widget.banner?['description'] ?? '');
    _btnTextController = TextEditingController(text: 'Shop Now');
    
    if (widget.banner != null) {
      _isActive = widget.banner!['isActive'];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _btnTextController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.gold, onPrimary: Colors.black, surface: AppColors.card),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => isStartDate ? _startDate = picked : _endDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.banner != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isEdit ? 'Edit Home Banner' : 'Add New Banner', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.close, color: AppColors.gold), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('BANNER IMAGE', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  image: widget.banner != null ? DecorationImage(
                    image: NetworkImage(widget.banner!['imageUrl']),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.5), BlendMode.darken),
                  ) : null,
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, color: AppColors.gold, size: 32),
                    SizedBox(height: 8),
                    Text('Change Banner Image', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('BANNER CONTENT', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            CustomTextField(hintText: 'Main Title', prefixIcon: Icons.title, controller: _titleController),
            CustomTextField(hintText: 'Subtitle/Description', prefixIcon: Icons.subtitles_outlined, controller: _descController),
            CustomTextField(hintText: 'Button Text', prefixIcon: Icons.smart_button_outlined, controller: _btnTextController),
            
            const SizedBox(height: 16),
            const Text('VISIBILITY TIMING', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDateTile('Starts', _startDate, () => _selectDate(context, true))),
                const SizedBox(width: 16),
                Expanded(child: _buildDateTile('Expires', _endDate, () => _selectDate(context, false))),
              ],
            ),
            
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Active Status', style: TextStyle(color: Colors.white, fontSize: 14)),
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
              activeThumbColor: AppColors.gold,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              tileColor: AppColors.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 48),
            CustomButton(text: 'SAVE BANNER CONFIG', onPressed: () => Navigator.pop(context)),
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
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 10)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.gold, size: 14),
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
