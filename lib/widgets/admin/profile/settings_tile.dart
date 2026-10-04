import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.goldBorder.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor ?? AppColors.gold, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, color: AppColors.grey, size: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }
}
