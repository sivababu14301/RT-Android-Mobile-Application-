import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/measurement_provider.dart';
import '../../services/product_service.dart';
import '../../widgets/product_image_slider.dart';
import '../../widgets/product_card.dart';
import '../auth/login_screen.dart';
import '../cart/cart_screen.dart';
import '../measurements/measurement_screen.dart';
import '../measurements/shirt_measurement_screen.dart';
import '../measurements/pant_measurement_screen.dart';
import '../payment/address_screen.dart';
import '../payment/payment_processing_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? _selectedSize;
  String? _selectedColor;
  String _selectedFabric = 'Cotton';
  int _quantity = 1;
  int _userRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  
  bool _isDetailsLoading = true;
  bool _isSubmittingReview = false;
  bool _isAddingToCart = false;
  final List<File> _reviewImageFiles = [];
  final ImagePicker _picker = ImagePicker();

  // Reviews data
  List<dynamic> _reviews = [];
  Map<String, dynamic> _starDistribution = {"1": 0, "2": 0, "3": 0, "4": 0, "5": 0};
  bool _isReviewsLoading = true;

  // Related products data
  List<Product> _relatedProducts = [];
  bool _isRelatedLoading = true;

  List<String> get _productFabrics {
    if (widget.product.fabrics.isNotEmpty) {
      return widget.product.fabrics;
    } else if (widget.product.fabric.isNotEmpty) {
      return widget.product.fabric.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    return ['Cotton'];
  }

  @override
  void initState() {
    super.initState();
    final List<String> sizes = widget.product.displaySizes;
    if (sizes.isNotEmpty) _selectedSize = sizes[0];
    if (widget.product.colors.isNotEmpty) _selectedColor = widget.product.colors[0];
    if (_productFabrics.isNotEmpty) _selectedFabric = _productFabrics[0];
    
    _loadAllData();
  }

  void _loadAllData() async {
    setState(() {
      _isDetailsLoading = true;
      _isReviewsLoading = true;
      _isRelatedLoading = true;
    });

    _fetchReviews();
    _fetchRelatedProducts();

    if (mounted) {
      setState(() => _isDetailsLoading = false);
    }
  }

  void _fetchReviews() async {
    try {
      final service = ProductService();
      final data = await service.getProductReviews(widget.product.id);
      if (mounted) {
        setState(() {
          _reviews = data['reviews'] ?? [];
          _starDistribution = data['starDistribution'] ?? _starDistribution;
          _isReviewsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      if (mounted) setState(() => _isReviewsLoading = false);
    }
  }

  void _fetchRelatedProducts() async {
    try {
      final service = ProductService();
      final products = await service.getProducts(category: widget.product.category, limit: 10);
      
      var filtered = products.where((p) => p.id != widget.product.id).toList();
      if (filtered.isEmpty) {
        final allProducts = await service.getProducts(limit: 100);
        filtered = allProducts
            .where((p) => p.id != widget.product.id)
            .where((p) => p.category.trim().toLowerCase() == widget.product.category.trim().toLowerCase())
            .toList();
      }

      if (mounted) {
        setState(() {
          _relatedProducts = filtered;
          _isRelatedLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching related: $e');
      if (mounted) setState(() => _isRelatedLoading = false);
    }
  }

  Future<void> _addToCart({bool showSnackBar = true}) async {
    if (_isAddingToCart) return;

    if (widget.product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This product is Out of Stock'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (_quantity > widget.product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only ${widget.product.stock} items available in stock'), backgroundColor: AppColors.error),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final token = userProvider.user?.token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add items to cart'), backgroundColor: AppColors.error),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    if (_selectedSize == null || _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select size and color'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isAddingToCart = true);

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final result = await cartProvider.addToCart(
        widget.product,
        token,
        quantity: _quantity,
        size: _selectedSize,
        color: _selectedColor,
      );

      if (mounted) {
        setState(() => _isAddingToCart = false);
        if (result['success'] == true) {
          if (showSnackBar) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? '${widget.product.name} added to cart'),
                backgroundColor: AppColors.success,
                action: SnackBarAction(
                  label: 'VIEW CART',
                  textColor: Colors.black,
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to add item to cart'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAddingToCart = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _buyNow() async {
    if (widget.product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This product is Out of Stock'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (_quantity > widget.product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only ${widget.product.stock} items available in stock'), backgroundColor: AppColors.error),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final token = userProvider.user?.token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to purchase items'), backgroundColor: AppColors.error),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    if (_selectedSize == null || _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select size and color'), backgroundColor: AppColors.error),
      );
      return;
    }

    // Direct Buy Now checkout flow
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final result = await cartProvider.addToCart(
      widget.product,
      token,
      quantity: _quantity,
      size: _selectedSize,
      color: _selectedColor,
    );

    if (mounted) {
      if (result['success'] == true) {
        final address = userProvider.user?.address;
        if (address == null || address.fullAddress.trim().isEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddressScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PaymentProcessingScreen(isCod: false)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Could not proceed to checkout'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _pickReviewImages() async {
    if (_reviewImageFiles.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed per review')),
      );
      return;
    }

    try {
      final List<XFile> picked = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (picked.isNotEmpty && mounted) {
        setState(() {
          final newFiles = picked
              .map((x) => File(x.path))
              .take(5 - _reviewImageFiles.length)
              .toList();
          _reviewImageFiles.addAll(newFiles);
        });
      }
    } catch (e) {
      debugPrint("❌ PICK REVIEW IMAGES ERROR: $e");
    }
  }

  void _handleSubmitReview() async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to rate'), backgroundColor: AppColors.error));
      return;
    }

    if (_userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a rating'), backgroundColor: AppColors.error));
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please write a comment'), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isSubmittingReview = true);

    try {
      final service = ProductService();
      List<String> uploadedImageUrls = [];

      if (_reviewImageFiles.isNotEmpty) {
        uploadedImageUrls = await service.uploadImages(_reviewImageFiles, token);
      }

      final result = await service.submitReview(
        widget.product.id, 
        _userRating, 
        _reviewController.text.trim(), 
        uploadedImageUrls,
        token
      );

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully!'), backgroundColor: AppColors.success)
          );
          _reviewController.clear();
          setState(() {
            _userRating = 0;
            _reviewImageFiles.clear();
            _isSubmittingReview = false;
          });
          _fetchReviews();
        } else {
          setState(() => _isSubmittingReview = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to submit review'), backgroundColor: AppColors.error)
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmittingReview = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error)
        );
      }
    }
  }

  void _showFullImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.gold,
                    size: 48,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = widget.product.stock <= 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.gold),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: widget.product.fullImageUrls.isNotEmpty
                  ? ProductImageSlider(images: widget.product.fullImageUrls)
                  : Container(
                      color: AppColors.card,
                      child: const Center(
                        child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 80),
                      ),
                    ),
            ),
            actions: [
              Consumer<WishlistProvider>(
                builder: (context, wishlist, child) {
                  final isFav = wishlist.isFavorite(widget.product.id);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : AppColors.gold,
                        ),
                        onPressed: () async {
                          final token = context.read<UserProvider>().user?.token;
                          if (token != null) {
                            if (isFav) {
                              await wishlist.removeFromWishlist(widget.product.id, token);
                            } else {
                              await wishlist.addToWishlist(widget.product, token);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please login to use wishlist')),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        widget.product.formattedPrice,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.gold, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.product.rating}',
                        style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${widget.product.reviewCount} Reviews)',
                        style: const TextStyle(color: AppColors.grey),
                      ),
                      const Spacer(),
                      Text(
                        isOutOfStock
                            ? 'Out of Stock'
                            : widget.product.stock <= 3
                                ? 'Only ${widget.product.stock} left!'
                                : 'In Stock (${widget.product.stock})',
                        style: TextStyle(
                          color: isOutOfStock
                              ? Colors.red
                              : widget.product.stock <= 3
                                  ? Colors.red
                                  : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),

                  _buildSizeSection(),
                  const SizedBox(height: 20),

                  if (widget.product.colors.isNotEmpty) ...[
                    _buildColorSection(),
                    const SizedBox(height: 20),
                  ],

                  if (_productFabrics.isNotEmpty) ...[
                    _buildFabricSection(),
                    const SizedBox(height: 20),
                  ],

                  _buildQuantitySection(),
                  const SizedBox(height: 24),

                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),

                  const Text(
                    'Description',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.product.description,
                    style: const TextStyle(color: AppColors.grey, height: 1.6, fontSize: 14),
                  ),

                  const SizedBox(height: 32),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),

                  _buildReviewsSection(),

                  const SizedBox(height: 32),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),

                  _buildRelatedProductsSection(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(isOutOfStock),
    );
  }

  Widget _buildSizeSection() {
    final List<String> sizes = widget.product.displaySizes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.product.isPantProduct
                  ? 'Select Pant Size (Waist in Inches)'
                  : 'Select Size',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.product.isCustomFitAvailable)
              TextButton.icon(
                onPressed: _toggleCustomFit,
                icon: Icon(
                  _selectedSize == 'Custom Fit' ? Icons.check_box : Icons.check_box_outline_blank,
                  color: AppColors.gold,
                  size: 18,
                ),
                label: const Text(
                  'Custom Fit',
                  style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: sizes.map((size) {
            final isSelected = _selectedSize == size;
            return ChoiceChip(
              label: Text(size),
              selected: isSelected,
              selectedColor: AppColors.gold,
              backgroundColor: AppColors.card,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? AppColors.gold : Colors.white10,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedSize = size);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Color',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.product.colors.map((color) {
            final isSelected = _selectedColor == color;
            return ChoiceChip(
              label: Text(color),
              selected: isSelected,
              selectedColor: AppColors.gold,
              backgroundColor: AppColors.card,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? AppColors.gold : Colors.white10,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedColor = color);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFabricSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Fabric',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _productFabrics.map((fabric) {
            final isSelected = _selectedFabric == fabric;
            return ChoiceChip(
              label: Text(fabric),
              selected: isSelected,
              selectedColor: AppColors.gold,
              backgroundColor: AppColors.card,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? AppColors.gold : Colors.white10,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFabric = fabric);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Row(
      children: [
        const Text(
          'Quantity',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: AppColors.gold, size: 18),
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              ),
              Text(
                '$_quantity',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.gold, size: 18),
                onPressed: _quantity < widget.product.stock
                    ? () => setState(() => _quantity++)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ratings & Reviews (${_reviews.length})',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isReviewsLoading)
          const Center(child: CircularProgressIndicator(color: AppColors.gold))
        else ...[
          _buildRatingSummary(),
          const SizedBox(height: 24),
          _buildAddReviewBox(),
          const SizedBox(height: 24),
          if (_reviews.isEmpty)
            const Text('No reviews yet. Be the first to rate this product!', style: TextStyle(color: AppColors.grey))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reviews.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 24),
              itemBuilder: (context, index) {
                final rev = _reviews[index];
                return _buildReviewItem(rev);
              },
            ),
        ],
      ],
    );
  }

  Widget _buildRatingSummary() {
    final double rating = widget.product.rating;
    final int total = widget.product.reviewCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.floor() ? Icons.star : Icons.star_border,
                    color: AppColors.gold,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text('$total ratings', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = _starDistribution[star.toString()] ?? 0;
                final pct = total > 0 ? count / total : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      Text('$star', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: Colors.white10,
                          color: AppColors.gold,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddReviewBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Write a Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              final star = index + 1;
              return IconButton(
                icon: Icon(
                  star <= _userRating ? Icons.star : Icons.star_border,
                  color: AppColors.gold,
                  size: 28,
                ),
                onPressed: () => setState(() => _userRating = star),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reviewController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Share your experience with this product...',
              hintStyle: const TextStyle(color: AppColors.grey),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          if (_reviewImageFiles.isNotEmpty) ...[
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _reviewImageFiles.length,
                itemBuilder: (context, index) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8, top: 8),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_reviewImageFiles[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _reviewImageFiles.removeAt(index)),
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _isSubmittingReview ? null : _pickReviewImages,
                icon: const Icon(Icons.add_a_photo_outlined, size: 18, color: AppColors.gold),
                label: Text('Add Photos (${_reviewImageFiles.length}/5)', style: const TextStyle(color: AppColors.gold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.gold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const Spacer(),
              _isSubmittingReview
                  ? const CircularProgressIndicator(color: AppColors.gold)
                  : ElevatedButton(
                      onPressed: _handleSubmitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('SUBMIT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(dynamic rev) {
    final String name = rev['userName'] ?? 'Customer';
    final int rating = rev['rating'] ?? 5;
    final String comment = rev['comment'] ?? '';
    final String dateStr = rev['createdAt'] != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(rev['createdAt']))
        : 'Recently';

    final List<dynamic> images = rev['images'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.gold,
              radius: 16,
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'C', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Row(
                  children: List.generate(5, (idx) {
                    return Icon(
                      idx < rating ? Icons.star : Icons.star_border,
                      color: AppColors.gold,
                      size: 14,
                    );
                  }),
                ),
              ],
            ),
            const Spacer(),
            Text(dateStr, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 10),
        Text(comment, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
        if (images.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, idx) {
                final imgUrl = images[idx];
                return GestureDetector(
                  onTap: () => _showFullImageDialog(context, imgUrl),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: AppColors.gold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRelatedProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'You Might Also Like',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_isRelatedLoading)
          const Center(child: CircularProgressIndicator(color: AppColors.gold))
        else if (_relatedProducts.isEmpty)
          const Text('No related products found.', style: TextStyle(color: AppColors.grey))
        else
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _relatedProducts.length,
              itemBuilder: (context, index) {
                final prod = _relatedProducts[index];
                return SizedBox(
                  width: 170,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ProductCard(product: prod),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar(bool isOutOfStock) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isOutOfStock || _isAddingToCart
                  ? null
                  : () => _addToCart(showSnackBar: true),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: isOutOfStock ? AppColors.grey : AppColors.gold, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: _isAddingToCart
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
                    )
                  : Text(
                      isOutOfStock ? 'OUT OF STOCK' : 'ADD TO CART',
                      style: TextStyle(
                        color: isOutOfStock ? AppColors.grey : AppColors.gold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: isOutOfStock || _isAddingToCart
                  ? null
                  : () => _buyNow(),
              style: ElevatedButton.styleFrom(
                backgroundColor: isOutOfStock ? AppColors.card : AppColors.gold,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(
                isOutOfStock ? 'OUT OF STOCK' : 'BUY NOW',
                style: TextStyle(
                  color: isOutOfStock ? AppColors.grey : Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleCustomFit() {
    final measurementProvider = Provider.of<MeasurementProvider>(context, listen: false);
    final cat = widget.product.category.toLowerCase().trim();
    final bool isPant = cat.contains('pant') || cat.contains('trouser');
    final bool isShirt = (cat.contains('shirt') && !cat.contains('t-shirt') && !cat.contains('tshirt')) || cat == 'shirts';

    bool hasMeasurements = false;
    if (isPant) {
      hasMeasurements = measurementProvider.hasSavedPantMeasurements;
    } else if (isShirt) {
      hasMeasurements = measurementProvider.hasSavedShirtMeasurements;
    } else {
      hasMeasurements = measurementProvider.hasSavedShirtMeasurements || measurementProvider.hasSavedPantMeasurements;
    }

    if (!hasMeasurements) {
      _showNoMeasurementsDialog(isPant: isPant, isShirt: isShirt);
      return;
    }

    setState(() {
      if (_selectedSize == 'Custom Fit') {
        _selectedSize = widget.product.sizes.isNotEmpty ? widget.product.sizes[0] : null;
      } else {
        _selectedSize = 'Custom Fit';
      }
    });
  }

  void _showNoMeasurementsDialog({bool isPant = false, bool isShirt = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('No Measurements Found', style: TextStyle(color: Colors.white)),
        content: Text(
          isPant
              ? 'Please add your Pant measurements first to use Custom Fit.'
              : (isShirt
                  ? 'Please add your Shirt measurements first to use Custom Fit.'
                  : 'Please add your measurements first to use Custom Fit.'),
          style: const TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Widget targetScreen = const MeasurementScreen();
              if (isPant) {
                targetScreen = const PantMeasurementScreen();
              } else if (isShirt) {
                targetScreen = const ShirtMeasurementScreen();
              }

              Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            child: const Text('ADD MEASUREMENTS', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
