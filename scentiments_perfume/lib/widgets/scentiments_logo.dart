import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScentimentsLogo extends StatelessWidget {
  final double height;
  final double? width;
  final BoxFit fit;
  final bool? isDarkMode;

  const ScentimentsLogo({
    super.key,
    this.height = 36,
    this.width,
    this.fit = BoxFit.contain,
    this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    // Register dependency on theme so it updates immediately when theme changes
    final themeController = ThemeScope.of(context);
    final dark = isDarkMode ?? themeController.isDark;

    return Image.asset(
      dark
          ? 'assets/images/scentiments_logo_white.png'
          : 'assets/images/scentiments_logo_dark.png',
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/scentiments_logo.png',
          height: height,
          width: width,
          fit: fit,
        );
      },
    );
  }
}
