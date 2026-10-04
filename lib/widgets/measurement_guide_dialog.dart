import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class MeasurementGuideInfo {
  final String title;
  final String keyName;
  final String instruction;
  final String tip;

  const MeasurementGuideInfo({
    required this.title,
    required this.keyName,
    required this.instruction,
    required this.tip,
  });
}

class MeasurementGuides {
  static const Map<String, MeasurementGuideInfo> guides = {
    // SHIRT
    'chest': MeasurementGuideInfo(
      title: 'Chest Measurement',
      keyName: 'chest',
      instruction: 'Measure horizontally around the fullest part of your chest, keeping the tape flat under your arms and across your back.',
      tip: 'Keep two fingers between the measuring tape and your body for a comfortable fit.',
    ),
    'shirt_waist': MeasurementGuideInfo(
      title: 'Waist Measurement (Shirt)',
      keyName: 'shirt_waist',
      instruction: 'Measure horizontally around the narrowest part of your waist or stomach where the shirt naturally sits.',
      tip: 'Stand relaxed and do not hold your breath in while taking this measurement.',
    ),
    'shoulder': MeasurementGuideInfo(
      title: 'Shoulder Measurement',
      keyName: 'shoulder',
      instruction: 'Measure across the back from the outer bone tip of one shoulder straight to the outer bone tip of the other.',
      tip: 'Follow the natural curve across the top of your shoulder blades.',
    ),
    'sleeve_length': MeasurementGuideInfo(
      title: 'Sleeve Length',
      keyName: 'sleeve_length',
      instruction: 'Measure from the top tip of your shoulder bone down along the outer arm to the wrist bone where the shirt cuff should rest.',
      tip: 'Bend your elbow slightly while taking the sleeve measurement.',
    ),
    'shirt_length': MeasurementGuideInfo(
      title: 'Shirt Length',
      keyName: 'shirt_length',
      instruction: 'Measure vertically from the base of the back collar seam straight down to the desired bottom hem of the shirt.',
      tip: 'For tucked shirts, add an extra 1-2 inches to length.',
    ),
    'neck': MeasurementGuideInfo(
      title: 'Neck / Collar Measurement',
      keyName: 'neck',
      instruction: 'Measure around the base of your neck where the shirt collar naturally rests.',
      tip: 'Keep one finger under the tape so the collar buttoning feels comfortable.',
    ),

    // PANT
    'pant_waist': MeasurementGuideInfo(
      title: 'Waist Measurement (Pant)',
      keyName: 'pant_waist',
      instruction: 'Measure around your natural waistline at the exact height where you wear your trousers or belt.',
      tip: 'Measure over underwear or light clothing, keeping the tape snug.',
    ),
    'hip': MeasurementGuideInfo(
      title: 'Hip Measurement',
      keyName: 'hip',
      instruction: 'Measure horizontally around the fullest part of your hips and rear/seat area.',
      tip: 'Ensure the tape stays parallel to the floor all the way around.',
    ),
    'thigh': MeasurementGuideInfo(
      title: 'Thigh Measurement',
      keyName: 'thigh',
      instruction: 'Measure horizontally around the fullest part of your upper thigh, just below the crotch seam.',
      tip: 'Take this measurement while standing upright with your legs slightly apart.',
    ),
    'inseam': MeasurementGuideInfo(
      title: 'Inseam Length',
      keyName: 'inseam',
      instruction: 'Measure along the inner leg seam from the bottom of the crotch straight down to the ankle or top of shoe.',
      tip: 'Stand straight and look ahead; have someone else measure down your inner leg.',
    ),
    'pant_length': MeasurementGuideInfo(
      title: 'Pant Length (Outseam)',
      keyName: 'pant_length',
      instruction: 'Measure along the outer side of the leg from the top of the waistband down to the desired bottom hem.',
      tip: 'Wear the shoes you intend to pair with the trousers for the best length accuracy.',
    ),
  };

  static void showGuide(BuildContext context, String guideKey) {
    final info = guides[guideKey] ?? MeasurementGuideInfo(
      title: '$guideKey Measurement',
      keyName: guideKey,
      instruction: 'Measure carefully using a flexible tailoring tape.',
      tip: 'Ensure the tape is flat and not twisted.',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF111111),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.gold, width: 2)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.straighten_rounded, color: AppColors.gold, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              info.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.gold, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Tailor Illustration Container
                Container(
                  height: 180,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.3)),
                  ),
                  child: CustomPaint(
                    painter: TailorGuidePainter(guideKey: info.keyName),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.gold, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.content_cut, color: AppColors.gold, size: 12),
                                const SizedBox(width: 6),
                                Text(
                                  info.title.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Instruction Section
                const Text(
                  'HOW TO MEASURE:',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Icon(Icons.check_circle_outline, color: AppColors.gold, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        info.instruction,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Pro Tip Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: AppColors.gold, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          info.tip,
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'GOT IT',
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Custom Painter for Tailoring Measurement Diagrams
class TailorGuidePainter extends CustomPainter {
  final String guideKey;

  TailorGuidePainter({required this.guideKey});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 10);

    final Paint bodyPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint linePaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final Paint dotPaint = Paint()
      ..color = AppColors.brightGold
      ..style = PaintingStyle.fill;

    // Draw silhouette background based on guideKey
    if (guideKey.contains('pant') || guideKey == 'hip' || guideKey == 'thigh' || guideKey == 'inseam') {
      // Lower body / Trousers Silhouette
      final Path legs = Path()
        ..moveTo(center.dx - 35, center.dy - 60) // Waist
        ..lineTo(center.dx + 35, center.dy - 60)
        ..lineTo(center.dx + 40, center.dy - 30) // Hips
        ..lineTo(center.dx + 30, center.dy + 50) // Ankle Right
        ..lineTo(center.dx + 5, center.dy + 50)
        ..lineTo(center.dx, center.dy - 10)      // Crotch
        ..lineTo(center.dx - 5, center.dy + 50)
        ..lineTo(center.dx - 30, center.dy + 50) // Ankle Left
        ..lineTo(center.dx - 40, center.dy - 30)
        ..close();
      canvas.drawPath(legs, bodyPaint);
    } else {
      // Torso / Shirt Silhouette
      final Path torso = Path()
        ..moveTo(center.dx - 15, center.dy - 65) // Neck
        ..lineTo(center.dx + 15, center.dy - 65)
        ..lineTo(center.dx + 50, center.dy - 45) // Shoulder Right
        ..lineTo(center.dx + 35, center.dy + 35) // Waist Right
        ..lineTo(center.dx - 35, center.dy + 35) // Waist Left
        ..lineTo(center.dx - 50, center.dy - 45) // Shoulder Left
        ..close();
      canvas.drawPath(torso, bodyPaint);

      // Arm outlines
      canvas.drawLine(Offset(center.dx - 50, center.dy - 45), Offset(center.dx - 65, center.dy + 20), bodyPaint);
      canvas.drawLine(Offset(center.dx + 50, center.dy - 45), Offset(center.dx + 65, center.dy + 20), bodyPaint);
    }

    // Draw specific measurement highlight line & dots
    switch (guideKey) {
      case 'chest':
        final y = center.dy - 20;
        canvas.drawLine(Offset(center.dx - 42, y), Offset(center.dx + 42, y), linePaint);
        canvas.drawCircle(Offset(center.dx - 42, y), 5, dotPaint);
        canvas.drawCircle(Offset(center.dx + 42, y), 5, dotPaint);
        break;

      case 'shirt_waist':
        final y = center.dy + 15;
        canvas.drawLine(Offset(center.dx - 35, y), Offset(center.dx + 35, y), linePaint);
        canvas.drawCircle(Offset(center.dx - 35, y), 5, dotPaint);
        canvas.drawCircle(Offset(center.dx + 35, y), 5, dotPaint);
        break;

      case 'shoulder':
        final y = center.dy - 45;
        canvas.drawLine(Offset(center.dx - 50, y), Offset(center.dx + 50, y), linePaint);
        canvas.drawCircle(Offset(center.dx - 50, y), 5, dotPaint);
        canvas.drawCircle(Offset(center.dx + 50, y), 5, dotPaint);
        break;

      case 'sleeve_length':
        canvas.drawLine(Offset(center.dx + 50, center.dy - 45), Offset(center.dx + 65, center.dy + 20), linePaint);
        canvas.drawCircle(Offset(center.dx + 50, center.dy - 45), 5, dotPaint);
        canvas.drawCircle(Offset(center.dx + 65, center.dy + 20), 5, dotPaint);
        break;

      case 'shirt_length':
        canvas.drawLine(Offset(center.dx, center.dy - 65), Offset(center.dx, center.dy + 35), linePaint);
        canvas.drawCircle(Offset(center.dx, center.dy - 65), 5, dotPaint);
        canvas.drawCircle(Offset(center.dx, center.dy + 35), 5, dotPaint);
        break;

      case 'neck':
        canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy - 62), width: 30, height: 14), linePaint);
        canvas.drawCircle(Offset(center.dx - 15, center.dy - 62), 4, dotPaint);
        canvas.drawCircle(Offset(center.dx + 15, center.dy - 62), 4, dotPaint);
        break;

      case 'pant_waist':
        final y = center.dy - 60;
        canvas.drawLine(Offset(center.dx - 35, y), Offset(center.dx + 35, y), linePaint);
        canvas.drawCircle(Offset(center.dx - 35, y), 5, dotPaint);
        canvas.drawCircle(Offset(center.dx + 35, y), 5, dotPaint);
        break;

      case 'hip':
        final y = center.dy - 30;
        canvas.drawLine(Offset(center.dx - 40, y), Offset(center.dx + 40, y), linePaint);
        canvas.drawCircle(Offset(center.dx - 40, y), 5, dotPaint);
        canvas.drawCircle(Offset(center.dx + 40, y), 5, dotPaint);
        break;

      case 'thigh':
        final y = center.dy;
        canvas.drawLine(Offset(center.dx + 5, y), Offset(center.dx + 32, y), linePaint);
        canvas.drawCircle(Offset(center.dx + 5, y), 5, dotPaint);
        canvas.drawCircle(Offset(center.dx + 32, y), 5, dotPaint);
        break;

      case 'inseam':
        canvas.drawLine(Offset(center.dx + 2, center.dy - 10), Offset(center.dx + 18, center.dy + 50), linePaint);
        canvas.drawCircle(Offset(center.dx + 2, center.dy - 10), 5, dotPaint);
        canvas.drawCircle(Offset(center.dx + 18, center.dy + 50), 5, dotPaint);
        break;

      case 'pant_length':
        canvas.drawLine(Offset(center.dx + 35, center.dy - 60), Offset(center.dx + 30, center.dy + 50), linePaint);
        canvas.drawCircle(Offset(center.dx + 35, center.dy - 60), 5, dotPaint);
        canvas.drawCircle(Offset(center.dx + 30, center.dy + 50), 5, dotPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant TailorGuidePainter oldDelegate) {
    return oldDelegate.guideKey != guideKey;
  }
}
