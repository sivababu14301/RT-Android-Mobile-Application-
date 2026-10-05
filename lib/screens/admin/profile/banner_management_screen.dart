import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../widgets/admin_banner_card.dart';
import 'add_edit_banner_screen.dart';

class BannerManagementScreen extends StatefulWidget {
  const BannerManagementScreen({super.key});

  @override
  State<BannerManagementScreen> createState() => _BannerManagementScreenState();
}

class _BannerManagementScreenState extends State<BannerManagementScreen> {
  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Premium Formal Shirts',
      'description': 'Tailored to perfection for a sharp look.',
      'imageUrl': 'https://images.unsplash.com/photo-1620012253295-c15cc3e65df4?q=80&w=1000&auto=format&fit=crop',
      'isActive': true,
    },
    {
      'title': 'Premium T-Shirts',
      'description': 'Comfort meets premium craftsmanship.',
      'imageUrl': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=1000&auto=format&fit=crop',
      'isActive': true,
    },
    {
      'title': 'Traditional Wedding Collection',
      'description': 'Royal attire for your special day.',
      'imageUrl': 'https://images.unsplash.com/photo-1593032465175-481ac7f401a0?q=80&w=1000&auto=format&fit=crop',
      'isActive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Banner Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search banners...',
                  hintStyle: TextStyle(color: AppColors.grey),
                  prefixIcon: Icon(Icons.search, color: AppColors.gold, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return AdminBannerCard(
                  title: banner['title'],
                  description: banner['description'],
                  imageUrl: banner['imageUrl'],
                  isActive: banner['isActive'],
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditBannerScreen(banner: banner),
                      ),
                    );
                  },
                  onDelete: () {
                    setState(() => _banners.removeAt(index));
                  },
                  onToggle: (val) {
                    setState(() => _banners[index]['isActive'] = val);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'admin_profile_banner_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditBannerScreen()),
          );
        },
        backgroundColor: AppColors.gold,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'New Banner',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
