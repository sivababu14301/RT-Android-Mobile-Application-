import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_colors.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/admin/admin_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final CategoryModel? category;
  const AddEditCategoryScreen({super.key, this.category});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  
  bool _isSubmitting = false;
  bool _isActive = true;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descController = TextEditingController(text: widget.category?.description ?? '');
    _isActive = widget.category?.isActive ?? true;

    // Listen to name changes to update live icon preview
    _nameController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("❌ OPTIONAL PICK CATEGORY IMAGE ERROR: $e");
    }
  }

  void _saveCategory() async {
    if (_isSubmitting) return; // Prevent duplicate requests on multiple taps

    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter a category name');
      return;
    }

    final adminProvider = context.read<AdminProvider>();
    final userProvider = context.read<UserProvider>();
    final token = adminProvider.admin?.token ?? userProvider.user?.token;

    if (token == null) {
      _showError('Not authorized');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    debugPrint("[ADMIN CATEGORY] Submit started");

    final categoryProvider = context.read<CategoryProvider>();
    String uploadedImageUrl = widget.category?.image ?? '';

    try {
      // Optional image upload
      if (_selectedImage != null) {
        debugPrint("[ADMIN CATEGORY] Uploading optional category image...");
        final newUrl = await categoryProvider.uploadImage(_selectedImage!, token);
        if (newUrl != null && newUrl.isNotEmpty) {
          uploadedImageUrl = newUrl;
        }
      }

      final categoryData = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim().isEmpty ? 'Custom Tailored Collection' : _descController.text.trim(),
        'isActive': _isActive,
        'image': uploadedImageUrl,
      };

      debugPrint("[ADMIN CATEGORY] API request started");
      String? errorMessage;
      if (widget.category == null) {
        errorMessage = await categoryProvider.addCategory(categoryData, token);
      } else {
        errorMessage = await categoryProvider.updateCategory(widget.category!.id, categoryData, token);
      }
      debugPrint("[ADMIN CATEGORY] API response received & submit completed");

      if (mounted) {
        if (errorMessage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.category == null ? 'Category added successfully' : 'Category updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          _showError(errorMessage);
        }
      }
    } catch (e) {
      debugPrint("❌ [ADMIN CATEGORY ERROR]: $e");
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.contains('receive timeout') || errorMsg.contains('took longer than')) {
          errorMsg = 'Request timed out. Please check your network and try again.';
        }
        _showError(errorMsg);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.category != null;
    final isLoading = context.watch<CategoryProvider>().isLoading;
    final IconData smartIcon = CategoryModel.getIconForName(_nameController.text);

    Widget? imageWidget;
    if (_selectedImage != null) {
      imageWidget = Image.file(_selectedImage!, fit: BoxFit.cover);
    } else if (widget.category != null && widget.category!.image.startsWith('http')) {
      imageWidget = Image.network(
        widget.category!.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(smartIcon, color: AppColors.gold, size: 48),
      );
    }

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
          isEdit ? 'Edit Category' : 'Add Category',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Smart Icon Preview
            GestureDetector(
              onTap: _isSubmitting ? null : _pickImage,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: imageWidget ?? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(smartIcon, color: AppColors.gold, size: 48),
                      const SizedBox(height: 4),
                      const Text('Change Photo', style: TextStyle(color: AppColors.grey, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Category Icon Preview: ${_nameController.text.isEmpty ? "Default" : _nameController.text}',
              style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _nameController,
                enabled: !_isSubmitting,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  labelStyle: TextStyle(color: AppColors.grey),
                  prefixIcon: Icon(Icons.category_outlined, color: AppColors.gold, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _descController,
                enabled: !_isSubmitting,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(color: AppColors.grey),
                  prefixIcon: Icon(Icons.description_outlined, color: AppColors.gold, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Enable Category', style: TextStyle(color: Colors.white)),
              value: _isActive,
              activeThumbColor: AppColors.gold,
              onChanged: _isSubmitting ? null : (val) => setState(() => _isActive = val),
            ),
            const SizedBox(height: 40),
            (_isSubmitting || isLoading)
              ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
              : CustomButton(
                  text: isEdit ? 'UPDATE CATEGORY' : 'SAVE CATEGORY',
                  onPressed: _isSubmitting ? () {} : _saveCategory,
                ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
