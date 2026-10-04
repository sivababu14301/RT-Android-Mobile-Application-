import 'package:flutter/material.dart';

class OrderStatusChip extends StatelessWidget {
  final String status;

  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'order placed':
      case 'pending':
        color = Colors.amber;
        break;
      case 'order confirmed':
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'stitching':
        color = Colors.purpleAccent;
        break;
      case 'ready':
        color = Colors.cyan;
        break;
      case 'out for delivery':
        color = Colors.deepOrange;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
