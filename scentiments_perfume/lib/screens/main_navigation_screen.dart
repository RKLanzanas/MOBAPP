import 'package:flutter/material.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'shop_screen.dart';
import 'wishlist_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Explicitly register dependency on ThemeScope so navigation updates immediately
    ThemeScope.of(context);
    final shopState = ShopStateScope.of(context);

    final List<Widget> screens = [
      HomeScreen(onNavigateToTab: _onTabSelected),
      const ShopScreen(),
      CartScreen(onContinueShopping: () => _onTabSelected(1)),
      WishlistScreen(onExplore: () => _onTabSelected(1)),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
        cartCount: shopState.totalCartQuantity,
        wishlistCount: shopState.wishlistIds.length,
      ),
    );
  }
}
