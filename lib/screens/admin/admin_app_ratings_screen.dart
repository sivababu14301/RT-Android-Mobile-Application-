import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/app_rating_service.dart';

class AdminAppRatingsScreen extends StatefulWidget {
  const AdminAppRatingsScreen({super.key});

  @override
  State<AdminAppRatingsScreen> createState() => _AdminAppRatingsScreenState();
}

class _AdminAppRatingsScreenState extends State<AdminAppRatingsScreen> {
  bool _isLoading = true;
  List<dynamic> _ratings = [];
  int _count = 0;
  double _avgRating = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchRatings();
  }

  Future<void> _fetchRatings() async {
    setState(() => _isLoading = true);
    final token = context.read<UserProvider>().user?.token;
    if (token != null) {
      final service = AppRatingService();
      final result = await service.getAppRatings(token);
      if (mounted) {
        setState(() {
          _ratings = result['ratings'] ?? [];
          _count = result['count'] ?? 0;
          _avgRating = (result['avgRating'] is num) ? (result['avgRating'] as num).toDouble() : 0.0;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
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
          'Customer App Ratings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : RefreshIndicator(
              onRefresh: _fetchRatings,
              color: AppColors.gold,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _avgRating.toStringAsFixed(1),
                                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: List.generate(5, (idx) {
                                  return Icon(
                                    idx < _avgRating.floor() ? Icons.star : Icons.star_border,
                                    color: AppColors.gold,
                                    size: 16,
                                  );
                                }),
                              ),
                              const SizedBox(height: 4),
                              Text('$_count total ratings', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.rate_review_outlined, color: AppColors.gold, size: 36),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Rating History',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),

                    if (_ratings.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Text(
                            'No customer app ratings submitted yet.',
                            style: TextStyle(color: AppColors.grey, fontSize: 15),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _ratings.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final item = _ratings[index];
                          final String name = item['name'] ?? 'Valued Customer';
                          final String email = item['email'] ?? '';
                          final int rating = (item['rating'] is num) ? (item['rating'] as num).toInt() : 5;
                          final String feedback = item['feedback'] ?? '';
                          final String dateStr = item['createdAt'] != null
                              ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(item['createdAt']))
                              : 'Recently';

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
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.gold,
                                      radius: 16,
                                      child: Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : 'C',
                                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                          if (email.isNotEmpty)
                                            Text(email, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(5, (rIdx) {
                                        return Icon(
                                          rIdx < rating ? Icons.star : Icons.star_border,
                                          color: AppColors.gold,
                                          size: 14,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  feedback,
                                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(dateStr, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
