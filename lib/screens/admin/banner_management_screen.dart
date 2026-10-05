import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/banner_provider.dart';
import '../../providers/admin/admin_provider.dart';
import '../../providers/user_provider.dart';
import 'add_edit_banner_screen.dart';

class BannerManagementScreen extends StatefulWidget {
  const BannerManagementScreen({super.key});

  @override
  State<BannerManagementScreen> createState() => _BannerManagementScreenState();
}

class _BannerManagementScreenState extends State<BannerManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BannerProvider>().fetchBanners();
    });
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
          'Banner Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<BannerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.banners.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          if (provider.banners.isEmpty) {
            return const Center(
              child: Text('No banners found', style: TextStyle(color: AppColors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.banners.length,
            itemBuilder: (context, index) {
              final banner = provider.banners[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        banner.fullImageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 120,
                          color: Colors.black26,
                          child: const Icon(Icons.error, color: AppColors.gold),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        banner.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Status: ${banner.isActive ? 'Active' : 'Inactive'}',
                        style: TextStyle(color: banner.isActive ? Colors.green : Colors.red, fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditBannerScreen(banner: banner),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                          ),
                          IconButton(
                            onPressed: () {
                              _showDeleteConfirmation(context, banner.id);
                            },
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: SafeArea(
        child: FloatingActionButton(
          heroTag: 'admin_add_banner_fab',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEditBannerScreen()),
            );
          },
          backgroundColor: AppColors.gold,
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Delete Banner?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this banner?', style: TextStyle(color: AppColors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final adminProvider = context.read<AdminProvider>();
              final userProvider = context.read<UserProvider>();
              final token = adminProvider.admin?.token ?? userProvider.user?.token;
              if (token != null) {
                await context.read<BannerProvider>().deleteBanner(id, token);
              }
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
