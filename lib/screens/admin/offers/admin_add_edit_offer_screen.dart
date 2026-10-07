import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/app_colors.dart';
import '../../../models/offer_model.dart';
import '../../../providers/offer_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/admin/admin_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class AdminAddEditOfferScreen extends StatefulWidget {
  final OfferModel? offer;
  const AdminAddEditOfferScreen({super.key, this.offer});

  @override
  State<AdminAddEditOfferScreen> createState() => _AdminAddEditOfferScreenState();
}

class _AdminAddEditOfferScreenState extends State<AdminAddEditOfferScreen> {
  final _nameController = TextEditingController();
  final _discountController = TextEditingController();
  final _descController = TextEditingController();
  final _linkController = TextEditingController();

  bool _isSubmitting = false;
  String _linkType = 'Category'; // 'Category' or 'Product'
  String _selectedCategoryLink = 'Wedding Collection';
  String _selectedProductId = '';
  
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _endTime = TimeOfDay.now();
  
  bool _isEnabled = true;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
      context.read<ProductProvider>().fetchProducts();
    });

    if (widget.offer != null) {
      _nameController.text = widget.offer!.offerName;
      _discountController.text = widget.offer!.discount;
      _descController.text = widget.offer!.description;
      _startDate = widget.offer!.startDateTime;
      _startTime = TimeOfDay.fromDateTime(widget.offer!.startDateTime);
      _endDate = widget.offer!.endDateTime;
      _endTime = TimeOfDay.fromDateTime(widget.offer!.endDateTime);
      _isEnabled = widget.offer!.isEnabled;
      
      final linkStr = widget.offer!.link.trim();
      if (linkStr.startsWith('product:')) {
        _linkType = 'Product';
        _selectedProductId = linkStr.replaceFirst('product:', '');
        _linkController.text = linkStr;
      } else if (linkStr.isNotEmpty && linkStr != 'All') {
        _linkType = 'Category';
        _selectedCategoryLink = linkStr;
        _linkController.text = linkStr;
      } else {
        _linkType = 'Category';
        _selectedCategoryLink = 'Wedding Collection';
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

  Future<void> _pickDateTime(bool isStart) async {
    if (_isSubmitting) return;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.gold,
            onPrimary: Colors.black,
            surface: AppColors.card,
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: isStart ? _startTime : _endTime,
      );

      if (pickedTime != null) {
        setState(() {
          if (isStart) {
            _startDate = pickedDate;
            _startTime = pickedTime;
          } else {
            _endDate = pickedDate;
            _endTime = pickedTime;
          }
        });
      }
    }
  }

  void _saveOffer() async {
    if (_isSubmitting) return; // Prevent duplicate requests on multiple taps

    if (_nameController.text.trim().isEmpty || _discountController.text.trim().isEmpty) {
      _showError('Please fill all required fields');
      return;
    }

    final start = DateTime(_startDate.year, _startDate.month, _startDate.day, _startTime.hour, _startTime.minute);
    final end = DateTime(_endDate.year, _endDate.month, _endDate.day, _endTime.hour, _endTime.minute);

    if (end.isBefore(start)) {
      _showError('End date must be after Start date');
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
        if (imageUrl == null) {
          _showError('Failed to upload image');
          return;
        }
      }

      if (imageUrl == null || imageUrl.isEmpty) {
        _showError('Please select an image');
        return;
      }

      String finalTargetType = _linkType.toLowerCase();
      String finalLink = _selectedCategoryLink;
      String finalCategory = _selectedCategoryLink;
      String finalProductId = '';
      List<String> finalProductIds = [];

      if (_linkType == 'Product') {
        finalTargetType = 'product';
        final productProvider = context.read<ProductProvider>();
        if (_selectedProductId.isEmpty && productProvider.allProducts.isNotEmpty) {
          _selectedProductId = productProvider.allProducts.first.id;
        }
        finalProductId = _selectedProductId;
        finalProductIds = [_selectedProductId];
        finalLink = 'product:$_selectedProductId';
      } else {
        finalTargetType = 'category';
        finalLink = _selectedCategoryLink;
        finalCategory = _selectedCategoryLink;
      }

      final offerData = {
        'title': _nameController.text.trim(),
        'discount': _discountController.text.trim(),
        'description': _descController.text.trim(),
        'image': imageUrl,
        'targetType': finalTargetType,
        'category': finalCategory,
        'categoryName': finalCategory,
        'target': finalLink,
        'link': finalLink,
        'productId': finalProductId,
        'productIds': finalProductIds,
        'startDate': start.toIso8601String(),
        'endDate': end.toIso8601String(),
        'isActive': _isEnabled,
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
            SnackBar(content: Text(widget.offer == null ? 'Offer added successfully' : 'Offer updated successfully'), backgroundColor: Colors.green),
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<OfferProvider>().isLoading;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.offer == null ? 'Add Offer' : 'Edit Offer', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildImagePicker(),
            const SizedBox(height: 32),
            CustomTextField(hintText: 'Offer Name', prefixIcon: Icons.title, controller: _nameController),
            CustomTextField(hintText: 'Discount (e.g. 20% OFF)', prefixIcon: Icons.percent, controller: _discountController),
            CustomTextField(hintText: 'Description', prefixIcon: Icons.description, controller: _descController),
            const SizedBox(height: 12),
            _buildTargetSelector(),
            const SizedBox(height: 16),
            _buildDateTimePicker('Start Date & Time', _startDate, _startTime, () => _pickDateTime(true)),
            const SizedBox(height: 16),
            _buildDateTimePicker('End Date & Time', _endDate, _endTime, () => _pickDateTime(false)),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Offer Status', style: TextStyle(color: Colors.white, fontSize: 16)),
              subtitle: Text(_isEnabled ? 'Active' : 'Inactive', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              value: _isEnabled,
              activeThumbColor: AppColors.gold,
              onChanged: _isSubmitting ? null : (val) => setState(() => _isEnabled = val),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 48),
            (_isSubmitting || isLoading)
              ? const CircularProgressIndicator(color: AppColors.gold)
              : CustomButton(text: widget.offer == null ? 'SAVE OFFER' : 'UPDATE OFFER', onPressed: _isSubmitting ? () {} : _saveOffer),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSelector() {
    final categoryProvider = context.watch<CategoryProvider>();
    final productProvider = context.watch<ProductProvider>();

    final List<String> availableCategories = ['Wedding Collection', 'Shirts', 'Pants', 'T-Shirts', 'Suits', 'Uniforms', 'All'];

    for (var cat in categoryProvider.categories) {
      if (!availableCategories.contains(cat.name) && cat.name.isNotEmpty) {
        availableCategories.add(cat.name);
      }
    }

    if (!_selectedCategoryLink.startsWith('product:') && !availableCategories.contains(_selectedCategoryLink)) {
      availableCategories.add(_selectedCategoryLink);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Linked Offer Target', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Category Offer'),
                selected: _linkType == 'Category',
                selectedColor: AppColors.gold,
                backgroundColor: AppColors.card,
                labelStyle: TextStyle(color: _linkType == 'Category' ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                onSelected: _isSubmitting ? null : (val) {
                  if (val) setState(() => _linkType = 'Category');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Text('Specific Product'),
                selected: _linkType == 'Product',
                selectedColor: AppColors.gold,
                backgroundColor: AppColors.card,
                labelStyle: TextStyle(color: _linkType == 'Product' ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                onSelected: _isSubmitting ? null : (val) {
                  if (val) setState(() => _linkType = 'Product');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_linkType == 'Category')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: availableCategories.contains(_selectedCategoryLink) ? _selectedCategoryLink : availableCategories[0],
                dropdownColor: AppColors.card,
                isExpanded: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                items: availableCategories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat, style: const TextStyle(color: Colors.white)),
                )).toList(),
                onChanged: _isSubmitting ? null : (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategoryLink = val;
                      _linkController.text = val;
                    });
                  }
                },
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: productProvider.allProducts.any((p) => p.id == _selectedProductId)
                    ? _selectedProductId
                    : (productProvider.allProducts.isNotEmpty ? productProvider.allProducts.first.id : null),
                hint: const Text('Select a Product', style: TextStyle(color: Colors.white70)),
                dropdownColor: AppColors.card,
                isExpanded: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                items: productProvider.allProducts.map((prod) => DropdownMenuItem(
                  value: prod.id,
                  child: Text('${prod.name} (₹${prod.price.toInt()})', style: const TextStyle(color: Colors.white)),
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
    );
  }

  Widget _buildImagePicker() {
    Widget? imageWidget;
    if (_selectedImage != null) {
      imageWidget = Image.file(_selectedImage!, fit: BoxFit.cover);
    } else if (widget.offer != null) {
      imageWidget = Image.network(widget.offer!.fullImageUrl, fit: BoxFit.cover);
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
                    SizedBox(height: 12),
                    Text('Change Offer Image', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(String label, DateTime date, TimeOfDay time, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isSubmitting ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: AppColors.gold, size: 16),
                const SizedBox(width: 10),
                Text('${_dateFormat.format(date)}  •  ${time.format(context)}', style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
