import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _issueController = TextEditingController();

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_issueController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
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
          'Report an Issue',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Describe the issue you are facing',
              style: TextStyle(color: AppColors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hintText: 'Describe your problem...',
              prefixIcon: Icons.bug_report_outlined,
              controller: _issueController,
            ),
            const Spacer(),
            CustomButton(
              text: 'SUBMIT REPORT',
              onPressed: _submitReport,
            ),
          ],
        ),
      ),
    );
  }
}
