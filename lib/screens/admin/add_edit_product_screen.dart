import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/admin/admin_provider.dart';
import '../../providers/fabric_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/custom_button.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descController;
  late TextEditingController _colorsController;
  
  bool _isSubmitting = false;
  String _selectedCategory = 'Shirts';
  List<String> _selectedFabrics = ['Cotton'];
  List<String> _selectedSizes = [];
  bool _isFeatured = false;
  bool _allowCustomFit = false;
  
  final List<File> _selectedImageFiles = [];
  final ImagePicker _picker = ImagePicker();

  bool get _isPantCategory => Product.isPantCategory(_selectedCategory);

  List<String> get _standardSizes =>
      _isPantCategory ? ['32', '34', '36', '38', '40'] : ['S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
    _descController = TextEditingController(text: widget.product?.description ?? '');
    _colorsController = TextEditingController(text: widget.product?.colors.join(', ') ?? '');
    
    if (widget.product != null) {
      _selectedCategory = widget.product!.category;
      if (widget.product!.fabrics.isNotEmpty) {
        _selectedFabrics = List.from(widget.product!.fabrics);
      } else if (widget.product!.fabric.isNotEmpty) {
        _selectedFabrics = widget.product!.fabric.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
      if (_selectedFabrics.isEmpty) {
        _selectedFabrics = ['Cotton'];
      }
      
      if (widget.product!.isPantProduct) {
        _selectedSizes = widget.product!.sizes.map((s) => Product.mapPantSizeToNumeric(s)).toList();
      } else {
        _selectedSizes = List.from(widget.product!.sizes);
      }
      
      _isFeatured = false;
      _allowCustomFit = widget.product!.allowCustomFit || widget.product!.sizes.contains('Custom Fit');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
      final token = context.read<UserProvider>().user?.token ?? context.read<AdminProvider>().admin?.token;
      if (token != null) {
        context.read<FabricProvider>().fetchAllFabrics(token);
      } else {
        context.read<FabricProvider>().fetchActiveFabrics();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    _colorsController.dispose();
    super.dispose();
  }

  void _toggleFabricSelection(String fabric) {
    setState(() {
      if (_selectedFabrics.contains(fabric)) {
        if (_selectedFabrics.length > 1) {
          _selectedFabrics.remove(fabric);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('At least one fabric must be selected')),
          );
        }
      } else {
        _selectedFabrics.add(fabric);
      }
    });
  }

  void _showAddExtraFabricDialog(BuildContext parentContext) {
    final extraController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.goldBorder, width: 0.5),
          ),
          title: const Text(
            'Add Extra Fabric',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: extraController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Extra Fabric Name',
                labelStyle: const TextStyle(color: AppColors.gold),
                hintText: 'e.g. Ramthuri, Lycra, Velvet',
                hintStyle: const TextStyle(color: Colors.white38),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter fabric name';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final token = parentContext.read<AdminProvider>().admin?.token ?? parentContext.read<UserProvider>().user?.token;
                  if (token == null) return;

                  final fabricName = extraController.text.trim();
                  Navigator.pop(dialogContext);

                  final result = await parentContext.read<FabricProvider>().addFabric(fabricName, token);

                  if (mounted) {
                    if (result['success'] == true) {
                      setState(() {
                        if (!_selectedFabrics.contains(fabricName)) {
                          _selectedFabrics.add(fabricName);
                        }
                      });
                      if (parentContext.mounted) {
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          SnackBar(
                            content: Text('Fabric "$fabricName" added to MongoDB and selected!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      if (parentContext.mounted) {
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          SnackBar(
                            content: Text(result['message'] ?? 'Failed to add fabric'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('SAVE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImageFiles.addAll(images.map((xfile) => File(xfile.path)));
        });
      }
    } catch (e) {
      debugPrint("❌ PICK MULTI-IMAGES FAILED, RETRYING SINGLE PICKER: $e");
      try {
        final XFile? singleImage = await _picker.pickImage(source: ImageSource.gallery);
        if (singleImage != null) {
          setState(() {
            _selectedImageFiles.add(File(singleImage.path));
          });
        }
      } catch (err) {
        debugPrint("❌ SINGLE IMAGE PICKER ERROR: $err");
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImageFiles.removeAt(index);
    });
  }

  void _toggleSize(String size) {
    setState(() {
      if (_selectedSizes.contains(size)) {
        _selectedSizes.remove(size);
      } else {
        _selectedSizes.add(size);
      }
    });
  }

  void _saveProduct() async {
    if (_isSubmitting) return;

    if (_nameController.text.trim().isEmpty) {
      _showError('Product name is required');
      return;
    }

    final double? price = double.tryParse(_priceController.text.trim());
    if (price == null || price < 0) {
      _showError('Please enter a valid price');
      return;
    }

    final int? stock = int.tryParse(_stockController.text.trim());
    if (stock == null || stock < 0) {
      _showError('Please enter a valid stock count');
      return;
    }

    if (_descController.text.trim().isEmpty) {
      _showError('Description is required');
      return;
    }

    if (_selectedSizes.isEmpty) {
      _showError('Please select at least one size');
      return;
    }

    if (_selectedFabrics.isEmpty) {
      _showError('Please select at least one fabric');
      return;
    }

    final productProvider = context.read<ProductProvider>();
    final userProvider = context.read<UserProvider>();
    final adminProvider = context.read<AdminProvider>();
    
    final token = adminProvider.admin?.token ?? userProvider.user?.token;

    if (token == null) {
      _showError('Not authorized. Please login as Admin again.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    debugPrint("[ADMIN PRODUCT] Submit started");

    try {
      List<String> imageUrls = widget.product?.images != null ? List<String>.from(widget.product!.images) : [];

      if (_selectedImageFiles.isNotEmpty) {
        debugPrint("[ADMIN PRODUCT] Uploading images...");
        final newUrls = await productProvider.uploadImages(_selectedImageFiles, token);
        imageUrls.addAll(newUrls);
      }

      bool isShirtOrPant = (_selectedCategory.toLowerCase().contains('shirt') && !_selectedCategory.toLowerCase().contains('t-shirt')) ||
                           _selectedCategory.toLowerCase().contains('pant');

      final Map<String, dynamic> productData = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'category': _selectedCategory,
        'price': price, 
        'stock': stock, 
        'fabric': _selectedFabrics.join(', '),
        'fabrics': _selectedFabrics,
        'sizes': _selectedSizes, 
        'colors': _colorsController.text.split(',').map((c) => c.trim()).where((c) => c.isNotEmpty).toList(),
        'images': imageUrls,
        'isFeatured': _isFeatured,
        'allowCustomFit': isShirtOrPant ? true : (_allowCustomFit || _selectedSizes.contains('Custom Fit')),
      };

      debugPrint("[ADMIN PRODUCT] API request started");
      if (widget.product != null) {
        await productProvider.updateProduct(widget.product!.id, productData, token);
      } else {
        await productProvider.addProduct(productData, token);
      }
      debugPrint("[ADMIN PRODUCT] API response received & submit completed");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product != null ? 'Product updated successfully' : 'Product added successfully'), 
            backgroundColor: Colors.green
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("❌ [ADMIN PRODUCT ERROR]: $e");
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.contains('receive timeout') || errorMsg.contains('took longer than')) {
          errorMsg = 'Request timed out uploading images. Please check your network and try again.';
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
    bool isEdit = widget.product != null;
    final isLoading = context.watch<ProductProvider>().isLoading;

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
          isEdit ? 'Edit Product' : 'Add New Product',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Upload Area
            GestureDetector(
              onTap: _isSubmitting ? null : _pickImages,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.3)),
                ),
                child: _selectedImageFiles.isEmpty && (widget.product?.images.isEmpty ?? true)
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, color: AppColors.gold, size: 40),
                          SizedBox(height: 8),
                          Text('Upload Product Images', style: TextStyle(color: AppColors.grey)),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(12),
                              itemCount: _selectedImageFiles.length + (widget.product?.images.length ?? 0),
                              itemBuilder: (context, index) {
                                int existingCount = widget.product?.images.length ?? 0;
                                if (index < existingCount) {
                                  String url = widget.product!.images[index];
                                  final fullUrl = Product.formatImageUrl(url);
                                  return _buildImagePreview(
                                    Image.network(fullUrl, fit: BoxFit.contain),
                                    () {
                                      setState(() {
                                        widget.product!.images.removeAt(index);
                                      });
                                    },
                                  );
                                } else {
                                  int fileIndex = index - existingCount;
                                  return _buildImagePreview(
                                    Image.file(_selectedImageFiles[fileIndex], fit: BoxFit.contain),
                                    () => _removeImage(fileIndex),
                                  );
                                }
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text('Tap to add more', style: TextStyle(color: AppColors.gold, fontSize: 12)),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 30),
            
            _buildSectionLabel('Product Information'),
            _buildAdminTextField(_nameController, 'Product Name', Icons.shopping_bag_outlined),
            
            _buildSectionLabel('Category'),
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                List<String> displayCategories = [];
                if (categoryProvider.categories.isNotEmpty) {
                  displayCategories = categoryProvider.categories.map((c) => c.name).toList();
                } else {
                  displayCategories = ['Shirts', 'Pants', 'T-Shirts', 'Suits', 'Wedding Collection', 'Uniforms'];
                }

                if (_selectedCategory.isNotEmpty && !displayCategories.contains(_selectedCategory)) {
                  displayCategories.add(_selectedCategory);
                }

                if (!displayCategories.contains(_selectedCategory) && displayCategories.isNotEmpty) {
                  _selectedCategory = displayCategories.first;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      dropdownColor: AppColors.card,
                      style: const TextStyle(color: Colors.white),
                      items: displayCategories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: _isSubmitting ? null : (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                            // Automatically convert selected sizes when switching to/from Pant category
                            if (Product.isPantCategory(newValue)) {
                              _selectedSizes = _selectedSizes.map((s) => Product.mapPantSizeToNumeric(s)).toList();
                            } else {
                              _selectedSizes = _selectedSizes.map((s) => Product.mapNumericToPantLetter(s)).toList();
                            }
                          });
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            
            Row(
              children: [
                Expanded(child: _buildAdminTextField(_priceController, 'Price (₹)', Icons.currency_rupee, keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _buildAdminTextField(_stockController, 'Stock', Icons.inventory_2_outlined, keyboardType: TextInputType.number)),
              ],
            ),
            
            _buildAdminTextField(_descController, 'Description', Icons.description_outlined, maxLines: 4),

            // --- SIZE SELECTION ---
            _buildSectionLabel(_isPantCategory ? 'Select Pant Size (Waist in Inches)' : 'Select Size'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _standardSizes.map((size) {
                bool isSelected = _selectedSizes.contains(size);
                return _buildSelectableButton(
                  text: size,
                  isSelected: isSelected,
                  onTap: _isSubmitting ? () {} : () => _toggleSize(size),
                  width: 60,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                bool isShirtOrPantCategory = (_selectedCategory.toLowerCase().contains('shirt') && !_selectedCategory.toLowerCase().contains('t-shirt')) ||
                                             _selectedCategory.toLowerCase().contains('pant');

                return _buildSelectableButton(
                  text: isShirtOrPantCategory ? 'Custom Fit (Always On)' : 'Custom Fit',
                  isSelected: isShirtOrPantCategory || _selectedSizes.contains('Custom Fit') || _allowCustomFit,
                  onTap: _isSubmitting ? () {} : () {
                    if (isShirtOrPantCategory) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Custom Fit is always enabled for Shirts & Pants.')),
                      );
                    } else {
                      setState(() {
                        _allowCustomFit = !_allowCustomFit;
                        if (_allowCustomFit) {
                          if (!_selectedSizes.contains('Custom Fit')) _selectedSizes.add('Custom Fit');
                        } else {
                          _selectedSizes.remove('Custom Fit');
                        }
                      });
                    }
                  },
                  width: isShirtOrPantCategory ? 190 : 130,
                );
              },
            ),
            const SizedBox(height: 25),

            // --- FABRIC SELECTION (MULTI-SELECTABLE) ---
            _buildSectionLabel('Select Fabric'),
            const SizedBox(height: 10),
            Consumer<FabricProvider>(
              builder: (context, fabricProvider, child) {
                List<String> displayFabrics = fabricProvider.allFabrics.map((f) => f.name).toList();
                if (displayFabrics.isEmpty) {
                  displayFabrics = fabricProvider.activeFabrics.map((f) => f.name).toList();
                }
                for (var sel in _selectedFabrics) {
                  if (!displayFabrics.contains(sel)) {
                    displayFabrics.add(sel);
                  }
                }

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...displayFabrics.map((fabric) {
                      bool isSelected = _selectedFabrics.contains(fabric);
                      return _buildSelectableButton(
                        text: fabric,
                        isSelected: isSelected,
                        onTap: _isSubmitting ? () {} : () => _toggleFabricSelection(fabric),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      );
                    }),
                    GestureDetector(
                      onTap: _isSubmitting ? null : () => _showAddExtraFabricDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.gold, width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: AppColors.gold, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '+ Extra Fabric',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 25),

            _buildSectionLabel('Colors'),
            _buildAdminTextField(_colorsController, 'Available Colors (comma separated)', Icons.color_lens_outlined),
            
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Featured Product', style: TextStyle(color: Colors.white, fontSize: 14)),
              value: _isFeatured,
              activeThumbColor: AppColors.gold,
              onChanged: _isSubmitting ? null : (val) => setState(() => _isFeatured = val),
            ),
            const SizedBox(height: 32),
            
            (_isSubmitting || isLoading)
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : CustomButton(
                    text: isEdit ? 'UPDATE PRODUCT' : 'ADD PRODUCT',
                    onPressed: _isSubmitting ? () {} : _saveProduct,
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSelectableButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    double? width,
    EdgeInsets? padding,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.goldBorder.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(Widget image, VoidCallback onRemove) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: image,
          ),
        ),
        Positioned(
          top: 0,
          right: 12,
          child: GestureDetector(
            onTap: _isSubmitting ? null : onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
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
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
