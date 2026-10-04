import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../cart/cart_screen.dart';

class ReorderScreen extends StatefulWidget {
  const ReorderScreen({super.key});

  @override
  State<ReorderScreen> createState() => _ReorderScreenState();
}

class _ReorderScreenState extends State<ReorderScreen> {
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders();
    });
  }

  Future<void> _fetchOrders() async {
    final token = context.read<UserProvider>().user?.token;
    if (token != null) {
      await context.read<OrderProvider>().fetchMyOrders(token);
    }
  }

  void _reorderItem(OrderItem item) async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add items to cart'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isAddingToCart = true);

    // Construct Product model for CartProvider
    final product = Product(
      id: item.product,
      name: item.name,
      category: 'Shirt',
      description: item.name,
      fabric: 'Cotton',
      price: item.price,
      stock: 10,
      rating: 5.0,
      images: [item.image],
      sizes: item.size != null ? [item.size!] : ['M'],
      colors: item.color != null ? [item.color!] : ['Black'],
    );

    final success = await Provider.of<CartProvider>(context, listen: false).addToCart(
      product,
      token,
      quantity: item.quantity > 0 ? item.quantity : 1,
      size: item.size ?? 'M',
      color: item.color ?? 'Black',
    );

    if (mounted) {
      setState(() => _isAddingToCart = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} added to cart!'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'VIEW CART',
              textColor: Colors.black,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to reorder item into cart'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reorder Previous Products',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          // Extract unique order items from previous orders
          final List<OrderItem> previousItems = [];
          final Set<String> seenKeys = {};

          for (final order in orderProvider.orders) {
            for (final item in order.orderItems) {
              final key = '${item.product}_${item.size}_${item.color}';
              if (!seenKeys.contains(key)) {
                seenKeys.add(key);
                previousItems.add(item);
              }
            }
          }

          if (previousItems.isEmpty) {
            return RefreshIndicator(
              onRefresh: _fetchOrders,
              color: AppColors.gold,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.replay_outlined,
                            size: 80,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'No Reorder Items Available',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'You do not have any products in your previous order history to reorder.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('BACK TO PROFILE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _fetchOrders,
            color: AppColors.gold,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: previousItems.length,
              itemBuilder: (context, index) {
                final item = previousItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.black26,
                              child: const Icon(Icons.checkroom, color: AppColors.gold, size: 40),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (item.size != null || item.color != null) ...[
                              Text(
                                'Size: ${item.size ?? 'Std'}  |  Color: ${item.color ?? 'Std'}',
                                style: const TextStyle(color: AppColors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              '₹${item.price.toInt()}',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isAddingToCart ? null : () => _reorderItem(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: const Text('REORDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
