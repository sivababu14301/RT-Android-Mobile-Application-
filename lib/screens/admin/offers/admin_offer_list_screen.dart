import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../providers/offer_provider.dart';
import '../../../providers/admin/admin_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../widgets/admin_offer_card.dart';
import 'admin_add_edit_offer_screen.dart';

class AdminOfferListScreen extends StatefulWidget {
  const AdminOfferListScreen({super.key});

  @override
  State<AdminOfferListScreen> createState() => _AdminOfferListScreenState();
}

class _AdminOfferListScreenState extends State<AdminOfferListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfferProvider>().fetchOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Exclusive Offers', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.gold), onPressed: () => Navigator.pop(context)),
      ),
      body: Consumer<OfferProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.allOffers.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          final offers = provider.allOffers.where((offer) {
            final matchesSearch = offer.offerName.toLowerCase().contains(_searchQuery.toLowerCase());
            if (_selectedFilter == 'All') return matchesSearch;
            return matchesSearch && offer.calculatedStatus.name.toLowerCase() == _selectedFilter.toLowerCase();
          }).toList();

          return Column(
            children: [
              _buildHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchOffers(),
                  color: AppColors.gold,
                  child: offers.isEmpty 
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: offers.length,
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          return AdminOfferCard(
                            offer: offer,
                            onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminAddEditOfferScreen(offer: offer))),
                            onDelete: () => _showDeleteConfirmation(context, offer.id),
                            onToggle: (val) {
                               final token = context.read<AdminProvider>().admin?.token ?? context.read<UserProvider>().user?.token;
                               if (token != null) {
                                 provider.toggleOfferStatus(offer.id, val, token);
                               }
                            },
                          );
                        },
                      ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: SafeArea(
        child: FloatingActionButton.extended(
          heroTag: 'admin_add_offer_fab',
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminAddEditOfferScreen())),
          backgroundColor: AppColors.gold,
          icon: const Icon(Icons.add, color: Colors.black),
          label: const Text('New Offer', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Delete Offer?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this offer?', style: TextStyle(color: AppColors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final token = context.read<AdminProvider>().admin?.token ?? context.read<UserProvider>().user?.token;
              if (token != null) {
                await context.read<OfferProvider>().deleteOffer(id, token);
              }
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(15)),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search offers...',
                hintStyle: TextStyle(color: AppColors.grey),
                prefixIcon: Icon(Icons.search, color: AppColors.gold),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Active', 'Upcoming', 'Expired', 'Inactive'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedFilter = filter),
              selectedColor: AppColors.gold,
              backgroundColor: AppColors.card,
              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.local_offer_outlined, size: 60, color: Colors.white10),
          SizedBox(height: 16),
          Text('No offers match your criteria', style: TextStyle(color: Colors.white24)),
        ],
      ),
    );
  }
}
