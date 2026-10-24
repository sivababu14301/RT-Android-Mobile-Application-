import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/product_model.dart';
import 'package:rt_raymaans_tailors/providers/product_provider.dart';
import 'package:rt_raymaans_tailors/providers/user_provider.dart';
import 'package:rt_raymaans_tailors/providers/wishlist_provider.dart';
import 'package:rt_raymaans_tailors/providers/fabric_provider.dart';
import '../../widgets/category_chip.dart';
import 'product_details_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialSearch;
  const ProductListScreen({super.key, this.initialCategory, this.initialSearch});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Pants',
    'Shirts',
    'T-Shirts',
    'Formal Shirts',
    'Jeans',
    'Trousers',
    'Blazers',
    'Suits',
    'Wedding Wear',
    'School Uniforms',
    'College Uniforms',
    'Casual Wear',
    'Traditional Wear',
    'Shorts',
    'Jackets',
    'Accessories',
  ];

  final List<String> _selectedFilterCategories = [];
  final List<String> _selectedFabrics = [];
  String? _selectedPriceRange;
  final List<String> _selectedSizes = [];
  final List<String> _selectedColors = [];
  String _currentSort = 'Newest';

  void _showFilterSheet() {
    final fabricProvider = context.read<FabricProvider>();
    final List<String> availableFabrics = fabricProvider.activeFabrics.map((f) => f.name).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filters',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                _selectedFilterCategories.clear();
                                _selectedFabrics.clear();
                                _selectedPriceRange = null;
                                _selectedSizes.clear();
                                _selectedColors.clear();
                              });
                            },
                            child: const Text('Reset All', style: TextStyle(color: AppColors.gold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildFilterSection('Category', ['Shirts', 'Pants', 'T-Shirts', 'Suits'], _selectedFilterCategories, setSheetState),
                      _buildFilterSection('Fabric', availableFabrics, _selectedFabrics, setSheetState),
                      const Text('Price', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        children: ['Under ₹500', '₹500 – ₹1000', '₹1000 – ₹2000', 'Above ₹2000'].map((price) {
                          bool isSelected = _selectedPriceRange == price;
                          return ChoiceChip(
                            label: Text(price, style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
                            selected: isSelected,
                            selectedColor: AppColors.gold,
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isSelected ? AppColors.gold : Colors.white24)),
                            onSelected: (selected) {
                              setSheetState(() {
                                _selectedPriceRange = selected ? price : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      _buildFilterSection('Size', ['S', 'M', 'L', 'XL', 'XXL', 'Custom Fit'], _selectedSizes, setSheetState),
                      _buildFilterSection('Color', ['Black', 'White', 'Blue', 'Red', 'Grey'], _selectedColors, setSheetState),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<ProductProvider>().applyFilters(
                              categories: _selectedFilterCategories,
                              fabrics: _selectedFabrics,
                              priceRange: _selectedPriceRange,
                              sizes: _selectedSizes,
                              colors: _selectedColors,
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('APPLY FILTERS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(String title, List<String> options, List<String> selectedList, StateSetter setSheetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          children: options.map((option) {
            bool isSelected = selectedList.contains(option);
            return FilterChip(
              label: Text(option, style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
              selected: isSelected,
              selectedColor: AppColors.gold,
              backgroundColor: Colors.transparent,
              checkmarkColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isSelected ? AppColors.gold : Colors.white24)),
              onSelected: (selected) {
                setSheetState(() {
                  if (selected) {
                    selectedList.add(option);
                  } else {
                    selectedList.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildSortOption('Price: Low to High', Icons.trending_down),
              _buildSortOption('Price: High to Low', Icons.trending_up),
              _buildSortOption('Newest', Icons.new_releases_outlined),
              _buildSortOption('Rating: High to Low', Icons.star_outline),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String title, IconData icon) {
    bool isSelected = _currentSort == title;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.gold : Colors.white70),
      title: Text(title, style: TextStyle(color: isSelected ? AppColors.gold : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.gold) : null,
      onTap: () {
        setState(() {
          _currentSort = title;
        });
        context.read<ProductProvider>().applySort(title);
        Navigator.pop(context);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
    
    if (widget.initialSearch != null) {
      _searchController.text = widget.initialSearch!;
      _isSearching = true;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      productProvider.setCategory(_selectedCategory);
      productProvider.fetchProducts(
        category: _selectedCategory,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );
      context.read<FabricProvider>().fetchActiveFabrics();
      final token = context.read<UserProvider>().user?.token;
      if (token != null) {
        context.read<WishlistProvider>().fetchWishlist(token);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedFilterCategories.clear();
      _selectedFabrics.clear();
      _selectedPriceRange = null;
      _selectedSizes.clear();
      _selectedColors.clear();
    });
    final productProvider = context.read<ProductProvider>();
    if (category == 'All') {
      productProvider.resetToAll();
    } else {
      productProvider.setCategory(category);
    }
  }

  void _performSearch(String query) {
    context.read<ProductProvider>().setSearchQuery(query);
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.gold.withValues(alpha: 0.12),
      child: const Center(
        child: Icon(Icons.checkroom_outlined, color: AppColors.gold, size: 36),
      ),
    );
  }

  Widget _buildProductThumbnail(Product product) {
    final String imgUrl = product.imageUrl;
    if (imgUrl.trim().isEmpty) {
      return _buildImagePlaceholder();
    }

    if (imgUrl.startsWith('data:image/')) {
      try {
        final base64Str = imgUrl.split(',').last.trim();
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
        );
      } catch (_) {
        return _buildImagePlaceholder();
      }
    }

    return Image.network(
      imgUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
    );
  }

  Widget _buildVerticalProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 110,
                height: 130,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _buildProductThumbnail(product),
                    ),
                    // Rating Badge
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.6), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: AppColors.gold, size: 12),
                            const SizedBox(width: 3),
                            Text(
                              '${product.rating}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Right: Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Consumer<WishlistProvider>(
                        builder: (context, wishlist, child) {
                          final bool isFav = wishlist.isFavorite(product.id);
                          return GestureDetector(
                            onTap: () async {
                              final token = context.read<UserProvider>().user?.token;
                              if (token != null) {
                                if (isFav) {
                                  await wishlist.removeFromWishlist(product.id, token);
                                } else {
                                  await wishlist.addToWishlist(product, token);
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please login to use wishlist')),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : AppColors.gold,
                                size: 22,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Price & Stock Tag
                  Row(
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        product.stock > 0 ? 'In Stock' : 'Out of Stock',
                        style: TextStyle(
                          color: product.stock > 0 ? Colors.green : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Available Sizes
                  if (product.displaySizes.isNotEmpty) ...[
                    Row(
                      children: [
                        const Text('Sizes: ', style: TextStyle(color: AppColors.grey, fontSize: 11)),
                        Expanded(
                          child: Text(
                            product.displaySizes.take(4).join(', '),
                            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsScreen(product: product),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black, size: 16),
                      label: const Text(
                        'ADD TO CART',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        _selectedCategory = provider.selectedCategory;
        if (provider.searchQuery != null && provider.searchQuery!.isNotEmpty) {
          _searchController.text = provider.searchQuery!;
          _isSearching = true;
        } else if (_isSearching && (provider.searchQuery == null || provider.searchQuery!.isEmpty)) {
          _searchController.clear();
          _isSearching = false;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.gold),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _performSearch,
                  )
                : Text(
                    _selectedCategory == 'All' ? 'Products' : _selectedCategory,
                    style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                  ),
            iconTheme: const IconThemeData(color: AppColors.gold),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_isSearching) {
                      _isSearching = false;
                      _searchController.clear();
                      _performSearch('');
                    } else {
                      _isSearching = true;
                    }
                  });
                },
                icon: Icon(_isSearching ? Icons.close : Icons.search, color: AppColors.gold),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Category Filter Horizontal Scroll
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return CategoryChip(
                        label: _categories[index],
                        isSelected: _selectedCategory.toLowerCase().trim() == _categories[index].toLowerCase().trim(),
                        onTap: () => _onCategorySelected(_categories[index]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                // Filter & Sort Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showFilterSheet,
                          icon: const Icon(Icons.tune, size: 18, color: Colors.white70),
                          label: const Text('Filter', style: TextStyle(color: Colors.white, fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showSortSheet,
                          icon: const Icon(Icons.swap_vert, size: 18, color: Colors.white70),
                          label: const Text('Sort', style: TextStyle(color: Colors.white, fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Full-width Vertical Scrolling Product List
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                      : provider.products.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold.withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.inventory_2_outlined,
                                        size: 64,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'No products available in $_selectedCategory',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Explore our other custom tailored collections.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: AppColors.grey, fontSize: 13),
                                    ),
                                    const SizedBox(height: 28),
                                    ElevatedButton(
                                      onPressed: () {
                                        context.read<ProductProvider>().resetToAll();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.gold,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text(
                                        'EXPLORE ALL PRODUCTS',
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              physics: const BouncingScrollPhysics(),
                              itemCount: provider.products.length,
                              itemBuilder: (context, index) {
                                return _buildVerticalProductCard(context, provider.products[index]);
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
