import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/order_card.dart';

class MyOrdersScreen extends StatefulWidget {
  final String? filterStatus;
  final String? title;

  const MyOrdersScreen({super.key, this.filterStatus, this.title});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
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

  @override
  Widget build(BuildContext context) {
    final bool isFiltered = widget.filterStatus != null;
    final String screenTitle = widget.title ?? (isFiltered ? '${widget.filterStatus} Orders' : 'My Orders');

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
        title: Text(
          screenTitle,
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          final allOrders = orderProvider.orders;
          final orders = isFiltered
              ? allOrders
                  .where((o) => o.status.trim().toLowerCase() == widget.filterStatus!.trim().toLowerCase())
                  .toList()
              : allOrders;

          if (orders.isEmpty) {
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
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          isFiltered ? 'No ${widget.filterStatus} Orders' : 'No Orders Yet',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isFiltered
                              ? 'You do not have any ${widget.filterStatus!.toLowerCase()} orders at this time.'
                              : "You haven't placed any orders yet. Start shopping to place your first order.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
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
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'BACK TO PROFILE',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
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
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return OrderCard(order: orders[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
