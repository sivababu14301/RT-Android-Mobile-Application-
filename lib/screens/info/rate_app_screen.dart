import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/app_rating_service.dart';
import '../../widgets/custom_button.dart';

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  int _rating = 5;
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>().user;
      if (user != null && user.fullName.isNotEmpty) {
        _nameController.text = user.fullName;
      }
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_rating < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating (1 to 5 stars).'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback comments.'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userProvider = context.read<UserProvider>();
      final user = userProvider.user;
      final token = user?.token;

      final service = AppRatingService();
      final result = await service.submitRating(
        rating: _rating,
        feedback: _feedbackController.text.trim(),
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : user?.fullName,
        email: user?.email,
        token: token,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Thank you for your feedback! It has been delivered to Raymaans Tailors.'),
              backgroundColor: AppColors.gold,
              duration: const Duration(seconds: 3),
            ),
          );
          _feedbackController.clear();
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) Navigator.pop(context);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Submission failed. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting rating: $e'), backgroundColor: AppColors.error),
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
          'Rate App',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.stars_rounded, size: 85, color: AppColors.gold),
            const SizedBox(height: 20),
            const Text(
              'Enjoying RT – Raymaans Tailors?',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your feedback helps us provide you with the finest custom tailoring experience. Feedback will be sent to raymaanstailors@gmail.com.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 32),

            // Interactive Star Rating Selector
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'TAP A STAR TO RATE',
                    style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starVal = index + 1;
                      return IconButton(
                        onPressed: _isSubmitting ? null : () => setState(() => _rating = starVal),
                        icon: Icon(
                          starVal <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: AppColors.gold,
                          size: 42,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$_rating / 5 Stars',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Customer Name Field
            TextField(
              controller: _nameController,
              enabled: !_isSubmitting,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Your Name (Optional)',
                labelStyle: const TextStyle(color: AppColors.grey),
                filled: true,
                fillColor: AppColors.card,
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.gold),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Feedback Comments Multiline TextField
            TextField(
              controller: _feedbackController,
              enabled: !_isSubmitting,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tell us what you love or how we can improve...',
                hintStyle: const TextStyle(color: AppColors.grey),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 32),

            _isSubmitting
                ? const CircularProgressIndicator(color: AppColors.gold)
                : CustomButton(
                    text: 'SUBMIT FEEDBACK',
                    onPressed: _handleSubmit,
                  ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
