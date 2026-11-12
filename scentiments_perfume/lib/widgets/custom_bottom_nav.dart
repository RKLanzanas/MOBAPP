import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final int cartCount;
  final int wishlistCount;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.cartCount = 0,
    this.wishlistCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Explicitly listen to ThemeScope to guarantee instantaneous re-render on theme change
    final themeController = ThemeScope.of(context);
    final isDark = themeController.isDark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.6)
                : AppTheme.darkBluePrimary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: isDark
              ? const Color(0xFF27272A)
              : AppTheme.borderSubtle.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context: context,
            index: 0,
            icon: Icons.storefront_outlined,
            activeIcon: Icons.storefront_rounded,
            label: 'Home',
          ),
          _buildNavItem(
            context: context,
            index: 1,
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: 'Catalog',
          ),
          _buildCenterCartItem(
            context: context,
            index: 2,
            icon: Icons.shopping_basket_outlined,
            activeIcon: Icons.shopping_basket_rounded,
            badge: cartCount,
          ),
          _buildNavItem(
            context: context,
            index: 3,
            icon: Icons.favorite_border_rounded,
            activeIcon: Icons.favorite_rounded,
            label: 'Saved',
            badge: wishlistCount,
          ),
          _buildNavItem(
            context: context,
            index: 4,
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int badge = 0,
  }) {
    final bool isSelected = currentIndex == index;
    final bool isDark = AppTheme.isDark;

    final activeColor = isDark ? Colors.white : AppTheme.darkBluePrimary;
    final activeTextColor = isDark ? Colors.black : Colors.white;
    final inactiveIconColor = isDark ? const Color(0xFFA1A1AA) : AppTheme.darkBlueIcon;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? activeTextColor : inactiveIconColor,
                  size: 24,
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: activeTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
            if (badge > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.badgeRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    badge > 99 ? '99+' : '$badge',
                    style: const TextStyle(
                      color: AppTheme.alwaysWhite,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterCartItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    int badge = 0,
  }) {
    final bool isSelected = currentIndex == index;
    final bool isDark = AppTheme.isDark;

    final activeBg = isDark ? Colors.white : AppTheme.darkBluePrimary;
    final activeIconColor = isDark ? Colors.black : Colors.white;
    final inactiveBg = isDark ? const Color(0xFF222225) : AppTheme.softGrey;
    final inactiveIconColor = isDark ? const Color(0xFFA1A1AA) : AppTheme.darkBlueIcon;
    final borderColor = isSelected
        ? activeBg
        : (isDark ? const Color(0xFF2C2C30) : AppTheme.borderSubtle);

    return GestureDetector(
      onTap: () => onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? activeBg : inactiveBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? activeIconColor : inactiveIconColor,
              size: 22,
            ),
          ),
          if (badge > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : AppTheme.darkBluePrimary,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  '$badge',
                  style: TextStyle(
                    color: isDark ? Colors.black : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
