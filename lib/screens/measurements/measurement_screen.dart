import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/measurement_provider.dart';
import '../../providers/user_provider.dart';
import 'shirt_measurement_screen.dart';
import 'pant_measurement_screen.dart';

class MeasurementScreen extends StatefulWidget {
  const MeasurementScreen({super.key});

  @override
  State<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<UserProvider>().user?.token;
      if (token != null) {
        context.read<MeasurementProvider>().fetchMyMeasurements(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Measurements',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<MeasurementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select measurement type to manage',
                  style: TextStyle(color: AppColors.grey, fontSize: 16),
                ),
                const SizedBox(height: 30),
                _buildMeasurementCard(
                  context,
                  title: 'Shirt Measurements',
                  subtitle: provider.hasSavedShirtMeasurements ? 'View & Update' : 'Not Saved Yet',
                  icon: Icons.check_box_outline_blank,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShirtMeasurementScreen()),
                  ),
                ),
                const SizedBox(height: 20),
                _buildMeasurementCard(
                  context,
                  title: 'Pant Measurements',
                  subtitle: provider.hasSavedPantMeasurements ? 'View & Update' : 'Not Saved Yet',
                  icon: Icons.layers_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PantMeasurementScreen()),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMeasurementCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.gold, size: 30),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.grey, fontSize: 14),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: AppColors.gold, size: 16),
          ],
        ),
      ),
    );
  }
}
