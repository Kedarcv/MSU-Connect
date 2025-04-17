import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:msu_connect/core/theme/app_theme.dart';

class CachedProfileImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;

  const CachedProfileImage({
    super.key,
    this.imageUrl,
    this.radius = 50,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    size: radius,
                    color: AppTheme.msuMaroon,
                  ),
                )
              : Icon(
                  Icons.person,
                  size: radius,
                  color: AppTheme.msuMaroon,
                ),
        ),
      ),
    );
  }
}