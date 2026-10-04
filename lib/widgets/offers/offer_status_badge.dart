import 'package:flutter/material.dart';
import '../../models/offer_model.dart';

class OfferStatusBadge extends StatelessWidget {
  final OfferStatus status;

  const OfferStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case OfferStatus.active:
        color = Colors.green;
        text = 'Active';
        break;
      case OfferStatus.upcoming:
        color = Colors.amber;
        text = 'Upcoming';
        break;
      case OfferStatus.expired:
        color = Colors.red;
        text = 'Expired';
        break;
      case OfferStatus.inactive:
        color = Colors.grey;
        text = 'Disabled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
