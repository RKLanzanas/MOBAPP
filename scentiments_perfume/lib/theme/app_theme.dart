import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  /// Global flag toggled by [ThemeController]. All palette getters below read
  /// from it, so every screen automatically follows the selected theme.
  static bool isDark = false;

  // Primary & Accent Colors:
  // In Light mode: Deep Royal Midnight Blue (0xFF0F243E)
  // In Dark mode: Pure Black & White luxury palette (True Black 0xFF000000, 0xFFFFFFFF)
  static Color get darkBluePrimary =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0F243E);
  static Color get darkBlueSecondary =>
      isDark ? const Color(0xFF27272A) : const Color(0xFF1B3B6F);
  static Color get darkBlueAccent =>
      isDark ? const Color(0xFFE4E4E7) : const Color(0xFF28589B);
  static Color get darkBlueIcon =>
      isDark ? const Color(0xFFA1A1AA) : const Color(0xFF0F243E);

  /// Surface color (cards, app bars, dialogs). In dark mode: rich obsidian black surface.
  static Color get pureWhite =>
      isDark ? const Color(0xFF141414) : const Color(0xFFFFFFFF);
  /// Background color: pure pitch black in dark mode (0xFF000000), not dark blue.
  static Color get backgroundLight =>
      isDark ? const Color(0xFF000000) : const Color(0xFFF7F9FC);
  static Color get cardSurface =>
      isDark ? const Color(0xFF141414) : const Color(0xFFFFFFFF);
  static Color get softGrey =>
      isDark ? const Color(0xFF1F1F23) : const Color(0xFFF0F4F8);
  static Color get borderSubtle =>
      isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0);

  static Color get textDark =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0B192C);
  static Color get textMuted =>
      isDark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B);

  // Accent and status colors that stay consistent
  static const Color badgeRed = Color(0xFFEF4444);
  static const Color starGold = Color(0xFFF59E0B);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color gcashBlue = Color(0xFF007DFE);
  static const Color alwaysWhite = Color(0xFFFFFFFF);

  static ThemeData get lightTheme => _buildTheme(false);
  static ThemeData get darkTheme => _buildTheme(true);

  static ThemeData _buildTheme(bool dark) {
    final previous = isDark;
    isDark = dark;
    final theme = ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: dark ? const Color(0xFF000000) : const Color(0xFFF7F9FC),
      colorScheme: dark
          ? const ColorScheme.dark(
              primary: Color(0xFFFFFFFF),
              secondary: Color(0xFF27272A),
              surface: Color(0xFF141414),
              onPrimary: Color(0xFF000000),
              onSecondary: Color(0xFFFFFFFF),
              onSurface: Color(0xFFFFFFFF),
            )
          : const ColorScheme.light(
              primary: Color(0xFF0F243E),
              secondary: Color(0xFF1B3B6F),
              surface: Color(0xFFFFFFFF),
              onPrimary: Color(0xFFFFFFFF),
              onSecondary: Color(0xFFFFFFFF),
              onSurface: Color(0xFF0B192C),
            ),
      fontFamily: 'sans-serif',
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF141414) : const Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          color: dark ? const Color(0xFFFFFFFF) : const Color(0xFF0F243E),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: dark ? const Color(0xFFFFFFFF) : const Color(0xFF0B192C),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      iconTheme: IconThemeData(
        color: dark ? const Color(0xFFA1A1AA) : const Color(0xFF0F243E),
        size: 22,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: dark ? const Color(0xFFFFFFFF) : const Color(0xFF0F243E),
          foregroundColor: dark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF141414) : const Color(0xFFFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: dark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: dark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: dark ? const Color(0xFF141414) : const Color(0xFFFFFFFF),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: dark ? const Color(0xFF141414) : const Color(0xFFFFFFFF),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? const Color(0xFF27272A) : const Color(0xFF0F243E),
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
    );
    isDark = previous;
    return theme;
  }

  /// Shared input decoration used by the forms (login, sign up, settings...).
  static InputDecoration inputDecoration({
    required String hint,
    IconData? icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: textMuted, fontSize: 13),
      prefixIcon: icon == null ? null : Icon(icon, color: darkBlueIcon, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: isDark ? const Color(0xFF18181B) : backgroundLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFFFFFFFF) : darkBluePrimary,
          width: 1.5,
        ),
      ),
    );
  }
}

/// Holds the selected theme mode (light / dark) for the whole app.
class ThemeController extends ChangeNotifier {
  bool get isDark => AppTheme.isDark;

  void setDark(bool value) {
    if (AppTheme.isDark == value) return;
    AppTheme.isDark = value;
    notifyListeners();
  }

  void toggle() => setDark(!AppTheme.isDark);
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController super.notifier,
    required super.child,
  });

  static ThemeController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeScope>()!.notifier!;
  }
}
