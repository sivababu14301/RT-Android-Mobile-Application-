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
  bool _isActive = true;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descController = TextEditingController(text: widget.category?.description ?? '');
    _isActive = widget.category?.isActive ?? true;
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
      debugPrint("❌ PICK IMAGE ERROR: $e");
    }
  }

  void _saveCategory() async {
    if (_nameController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final adminProvider = context.read<AdminProvider>();
    final userProvider = context.read<UserProvider>();
    final token = adminProvider.admin?.token ?? userProvider.user?.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authorized')),
      );
      return;
    }

    final categoryProvider = context.read<CategoryProvider>();
    String? uploadedImageUrl = widget.category?.image;

    try {
      // 1. Upload image if selected
      if (_selectedImage != null) {
        final newUrl = await categoryProvider.uploadImage(_selectedImage!, token);
        if (newUrl != null) {
          uploadedImageUrl = newUrl;
        } else {
          _showError('Failed to upload image');
          return;
        }
      }

      final categoryData = {
        'name': _nameController.text,
        'description': _descController.text,
        'isActive': _isActive,
        'image': uploadedImageUrl ?? '',
      };

      String? errorMessage;
      if (widget.category == null) {
        errorMessage = await categoryProvider.addCategory(categoryData, token);
      } else {
        errorMessage = await categoryProvider.updateCategory(widget.category!.id, categoryData, token);
      }

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
      _showError(e.toString());
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

    // Resolve image to display
    Widget? imageWidget;
    if (_selectedImage != null) {
      imageWidget = Image.file(_selectedImage!, fit: BoxFit.cover);
    } else if (widget.category != null && widget.category!.image.isNotEmpty) {
      final baseServerUrl = Platform.isAndroid ? 'http://10.0.2.2:5000' : 'http://localhost:5000';
      final fullUrl = widget.category!.image.startsWith('http') 
          ? widget.category!.image 
          : '$baseServerUrl${widget.category!.image.startsWith('/') ? '' : '/'}${widget.category!.image}';
      
      imageWidget = Image.network(
        fullUrl, 
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: AppColors.gold),
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
            // Icon Upload Area
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.3)),
                ),
                child: ClipOval(
                  child: imageWidget ?? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, color: AppColors.gold, size: 30),
                      SizedBox(height: 4),
                      Text('Icon', style: TextStyle(color: AppColors.grey, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _nameController,
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
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Description',
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
              onChanged: (val) => setState(() => _isActive = val),
            ),
            const SizedBox(height: 40),
            isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
              : CustomButton(
                  text: isEdit ? 'UPDATE CATEGORY' : 'SAVE CATEGORY',
                  onPressed: _saveCategory,
                ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
