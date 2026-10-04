import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/measurement_model.dart';
import '../../providers/measurement_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/measurement_textfield.dart';
import '../../widgets/measurement_guide_dialog.dart';

class ShirtMeasurementScreen extends StatefulWidget {
  const ShirtMeasurementScreen({super.key});

  @override
  State<ShirtMeasurementScreen> createState() => _ShirtMeasurementScreenState();
}

class _ShirtMeasurementScreenState extends State<ShirtMeasurementScreen> {
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _shoulderController = TextEditingController();
  final _sleeveController = TextEditingController();
  final _lengthController = TextEditingController();
  final _neckController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  void _loadExisting() {
    final provider = context.read<MeasurementProvider>();
    final shirt = provider.measurements.where((m) => m.type == 'shirt').firstOrNull;
    if (shirt != null) {
      _chestController.text = shirt.chest?.toString() ?? '';
      _waistController.text = shirt.waist?.toString() ?? '';
      _shoulderController.text = shirt.shoulder?.toString() ?? '';
      _sleeveController.text = shirt.sleeveLength?.toString() ?? '';
      _lengthController.text = shirt.shirtLength?.toString() ?? '';
      _neckController.text = shirt.neck?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _chestController.dispose();
    _waistController.dispose();
    _shoulderController.dispose();
    _sleeveController.dispose();
    _lengthController.dispose();
    _neckController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null) return;

    final measurement = MeasurementModel(
      type: 'shirt',
      chest: double.tryParse(_chestController.text),
      waist: double.tryParse(_waistController.text),
      shoulder: double.tryParse(_shoulderController.text),
      sleeveLength: double.tryParse(_sleeveController.text),
      shirtLength: double.tryParse(_lengthController.text),
      neck: double.tryParse(_neckController.text),
    );

    final success = await context.read<MeasurementProvider>().saveMeasurement(measurement, token);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shirt Measurements Saved Successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        final error = context.read<MeasurementProvider>().error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Failed to save measurements'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<MeasurementProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Shirt Measurements', style: TextStyle(color: AppColors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            MeasurementTextField(
              label: 'Chest',
              hintText: 'Inches',
              controller: _chestController,
              onInfoTap: () => MeasurementGuides.showGuide(context, 'chest'),
            ),
            MeasurementTextField(
              label: 'Waist',
              hintText: 'Inches',
              controller: _waistController,
              onInfoTap: () => MeasurementGuides.showGuide(context, 'shirt_waist'),
            ),
            MeasurementTextField(
              label: 'Shoulder',
              hintText: 'Inches',
              controller: _shoulderController,
              onInfoTap: () => MeasurementGuides.showGuide(context, 'shoulder'),
            ),
            MeasurementTextField(
              label: 'Sleeve Length',
              hintText: 'Inches',
              controller: _sleeveController,
              onInfoTap: () => MeasurementGuides.showGuide(context, 'sleeve_length'),
            ),
            MeasurementTextField(
              label: 'Shirt Length',
              hintText: 'Inches',
              controller: _lengthController,
              onInfoTap: () => MeasurementGuides.showGuide(context, 'shirt_length'),
            ),
            MeasurementTextField(
              label: 'Neck',
              hintText: 'Inches',
              controller: _neckController,
              onInfoTap: () => MeasurementGuides.showGuide(context, 'neck'),
            ),
            const SizedBox(height: 20),
            isLoading 
              ? const CircularProgressIndicator(color: AppColors.gold)
              : CustomButton(text: 'SAVE SHIRT MEASUREMENTS', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
