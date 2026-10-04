import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import 'package:rt_raymaans_tailors/providers/product_provider.dart';
import 'package:rt_raymaans_tailors/providers/user_provider.dart';
import 'package:rt_raymaans_tailors/providers/wishlist_provider.dart';
import 'package:rt_raymaans_tailors/providers/fabric_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/product_card.dart';

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
  final List<String> _categories = [
    'All',
    'Shirts',
    'Pants',
    'T-Shirts',
    'Suits',
    'Wedding Collection',
    'Uniforms'
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
                      _buildFilterSection('Category', ['Shirt', 'Pant', 'T-Shirt', 'Suit'], _selectedFilterCategories, setSheetState),
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
            automaticallyImplyLeading: false,
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
                : const Text('Products', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
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
                        isSelected: _selectedCategory == _categories[index],
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
                const SizedBox(height: 12),
                // Responsive Product Grid
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                      : provider.products.isEmpty
                          ? const Center(child: Text('No products found', style: TextStyle(color: AppColors.grey)))
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final double screenWidth = constraints.maxWidth;
                                // Calculate dynamic card width and aspect ratio for any screen size
                                final double horizontalPadding = 32.0; // 16 left + 16 right
                                final double crossAxisSpacing = 16.0;
                                final double availableWidth = screenWidth - horizontalPadding - crossAxisSpacing;
                                final double cardWidth = availableWidth / 2;

                                // Details section takes ~68px, Image box scales with cardWidth * 1.25 (3:4 ratio)
                                final double detailsHeight = 68.0;
                                final double imageHeight = cardWidth * 1.25;
                                final double totalCardHeight = imageHeight + detailsHeight;
                                final double dynamicAspectRatio = (cardWidth / totalCardHeight).clamp(0.55, 0.75);

                                return GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                  physics: const BouncingScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: dynamicAspectRatio,
                                    crossAxisSpacing: crossAxisSpacing,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: provider.products.length,
                                  itemBuilder: (context, index) {
                                    return ProductCard(product: provider.products[index]);
                                  },
                                );
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
