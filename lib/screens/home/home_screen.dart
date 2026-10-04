import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../widgets/nav_drawer.dart';
import '../../widgets/home_banner.dart';
import '../../widgets/category_card.dart';
import '../../widgets/home/exclusive_offers.dart';
import '../../widgets/product_card.dart';
import '../cart/cart_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../notifications/notification_screen.dart';
import 'package:rt_raymaans_tailors/providers/customer_nav_provider.dart';
import 'package:rt_raymaans_tailors/providers/user_provider.dart';
import 'package:rt_raymaans_tailors/providers/category_provider.dart';
import 'package:rt_raymaans_tailors/providers/wishlist_provider.dart';
import 'package:rt_raymaans_tailors/providers/cart_provider.dart';
import 'package:rt_raymaans_tailors/providers/banner_provider.dart';
import 'package:rt_raymaans_tailors/providers/offer_provider.dart';
import 'package:rt_raymaans_tailors/providers/product_provider.dart';
import 'package:rt_raymaans_tailors/providers/notification_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _selectedCategories = [];
  final List<String> _selectedFabrics = [];
  String? _selectedPriceRange;
  final List<String> _selectedSizes = [];
  final List<String> _selectedColors = [];
  String _currentSort = 'Newest';

  void _showFilterSheet(BuildContext context) {
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
                                _selectedCategories.clear();
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
                      _buildFilterSection('Category', ['Shirt', 'Pant', 'T-Shirt', 'Suit'], _selectedCategories, setSheetState),
                      _buildFilterSection('Fabric', ['Cotton', 'Linen', 'Silk', 'Denim', 'Polyester'], _selectedFabrics, setSheetState),
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
                              categories: _selectedCategories,
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

  void _showSortSheet(BuildContext context) {
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
              _buildSortOption(context, 'Price: Low to High', Icons.trending_down),
              _buildSortOption(context, 'Price: High to Low', Icons.trending_up),
              _buildSortOption(context, 'Newest', Icons.new_releases_outlined),
              _buildSortOption(context, 'Rating: High to Low', Icons.star_outline),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(BuildContext context, String title, IconData icon) {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).clearSnackBars();
      context.read<CategoryProvider>().fetchCategories();
      context.read<ProductProvider>().fetchProducts();
      context.read<BannerProvider>().fetchBanners();
      context.read<OfferProvider>().fetchOffers();
      final token = context.read<UserProvider>().user?.token;
      if (token != null) {
        context.read<WishlistProvider>().fetchWishlist(token);
        context.read<CartProvider>().fetchCart(token);
        context.read<NotificationProvider>().fetchNotifications(token);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const NavDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.gold),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Consumer<UserProvider>(
          builder: (context, provider, child) {
            String userName = 'User';
            if (provider.user?.fullName != null && provider.user!.fullName.trim().isNotEmpty) {
              final nameParts = provider.user!.fullName.trim().split(' ');
              final firstName = nameParts[0].toLowerCase();
              userName = firstName.isNotEmpty 
                ? firstName[0].toUpperCase() + firstName.substring(1)
                : 'User';
            }
            return Text(
              'Hi, $userName',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
            icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.gold),
          ),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen())),
            icon: const Icon(Icons.favorite_border, color: AppColors.gold),
          ),
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return Stack(
                children: [
                  IconButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.gold),
                  ),
                  if (provider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${provider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. SEARCH BAR & FILTER SECTION
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back!',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Raymaans Tailors',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Dark Premium Search Bar
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white10),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search for shirts, pants...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: AppColors.gold),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          final productProvider = context.read<ProductProvider>();
                          productProvider.setSearchQuery(value.trim());
                          productProvider.fetchProducts(search: value.trim());
                          context.read<CustomerNavProvider>().setIndex(2);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Filter & Sort Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showFilterSheet(context),
                          icon: const Icon(Icons.tune, size: 18, color: Colors.white70),
                          label: const Text('Filter', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showSortSheet(context),
                          icon: const Icon(Icons.swap_vert, size: 18, color: Colors.white70),
                          label: const Text('Sort', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. BANNERS (Swipeable Banner Carousel with indicators)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: HomeBanner(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          // 3. CATEGORIES
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Categories', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      context.read<ProductProvider>().resetToAll();
                      context.read<CustomerNavProvider>().setIndex(2);
                    },
                    child: const Text('View All', style: TextStyle(color: AppColors.gold)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 105,
              child: Consumer<CategoryProvider>(
                builder: (context, provider, child) {
                  final categories = provider.categories.where((c) => c.isActive).toList();
                  
                  if (provider.isLoading && categories.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                  }

                  if (categories.isEmpty) {
                    return const Center(child: Text('No categories', style: TextStyle(color: AppColors.grey)));
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == categories.length) {
                        return _buildCategory(context, 'More', '⋯');
                      }
                      final cat = categories[index];
                      return _buildCategory(context, cat.name, '', imageUrl: cat.image);
                    },
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // 4. EXCLUSIVE OFFERS BANNER
          const SliverToBoxAdapter(child: ExclusiveOffers()),

          // 5. NEW ARRIVALS CATALOG
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New Arrivals',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<ProductProvider>().resetToAll();
                      context.read<CustomerNavProvider>().setIndex(2);
                    },
                    icon: const Icon(Icons.arrow_forward_ios, color: AppColors.gold, size: 18),
                  ),
                ],
              ),
            ),
          ),

          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              final products = provider.newArrivals;
              if (provider.isLoading && products.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
                );
              }
              if (products.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('No products found', style: TextStyle(color: AppColors.grey))),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ProductCard(product: products[index]),
                    childCount: min(products.length, 6),
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String title, String emoji, {String? imageUrl}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {
          if (title == 'More') {
            context.read<ProductProvider>().resetToAll();
            context.read<CustomerNavProvider>().setIndex(2);
          } else {
            final productProvider = context.read<ProductProvider>();
            productProvider.setCategory(title);
            context.read<CustomerNavProvider>().setIndex(2);
          }
        },
        child: CategoryCard(
          title: title,
          emoji: (imageUrl == null || imageUrl.isEmpty) && title != 'More' ? _getEmojiForCategory(title) : null,
          icon: title == 'More' ? Icons.more_horiz : null,
          imageUrl: imageUrl,
        ),
      ),
    );
  }

  String _getEmojiForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('shirt')) return '👔';
    if (n.contains('pant') || n.contains('paint')) return '👖';
    if (n.contains('t-shirt') || n.contains('tshirt')) return '👕';
    if (n.contains('suit')) return '🤵';
    if (n.contains('wedding')) return '👑';
    if (n.contains('uniform')) return '🎓';
    return '📂';
  }
}
