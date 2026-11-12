import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BurgisImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const BurgisImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget img;
    if (imagePath.startsWith('assets/')) {
      img = Image.asset(
        imagePath,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      img = Image.network(
        imagePath,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: img);
    }
    return img;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.softGrey,
      child: Center(
        child: Icon(
          Icons.bubble_chart_rounded,
          color: AppTheme.darkBluePrimary,
          size: 28,
        ),
      ),
    );
  }
}
