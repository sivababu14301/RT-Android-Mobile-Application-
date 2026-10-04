import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/measurement_model.dart';

class AdminMeasurementViewScreen extends StatelessWidget {
  final UserModel customer;
  final List<MeasurementModel> measurements;

  const AdminMeasurementViewScreen({
    super.key, 
    required this.customer,
    required this.measurements,
  });

  @override
  Widget build(BuildContext context) {
    final shirtMeasurements = measurements.where((m) => m.type == 'shirt').toList();
    final pantMeasurements = measurements.where((m) => m.type == 'pant').toList();
    final tshirtMeasurements = measurements.where((m) => m.type == 'tshirt' || m.type == 't-shirt').toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gold),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            '${customer.fullName}\'s Measurements',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.grey,
            tabs: [
              Tab(text: 'SHIRT'),
              Tab(text: 'PANT'),
              Tab(text: 'T-SHIRT'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Printing measurements...')),
                );
              },
              icon: const Icon(Icons.print_outlined, color: AppColors.gold),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildMeasurementList(shirtMeasurements, 'shirt'),
            _buildMeasurementList(pantMeasurements, 'pant'),
            _buildMeasurementList(tshirtMeasurements, 'tshirt'),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementList(List<MeasurementModel> items, String type) {
    if (items.isEmpty) {
      return Center(child: Text('No $type measurements saved', style: const TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final m = items[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Recorded: ${m.createdAt != null ? m.createdAt.toString().substring(0, 10) : 'N/A'}',
              style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMeasurementCard(
              type == 'tshirt'
                ? [
                    _buildMeasurementRow('Chest', '${m.chest ?? 0}"'),
                    _buildMeasurementRow('Shoulder', '${m.shoulder ?? 0}"'),
                    _buildMeasurementRow('Sleeve Length', '${m.sleeveLength ?? 0}"'),
                    _buildMeasurementRow('T-Shirt Length', '${m.shirtLength ?? 0}"'),
                    _buildMeasurementRow('Neck', '${m.neck ?? 0}"'),
                  ]
                : type == 'shirt'
                    ? [
                        _buildMeasurementRow('Chest', '${m.chest ?? 0}"'),
                        _buildMeasurementRow('Waist', '${m.waist ?? 0}"'),
                        _buildMeasurementRow('Shoulder', '${m.shoulder ?? 0}"'),
                        _buildMeasurementRow('Sleeve Length', '${m.sleeveLength ?? 0}"'),
                        _buildMeasurementRow('Shirt Length', '${m.shirtLength ?? 0}"'),
                        _buildMeasurementRow('Neck', '${m.neck ?? 0}"'),
                      ]
                    : [
                        _buildMeasurementRow('Waist', '${m.pantWaist ?? 0}"'),
                        _buildMeasurementRow('Hip', '${m.hip ?? 0}"'),
                        _buildMeasurementRow('Thigh', '${m.thigh ?? 0}"'),
                        _buildMeasurementRow('Inseam', '${m.inseam ?? 0}"'),
                        _buildMeasurementRow('Pant Length', '${m.pantLength ?? 0}"'),
                      ]
            ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  Widget _buildMeasurementCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMeasurementRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 16)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
