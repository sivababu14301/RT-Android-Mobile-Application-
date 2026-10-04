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
import '../../widgets/shimmer_loading.dart';
import '../cart/cart_screen.dart';
import '../measurements/measurement_screen.dart';
import '../measurements/shirt_measurement_screen.dart';
import '../measurements/pant_measurement_screen.dart';

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
  final List<File> _reviewImageFiles = [];
  bool _isSubmittingReview = false;
  
  bool _isDetailsLoading = true;
  
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
    if (widget.product.sizes.isNotEmpty) _selectedSize = widget.product.sizes[0];
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
          if (data['distribution'] != null && data['distribution'] is Map) {
            Map<String, dynamic> distMap = {};
            (data['distribution'] as Map).forEach((key, value) {
              distMap[key.toString()] = value;
            });
            _starDistribution = distMap;
          }
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

    final token = context.read<UserProvider>().user?.token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add items to cart'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (_selectedSize == null || _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select size and color'), backgroundColor: AppColors.error),
      );
      return;
    }

    final success = await Provider.of<CartProvider>(context, listen: false).addToCart(
      widget.product,
      token,
      quantity: _quantity,
      size: _selectedSize,
      color: _selectedColor,
    );

    if (success && mounted) {
      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.product.name} added to cart'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'VIEW CART',
              textColor: Colors.black,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            ),
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add item to cart'), backgroundColor: AppColors.error),
      );
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
      final ImagePicker picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          final availableSlots = 5 - _reviewImageFiles.length;
          final newFiles = pickedFiles
              .take(availableSlots)
              .map((xfile) => File(xfile.path))
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isDetailsLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductInfoSection(),
                        const SizedBox(height: 40),
                        _buildRatingsAndReviewsSection(),
                      ],
                    ),
                  ),
                ),
                ..._buildRelatedProductsSlivers(),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
      bottomNavigationBar: _isDetailsLoading ? null : _buildBottomActions(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 380.0,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black54,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gold, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<WishlistProvider>(
            builder: (context, wishlist, child) {
              final isFav = wishlist.isFavorite(widget.product.id);
              return CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : AppColors.gold,
                    size: 20,
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
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: widget.product.fullImageUrls.isNotEmpty
            ? ProductImageSlider(images: widget.product.fullImageUrls)
            : const Center(
                child: Icon(Icons.shopping_bag_outlined, color: AppColors.gold, size: 80),
              ),
      ),
    );
  }

  Widget _buildProductInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.product.name,
                style: const TextStyle(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              widget.product.formattedPrice,
              style: const TextStyle(color: AppColors.gold, fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: AppColors.gold, size: 20),
            const SizedBox(width: 6),
            Text(
              '${widget.product.rating} (${widget.product.reviewCount} Reviews)',
              style: const TextStyle(color: AppColors.grey, fontSize: 14),
            ),
            const Spacer(),
            Text(
              widget.product.stock <= 0
                  ? 'Out of Stock'
                  : widget.product.stock <= 3
                      ? 'Only ${widget.product.stock} left'
                      : 'In Stock',
              style: TextStyle(
                color: widget.product.stock <= 3 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        
        // Color Selection
        if (widget.product.colors.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text('Select Color', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildColorSelector(),
        ],
        
        // Size Selection
        const SizedBox(height: 32),
        const Text('Select Size', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildSizeSelector(),
        
        // Quantity
        const SizedBox(height: 32),
        _buildQuantityRow(),

        // Description
        const SizedBox(height: 32),
        const Text('Description', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(widget.product.description, style: const TextStyle(color: AppColors.grey, height: 1.6, fontSize: 15)),
        
        // Fabric Selection
        const SizedBox(height: 32),
        const Text('Select Fabric', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildFabricSelector(),
      ],
    );
  }

  Widget _buildColorSelector() {
    if (widget.product.colors.isEmpty) return const Text('No colors available', style: TextStyle(color: AppColors.grey));
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: widget.product.colors.map((color) {
        final isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.gold : AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? AppColors.gold : AppColors.borderColor),
            ),
            child: Text(color, style: TextStyle(color: isSelected ? Colors.black : AppColors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 55,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.product.sizes.length,
            itemBuilder: (context, index) {
              String size = widget.product.sizes[index];
              bool isSelected = _selectedSize == size;
              return GestureDetector(
                onTap: () => setState(() => _selectedSize = size),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.gold : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.gold : AppColors.borderColor),
                  ),
                  child: Center(child: Text(size, style: TextStyle(color: isSelected ? Colors.black : AppColors.white, fontWeight: FontWeight.bold))),
                ),
              );
            },
          ),
        ),
        if (widget.product.isCustomFitAvailable) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _toggleCustomFit,
            child: Container(
              height: 55, padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: _selectedSize == 'Custom Fit' ? AppColors.gold : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selectedSize == 'Custom Fit' ? AppColors.gold : AppColors.borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedSize == 'Custom Fit') const Padding(padding: EdgeInsets.only(right: 8.0), child: Icon(Icons.check, color: Colors.black, size: 20)),
                  Text('Custom Fit', style: TextStyle(color: _selectedSize == 'Custom Fit' ? Colors.black : AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFabricSelector() {
    final list = _productFabrics;
    if (list.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, index) {
          String fabric = list[index];
          bool isSelected = _selectedFabric == fabric;
          return GestureDetector(
            onTap: () => setState(() => _selectedFabric = fabric),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.gold : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.gold, width: 1.5),
              ),
              child: Center(child: Text(fabric, style: TextStyle(color: isSelected ? Colors.black : AppColors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuantityRow() {
    return Row(
      children: [
        const Text('Quantity', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const Spacer(),
        Container(
          height: 45,
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderColor)),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
                icon: const Icon(Icons.remove, color: AppColors.gold, size: 20),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(_quantity.toString(), style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                onPressed: () {
                  if (_quantity < widget.product.stock) {
                    setState(() => _quantity++);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Only ${widget.product.stock} items available in stock')),
                    );
                  }
                },
                icon: const Icon(Icons.add, color: AppColors.gold, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingsAndReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ratings & Reviews', style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        
        // Average Rating
        const Text('Average Rating', style: TextStyle(color: AppColors.grey, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(widget.product.rating.toString(), style: const TextStyle(color: AppColors.white, fontSize: 44, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: List.generate(5, (index) => Icon(index < widget.product.rating.floor() ? Icons.star : Icons.star_border, color: AppColors.gold, size: 20))),
                const SizedBox(height: 4),
                Text('⭐ ${widget.product.rating}/5', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Total Ratings: ${widget.product.reviewCount} Ratings', style: const TextStyle(color: AppColors.grey, fontSize: 14)),
        
        const SizedBox(height: 32),
        // Star Distribution
        _buildStarDistribution(),

        const SizedBox(height: 40),
        // Customer Reviews
        const Text('Customer Reviews', style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _isReviewsLoading 
            ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: AppColors.gold)))
            : _buildReviewList(),
        
        const SizedBox(height: 40),
        // Rate This Product
        _buildRateThisProductSection(),
      ],
    );
  }

  Widget _buildStarDistribution() {
    return Column(
      children: [5, 4, 3, 2, 1].map((star) {
        int count = _starDistribution[star.toString()] ?? 0;
        double percent = widget.product.reviewCount == 0 ? 0 : count / widget.product.reviewCount;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Row(
                  children: List.generate(5, (i) => Icon(Icons.star, size: 10, color: i < star ? AppColors.gold : Colors.white10)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text('$count', style: const TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewList() {
    if (_reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        width: double.infinity,
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(15)),
        child: const Center(child: Text('No reviews yet for this product', style: TextStyle(color: AppColors.grey))),
      );
    }

    return Column(
      children: _reviews.map((review) {
        final List reviewImages = (review['images'] != null && review['images'] is List) ? review['images'] : [];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card, 
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(review['name'] ?? 'Customer', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    review['createdAt'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(review['createdAt'])) : '', 
                    style: const TextStyle(color: AppColors.grey, fontSize: 12)
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(children: List.generate(5, (index) => Icon(index < (review['rating'] ?? 0) ? Icons.star : Icons.star_border, color: AppColors.gold, size: 16))),
              const SizedBox(height: 12),
              Text(review['comment'] ?? '', style: const TextStyle(color: AppColors.grey, height: 1.5, fontSize: 14)),
              
              if (reviewImages.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: reviewImages.length,
                    itemBuilder: (context, imgIndex) {
                      final rawUrl = reviewImages[imgIndex].toString();
                      final fullUrl = Product.formatImageUrl(rawUrl);
                      return GestureDetector(
                        onTap: () => _showFullImageDialog(context, fullUrl),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.3)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              fullUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.broken_image_outlined, color: AppColors.gold, size: 24),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRateThisProductSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rate This Product', style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _userRating = index + 1),
                    icon: Icon(
                      index < _userRating ? Icons.star : Icons.star_border, 
                      color: index < _userRating ? AppColors.gold : AppColors.grey, 
                      size: 40
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              const Text('Review:', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              TextField(
                controller: _reviewController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Write your review here...',
                  hintStyle: const TextStyle(color: AppColors.grey),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Add Photos (Optional):', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _pickReviewImages,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.gold, width: 1),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, color: AppColors.gold, size: 24),
                            SizedBox(height: 4),
                            Text('Add Photos', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ..._reviewImageFiles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final file = entry.value;
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(file, fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _reviewImageFiles.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isSubmittingReview
                    ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                    : ElevatedButton(
                        onPressed: _handleSubmitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold, 
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('SUBMIT REVIEW', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRelatedProductsSlivers() {
    if (_isRelatedLoading) {
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 40, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: Colors.white12, height: 60),
                Text('Related Products', style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Center(child: CircularProgressIndicator(color: AppColors.gold)),
              ],
            ),
          ),
        ),
      ];
    }

    if (_relatedProducts.isEmpty) {
      return [const SliverToBoxAdapter(child: SizedBox.shrink())];
    }

    return [
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: Colors.white12, height: 60),
              Text('Related Products', style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.70,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => ProductCard(product: _relatedProducts[index]),
            childCount: _relatedProducts.length,
          ),
        ),
      ),
    ];
  }

  Widget _buildBottomActions() {
    final bool isOutOfStock = widget.product.stock <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isOutOfStock
                  ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This product is Out of Stock')),
                      )
                  : () => _addToCart(showSnackBar: true),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: isOutOfStock ? AppColors.grey : AppColors.gold, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(
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
              onPressed: isOutOfStock
                  ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This product is Out of Stock')),
                      )
                  : () {
                      _addToCart(showSnackBar: false);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                    },
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
              : isShirt
                  ? 'Please add your Shirt measurements first to use Custom Fit.'
                  : 'Please add your measurements first to use Custom Fit.',
          style: const TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Widget targetScreen = const MeasurementScreen();
              if (isPant) targetScreen = const PantMeasurementScreen();
              else if (isShirt) targetScreen = const ShirtMeasurementScreen();

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
