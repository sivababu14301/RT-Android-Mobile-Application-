import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback? onCameraTap;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.radius = 60,
    this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.gold,
            child: CircleAvatar(
              radius: radius - 3,
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
              child: imageUrl == null
                  ? Icon(Icons.person, size: radius, color: Colors.black)
                  : null,
            ),
          ),
          if (onCameraTap != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onCameraTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
