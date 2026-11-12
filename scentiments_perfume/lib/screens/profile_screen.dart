import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../state/auth_state.dart';
import '../state/chat_state.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/scentiments_logo.dart';
import 'chat/chat_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthStateScope.of(context);
    final shop = ShopStateScope.of(context);
    final chat = ChatStateScope.of(context);
    final themeController = ThemeScope.of(context);
    final user = auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Scentiments'),
        centerTitle: false,
        actions: [
          // Theme switch button
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
              themeController.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: AppTheme.darkBlueIcon,
            ),
            onPressed: themeController.toggle,
          ),
          // Chat shortcut button with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Chats',
                icon: Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.darkBlueIcon),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatListScreen()),
                ),
              ),
              if (chat.totalUnread > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.badgeRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${chat.totalUnread}',
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
          // Settings button
          IconButton(
            tooltip: 'Settings',
            icon: Icon(Icons.settings_outlined, color: AppTheme.darkBlueIcon),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        child: Column(
          children: [
            // User Header Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkBluePrimary.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppTheme.darkBluePrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user.initials,
                        style: TextStyle(
                          color: AppTheme.pureWhite,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user.gmail ?? '@${user.username}',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.workspace_premium_rounded,
                                size: 16, color: AppTheme.starGold),
                            const SizedBox(width: 4),
                            Text(
                              'Diamond Scent Tier',
                              style: TextStyle(
                                color: AppTheme.darkBluePrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_note_rounded, color: AppTheme.darkBlueAccent, size: 28),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quick Stats Row
            Row(
              children: [
                _buildStatPill(
                  label: 'In Cart',
                  value: '${shop.totalCartQuantity} items',
                  icon: Icons.shopping_basket_rounded,
                  color: AppTheme.darkBluePrimary,
                ),
                const SizedBox(width: 12),
                _buildStatPill(
                  label: 'Wishlist',
                  value: '${shop.wishlistIds.length} saved',
                  icon: Icons.favorite_rounded,
                  color: AppTheme.badgeRed,
                ),
                const SizedBox(width: 12),
                _buildStatPill(
                  label: 'Orders',
                  value: '${shop.orders.length} placed',
                  icon: Icons.receipt_long_rounded,
                  color: AppTheme.successGreen,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Core Profile Settings & Actions Card
            Container(
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profile Information',
                    subtitle: 'Update your name, username, phone & address',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ),
                  ),
                  Divider(height: 1, indent: 60, color: AppTheme.borderSubtle),
                  _buildMenuItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Chats & Customer Support',
                    subtitle: 'Talk with our fragrance specialists',
                    badge: chat.totalUnread > 0 ? '${chat.totalUnread} new' : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatListScreen()),
                    ),
                  ),
                  Divider(height: 1, indent: 60, color: AppTheme.borderSubtle),
                  _buildMenuItem(
                    icon: shop.paymentMethod.icon,
                    title: 'Payment Method',
                    subtitle: '${shop.paymentMethod.label} • ${shop.paymentDetails}',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                  Divider(height: 1, indent: 60, color: AppTheme.borderSubtle),
                  _buildMenuItem(
                    icon: themeController.isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    title: 'Theme: ${themeController.isDark ? 'Dark Mode' : 'Light Mode'}',
                    subtitle: 'Tap to switch theme mode',
                    trailing: Switch(
                      value: themeController.isDark,
                      activeThumbColor: AppTheme.darkBluePrimary,
                      onChanged: themeController.setDark,
                    ),
                    onTap: themeController.toggle,
                  ),
                  Divider(height: 1, indent: 60, color: AppTheme.borderSubtle),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings & Security',
                    subtitle: 'Password, Gmail connection & security questions',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Recent Orders Section
            if (shop.orders.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Orders',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...shop.orders.take(3).map((order) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.softGrey,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(order.paymentMethod.icon,
                            color: AppTheme.darkBlueIcon, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order.id}',
                              style: TextStyle(
                                color: AppTheme.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${order.itemCount} items • ${order.paymentMethod.label}',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            if (order.discount > 0)
                              Text(
                                'Discount saved: ₱${order.discount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppTheme.successGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '₱${order.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppTheme.darkBluePrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 14),
            ],

            // Scent Preferences Quick Card
            Container(
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.local_florist_outlined,
                    title: 'Favorite Scent Notes',
                    subtitle: 'Floral, Woody, Oriental, Fresh',
                    onTap: () {},
                  ),
                  Divider(height: 1, indent: 60, color: AppTheme.borderSubtle),
                  _buildMenuItem(
                    icon: Icons.card_giftcard_rounded,
                    title: 'VIP Reward Points',
                    subtitle: '2,450 Scent Points available',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.pureWhite,
                      title: const Text('Log out?'),
                      content: const Text(
                          'You will need to log in again to view your saved items and cart.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Log Out',
                              style: TextStyle(color: AppTheme.badgeRed)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    auth.logout();
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.badgeRed, width: 1.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.logout_rounded, color: AppTheme.badgeRed),
                label: const Text(
                  'Log Out',
                  style: TextStyle(color: AppTheme.badgeRed, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: ScentimentsLogo(height: 64),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'SCENTIMENTS PERFUME • HAUTE PARFUMERIE',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.softGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.darkBlueIcon, size: 20),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.badgeRed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: AppTheme.alwaysWhite,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textMuted,
            size: 20,
          ),
    );
  }
}
