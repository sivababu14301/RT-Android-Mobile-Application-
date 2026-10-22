import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../config/app_colors.dart';
import '../../../models/offer_model.dart';
import '../../../models/product_model.dart';
import '../../../providers/offer_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/admin/admin_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../widgets/custom_button.dart';

class AdminAddEditOfferScreen extends StatefulWidget {
  final OfferModel? offer;
  const AdminAddEditOfferScreen({super.key, this.offer});

  @override
  State<AdminAddEditOfferScreen> createState() => _AdminAddEditOfferScreenState();
}

class _AdminAddEditOfferScreenState extends State<AdminAddEditOfferScreen> {
  late TextEditingController _nameController;
  late TextEditingController _discountController;
  late TextEditingController _descController;
  late TextEditingController _linkController;

  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _endTime = TimeOfDay.now();

  bool _isEnabled = true;
  bool _isSubmitting = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  String _targetType = 'category';
  String _selectedCategory = 'Shirts';
  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
      context.read<ProductProvider>().fetchProducts();
    });

    _nameController = TextEditingController(text: widget.offer?.offerName ?? '');
    _discountController = TextEditingController(text: widget.offer?.discount ?? '');
    _descController = TextEditingController(text: widget.offer?.description ?? '');
    _linkController = TextEditingController(text: widget.offer?.link ?? '');

    if (widget.offer != null) {
      _startDate = widget.offer!.startDateTime;
      _startTime = TimeOfDay.fromDateTime(widget.offer!.startDateTime);
      _endDate = widget.offer!.endDateTime;
      _endTime = TimeOfDay.fromDateTime(widget.offer!.endDateTime);
      _isEnabled = widget.offer!.isEnabled;

      _targetType = widget.offer!.targetType;
      if (widget.offer!.category.isNotEmpty) {
        _selectedCategory = widget.offer!.category;
      }
      if (widget.offer!.productId.isNotEmpty) {
        _selectedProductId = widget.offer!.productId;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _discountController.dispose();
    _descController.dispose();
    _linkController.dispose();
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
      debugPrint("❌ PICK OFFER IMAGE ERROR: $e");
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
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
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
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
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _saveOffer() async {
    if (_isSubmitting) return;

    if (_nameController.text.trim().isEmpty ||
        _discountController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty) {
      _showError('Please fill in all required fields');
      return;
    }

    final start = _combineDateAndTime(_startDate, _startTime);
    final end = _combineDateAndTime(_endDate, _endTime);

    if (end.isBefore(start)) {
      _showError('End date/time must be after start date/time');
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

    debugPrint("[ADMIN OFFER] Submit started");

    final offerProvider = context.read<OfferProvider>();
    String? imageUrl = widget.offer?.offerImage;

    try {
      if (_selectedImage != null) {
        debugPrint("[ADMIN OFFER] Uploading offer image to Cloudinary/Render...");
        imageUrl = await offerProvider.uploadImage(_selectedImage!, token);
        if (imageUrl == null || imageUrl.trim().isEmpty) {
          _showError('Failed to upload image. Please select a valid image file.');
          setState(() {
            _isSubmitting = false;
          });
          return;
        }
      }

      if (imageUrl == null || imageUrl.trim().isEmpty) {
        _showError('Please select an offer image before saving.');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      String targetLink = _linkController.text.trim();
      if (_targetType == 'category') {
        targetLink = _selectedCategory;
      } else if (_targetType == 'product') {
        if (_selectedProductId == null || _selectedProductId!.isEmpty) {
          _showError('Please select a target product for this offer');
          setState(() {
            _isSubmitting = false;
          });
          return;
        }
        targetLink = 'product:$_selectedProductId';
      }

      final offerData = {
        'title': _nameController.text.trim(),
        'offerName': _nameController.text.trim(),
        'discount': _discountController.text.trim(),
        'description': _descController.text.trim(),
        'image': imageUrl,
        'offerImage': imageUrl,
        'link': targetLink,
        'targetType': _targetType,
        'category': _targetType == 'category' ? _selectedCategory : '',
        'categoryId': _targetType == 'category' ? _selectedCategory : '',
        'productId': _targetType == 'product' ? (_selectedProductId ?? '') : '',
        'productIds': _targetType == 'product' && _selectedProductId != null ? [_selectedProductId!] : [],
        'startDate': start.toIso8601String(),
        'endDate': end.toIso8601String(),
        'isActive': _isEnabled,
        'isEnabled': _isEnabled,
      };

      debugPrint("[ADMIN OFFER] API request started");
      String? error;
      if (widget.offer == null) {
        error = await offerProvider.addOffer(offerData, token);
      } else {
        error = await offerProvider.updateOffer(widget.offer!.id, offerData, token);
      }
      debugPrint("[ADMIN OFFER] API response received & submit completed");

      if (mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.offer == null ? 'Offer added successfully' : 'Offer updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          _showError(error);
        }
      }
    } catch (e) {
      debugPrint("❌ [ADMIN OFFER ERROR]: $e");
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
    bool isEdit = widget.offer != null;
    final isLoading = context.watch<OfferProvider>().isLoading;
    final dateFormat = DateFormat('dd MMM yyyy');

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
          isEdit ? 'Edit Offer' : 'Add New Offer',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 24),
            _buildTextField(_nameController, 'Offer Name / Title *', Icons.local_offer_outlined),
            _buildTextField(_discountController, 'Discount Text (e.g. 20% OFF) *', Icons.percent_outlined),
            _buildTextField(_descController, 'Description *', Icons.description_outlined, maxLines: 3),
            
            const SizedBox(height: 10),
            _buildTargetTypeSelector(),
            if (_targetType == 'category') _buildCategorySelector(),
            if (_targetType == 'product') _buildProductSelector(),

            const SizedBox(height: 10),
            const Text('Start Date & Time *', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildPickerTile(Icons.calendar_today, dateFormat.format(_startDate), () => _selectDate(context, true))),
                const SizedBox(width: 12),
                Expanded(child: _buildPickerTile(Icons.access_time, _startTime.format(context), () => _selectTime(context, true))),
              ],
            ),
            const SizedBox(height: 16),
            const Text('End Date & Time *', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildPickerTile(Icons.calendar_today, dateFormat.format(_endDate), () => _selectDate(context, false))),
                const SizedBox(width: 12),
                Expanded(child: _buildPickerTile(Icons.access_time, _endTime.format(context), () => _selectTime(context, false))),
              ],
            ),

            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Offer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              value: _isEnabled,
              activeThumbColor: AppColors.gold,
              onChanged: _isSubmitting ? null : (val) => setState(() => _isEnabled = val),
            ),
            const SizedBox(height: 30),
            (_isSubmitting || isLoading)
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : CustomButton(
                    text: isEdit ? 'UPDATE OFFER' : 'SAVE OFFER',
                    onPressed: _isSubmitting ? () {} : _saveOffer,
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetTypeSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.ads_click, color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _targetType,
                dropdownColor: AppColors.card,
                isExpanded: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                items: const [
                  DropdownMenuItem(value: 'category', child: Text('Target: Product Category')),
                  DropdownMenuItem(value: 'product', child: Text('Target: Specific Product')),
                ],
                onChanged: _isSubmitting ? null : (val) {
                  if (val != null) {
                    setState(() {
                      _targetType = val;
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
        borderRadius: BorderRadius.circular(16),
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
                  child: Text('Category: $cat', style: const TextStyle(color: Colors.white)),
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

  Widget _buildProductSelector() {
    final productProvider = context.watch<ProductProvider>();
    final List<Product> products = productProvider.products;

    if (products.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
        child: const Text('No products available to link.', style: TextStyle(color: AppColors.grey)),
      );
    }

    if (_selectedProductId == null || !products.any((p) => p.id == _selectedProductId)) {
      _selectedProductId = products.first.id;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedProductId,
                dropdownColor: AppColors.card,
                isExpanded: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                items: products.map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Text('${p.name} (₹${p.price.toInt()})', style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: _isSubmitting ? null : (val) {
                  if (val != null) {
                    setState(() {
                      _selectedProductId = val;
                      _linkController.text = 'product:$val';
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

  Widget _buildImagePicker() {
    Widget? imageWidget;
    if (_selectedImage != null) {
      imageWidget = Image.file(_selectedImage!, fit: BoxFit.cover);
    } else if (widget.offer != null) {
      final url = widget.offer!.fullImageUrl.trim();
      if (url.startsWith('data:image/')) {
        try {
          final base64Str = url.split(',').last;
          final bytes = base64Decode(base64Str);
          imageWidget = Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: AppColors.gold),
          );
        } catch (_) {}
      } else if (url.isNotEmpty) {
        imageWidget = Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: AppColors.gold),
        );
      }
    }

    return GestureDetector(
      onTap: _isSubmitting ? null : _pickImage,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              if (imageWidget != null) Positioned.fill(child: imageWidget),
              if (imageWidget != null) Container(color: Colors.black38),
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, color: AppColors.gold, size: 40),
                    SizedBox(height: 8),
                    Text('Upload Offer Banner Image', style: TextStyle(color: AppColors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        enabled: !_isSubmitting,
        maxLines: maxLines,
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

  Widget _buildPickerTile(IconData icon, String value, VoidCallback onTap) {
    return InkWell(
      onTap: _isSubmitting ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 18),
            const SizedBox(width: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
