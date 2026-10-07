import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_colors.dart';
import '../../models/banner_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/banner_provider.dart';
import '../../providers/admin/admin_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';

class AddEditBannerScreen extends StatefulWidget {
  final BannerModel? banner;
  const AddEditBannerScreen({super.key, this.banner});

  @override
  State<AddEditBannerScreen> createState() => _AddEditBannerScreenState();
}

class _AddEditBannerScreenState extends State<AddEditBannerScreen> {
  late TextEditingController _titleController;
  late TextEditingController _linkController;
  late TextEditingController _orderController;
  
  bool _isSubmitting = false;
  String _selectedCategory = 'Shirts';
  bool _isActive = true;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });

    _titleController = TextEditingController(text: widget.banner?.title ?? '');
    _linkController = TextEditingController(text: widget.banner?.link ?? '');
    _orderController = TextEditingController(text: widget.banner?.order.toString() ?? '0');
    _isActive = widget.banner?.isActive ?? true;

    if (widget.banner != null) {
      final bannerCat = widget.banner!.category.trim();
      final bannerLink = widget.banner!.link.trim();
      if (bannerCat.isNotEmpty && bannerCat != 'All') {
        _selectedCategory = bannerCat;
      } else if (bannerLink.isNotEmpty && bannerLink != 'All') {
        _selectedCategory = bannerLink;
      } else {
        _selectedCategory = 'Shirts';
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    _orderController.dispose();
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
      debugPrint("❌ PICK BANNER IMAGE ERROR: $e");
    }
  }

  void _saveBanner() async {
    if (_isSubmitting) return; // Prevent duplicate requests on multiple taps

    if (_titleController.text.trim().isEmpty) {
      _showError('Please enter a title');
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

    debugPrint("[ADMIN BANNER] Submit started");

    final bannerProvider = context.read<BannerProvider>();
    String? imageUrl = widget.banner?.image;

    try {
      if (_selectedImage != null) {
        debugPrint("[ADMIN BANNER] Uploading banner image to Cloudinary/Render...");
        imageUrl = await bannerProvider.uploadImage(_selectedImage!, token);
        if (imageUrl == null) {
          _showError('Failed to upload image');
          return;
        }
      }

      if (imageUrl == null || imageUrl.isEmpty) {
        _showError('Please select an image');
        return;
      }

      final bannerData = {
        'title': _titleController.text.trim(),
        'image': imageUrl,
        'link': _selectedCategory,
        'category': _selectedCategory,
        'categoryId': _selectedCategory,
        'targetType': 'category',
        'isActive': _isActive,
        'order': int.tryParse(_orderController.text.trim()) ?? 0,
      };

      debugPrint("[ADMIN BANNER] API request started");
      String? error;
      if (widget.banner == null) {
        error = await bannerProvider.addBanner(bannerData, token);
      } else {
        error = await bannerProvider.updateBanner(widget.banner!.id, bannerData, token);
      }
      debugPrint("[ADMIN BANNER] API response received & submit completed");

      if (mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.banner == null ? 'Banner added successfully' : 'Banner updated successfully'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          _showError(error);
        }
      }
    } catch (e) {
      debugPrint("❌ [ADMIN BANNER ERROR]: $e");
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.contains('receive timeout') || errorMsg.contains('took longer than')) {
          errorMsg = 'Request timed out uploading image. Please check your network and try again.';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.banner != null;
    final isLoading = context.watch<BannerProvider>().isLoading;

    Widget? imageWidget;
    if (_selectedImage != null) {
      imageWidget = Image.file(_selectedImage!, fit: BoxFit.cover);
    } else if (widget.banner != null) {
      imageWidget = Image.network(
        widget.banner!.fullImageUrl,
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
          isEdit ? 'Edit Banner' : 'Add New Banner',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isSubmitting ? null : _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: imageWidget ?? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, color: AppColors.gold, size: 40),
                      SizedBox(height: 8),
                      Text('Upload Banner Image (1200x600)', style: TextStyle(color: AppColors.grey)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildAdminTextField(_titleController, 'Banner Title', Icons.title),
            _buildCategorySelector(),
            _buildAdminTextField(_orderController, 'Display Order', Icons.sort, keyboardType: TextInputType.number),
            
            SwitchListTile(
              title: const Text('Active Status', style: TextStyle(color: Colors.white)),
              value: _isActive,
              activeThumbColor: AppColors.gold,
              onChanged: _isSubmitting ? null : (val) => setState(() => _isActive = val),
            ),
            const SizedBox(height: 30),
            (_isSubmitting || isLoading)
                ? const CircularProgressIndicator(color: AppColors.gold)
                : CustomButton(
                    text: isEdit ? 'UPDATE BANNER' : 'SAVE BANNER',
                    onPressed: _isSubmitting ? () {} : _saveBanner,
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categoryProvider = context.watch<CategoryProvider>();
    final List<String> categories = ['Shirts', 'Pants', 'T-Shirts', 'Suits', 'Wedding Collection', 'Uniforms', 'All'];

    for (var cat in categoryProvider.categories) {
      if (!categories.contains(cat.name) && cat.name.isNotEmpty) {
        categories.add(cat.name);
      }
    }

    if (!categories.contains(_selectedCategory) && _selectedCategory.isNotEmpty) {
      categories.add(_selectedCategory);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.category_outlined, color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: categories.contains(_selectedCategory) ? _selectedCategory : categories[0],
                dropdownColor: AppColors.card,
                isExpanded: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                items: categories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text('Target Category: $cat', style: const TextStyle(color: Colors.white)),
                )).toList(),
                onChanged: _isSubmitting ? null : (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                      _linkController.text = val;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        enabled: !_isSubmitting,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.grey),
          prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
