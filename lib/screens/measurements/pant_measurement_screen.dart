import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/measurement_model.dart';
import '../../providers/measurement_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/measurement_textfield.dart';
import '../../widgets/measurement_guide_dialog.dart';

class PantMeasurementScreen extends StatefulWidget {
  const PantMeasurementScreen({super.key});

  @override
  State<PantMeasurementScreen> createState() => _PantMeasurementScreenState();
}

class _PantMeasurementScreenState extends State<PantMeasurementScreen> {
  final _waistController = TextEditingController();
  final _hipController = TextEditingController();
  final _thighController = TextEditingController();
  final _inseamController = TextEditingController();
  final _lengthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  void _loadExisting() {
    final provider = context.read<MeasurementProvider>();
    final pant = provider.measurements.where((m) => m.type == 'pant').firstOrNull;
    if (pant != null) {
      _waistController.text = pant.pantWaist?.toString() ?? '';
      _hipController.text = pant.hip?.toString() ?? '';
      _thighController.text = pant.thigh?.toString() ?? '';
      _inseamController.text = pant.inseam?.toString() ?? '';
      _lengthController.text = pant.pantLength?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _waistController.dispose();
    _hipController.dispose();
    _thighController.dispose();
    _inseamController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null) return;

    final measurement = MeasurementModel(
      type: 'pant',
      pantWaist: double.tryParse(_waistController.text),
      hip: double.tryParse(_hipController.text),
      thigh: double.tryParse(_thighController.text),
      inseam: double.tryParse(_inseamController.text),
      pantLength: double.tryParse(_lengthController.text),
    );

    final success = await context.read<MeasurementProvider>().saveMeasurement(measurement, token);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pant Measurements Saved Successfully!'), backgroundColor: Colors.green),
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
        title: const Text('Pant Measurements', style: TextStyle(color: AppColors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            MeasurementTextField(
              label: 'Waist',
              hintText: 'Inches',
              controller: _waistController,
              onInfoTap: () => MeasurementGuides.showGuide(context, 'pant_waist'),
            ),
            MeasurementTextField(
              label: 'Hip',
              hintText: 'Inches',
              controller: _hipController,
              onInfoTap: () => MeasurementGuides.showGuide(context, 'hip'),
            ),
            MeasurementTextField(
              label: 'Thigh',
              hintText: 'Inches',
              controller: _thighController,
              onInfoTap: () => MeasurementGuides.showGuide(context, 'thigh'),
            ),
            MeasurementTextField(
              label: 'Inseam Length',
              hintText: 'Inches',
              controller: _inseamController,
              onInfoTap: () => MeasurementGuides.showGuide(context, 'inseam'),
            ),
            MeasurementTextField(
              label: 'Pant Length',
              hintText: 'Inches',
              controller: _lengthController,
              onInfoTap: () => MeasurementGuides.showGuide(context, 'pant_length'),
            ),
            const SizedBox(height: 20),
            isLoading
              ? const CircularProgressIndicator(color: AppColors.gold)
              : CustomButton(text: 'SAVE PANT MEASUREMENTS', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
