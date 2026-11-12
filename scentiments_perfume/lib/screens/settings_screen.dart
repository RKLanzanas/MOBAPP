import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../models/user_account.dart';
import '../state/auth_state.dart';
import '../state/shop_state.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_widgets.dart';
import 'chat/chat_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthStateScope.of(context);
    final shop = ShopStateScope.of(context);
    final themeController = ThemeScope.of(context);
    final user = auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        children: [
          // Profile summary
          SectionCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.darkBluePrimary,
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      color: AppTheme.pureWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '@${user.username}',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  ),
                  icon: Icon(Icons.edit_rounded, size: 16, color: AppTheme.darkBlueAccent),
                  label: Text(
                    'Edit',
                    style: TextStyle(color: AppTheme.darkBlueAccent, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          _sectionLabel('Account'),
          _group([
            _tile(
              icon: Icons.person_outline_rounded,
              title: 'Edit Profile Info',
              subtitle: 'Name, username, phone & address',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
            ),
            _tile(
              icon: Icons.key_outlined,
              title: user.hasPassword ? 'Change Password' : 'Set a Password',
              subtitle: user.hasPassword
                  ? 'Update your log in password'
                  : 'Log in with your username too, not just Gmail',
              onTap: () => _showChangePassword(context, user),
            ),
            _tile(
              leading: const GoogleMark(size: 22),
              title: user.isGmailConnected ? 'Gmail Connected' : 'Connect Gmail',
              subtitle: user.isGmailConnected
                  ? '${user.gmail} • tap to disconnect'
                  : 'Log in with Gmail & recover your password',
              onTap: () => _toggleGmail(context, auth, user),
            ),
            _tile(
              icon: Icons.help_outline_rounded,
              title: 'Security Question',
              subtitle: user.hasSecurityQuestion
                  ? user.securityQuestion
                  : 'Not set — needed to reset a username-only account',
              onTap: () => _showSecurityQuestion(context, auth, user),
            ),
          ]),

          _sectionLabel('Appearance'),
          _group([
            SwitchListTile(
              value: themeController.isDark,
              activeThumbColor: AppTheme.darkBluePrimary,
              onChanged: themeController.setDark,
              secondary: _iconBox(
                themeController.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              ),
              title: _titleText('Dark Mode'),
              subtitle: _subtitleText(themeController.isDark ? 'Dark theme on' : 'Light theme on'),
            ),
          ]),

          _sectionLabel('Payment'),
          _group([
            for (final method in PaymentMethod.values)
              RadioListTile<PaymentMethod>(
                value: method,
                // ignore: deprecated_member_use
                groupValue: shop.paymentMethod,
                activeColor: AppTheme.darkBluePrimary,
                // ignore: deprecated_member_use
                onChanged: (m) => shop.setPaymentMethod(m!),
                secondary: _iconBox(method.icon),
                title: _titleText(method.label),
                subtitle: _subtitleText(method.description),
              ),
          ]),

          _sectionLabel('Support'),
          _group([
            _tile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Chats',
              subtitle: 'Message Scentiments customer support',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatListScreen()),
              ),
            ),
          ]),

          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, auth),
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
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(6, 22, 6, 8),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      );

  Widget _group(List<Widget> children) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) items.add(const Divider(height: 1, indent: 64));
    }
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(color: Colors.transparent, child: Column(children: items)),
    );
  }

  Widget _iconBox(IconData icon) => Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: AppTheme.softGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.darkBlueIcon, size: 20),
      );

  Widget _titleText(String text) => Text(
        text,
        style: TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w700),
      );

  Widget _subtitleText(String text) =>
      Text(text, style: TextStyle(color: AppTheme.textMuted, fontSize: 12));

  Widget _tile({
    IconData? icon,
    Widget? leading,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: leading == null
          ? _iconBox(icon!)
          : Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppTheme.softGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: leading,
            ),
      title: _titleText(title),
      subtitle: _subtitleText(subtitle),
      trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _toggleGmail(BuildContext context, AuthState auth, UserAccount user) async {
    if (user.isGmailConnected) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Disconnect Gmail?'),
          content: Text('You will no longer be able to log in with ${user.gmail}.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Disconnect', style: TextStyle(color: AppTheme.badgeRed)),
            ),
          ],
        ),
      );
      if (confirm != true || !context.mounted) return;
      final error = auth.disconnectGmail();
      showAppSnackBar(context, error ?? 'Gmail disconnected.', isError: error != null);
      return;
    }

    final result = await showGmailSignInSheet(
      context,
      title: 'Connect your Gmail',
      subtitle: 'to your Scentiments account',
      askName: false,
    );
    if (result == null || !context.mounted) return;
    final error = auth.connectGmail(result.$1);
    showAppSnackBar(context, error ?? 'Gmail connected!', isError: error != null);
  }

  Future<void> _showChangePassword(BuildContext context, UserAccount user) async {
    final auth = AuthStateScope.of(context);
    final formKey = GlobalKey<FormState>();
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BottomForm(
        title: user.hasPassword ? 'Change Password' : 'Set a Password',
        formKey: formKey,
        submitLabel: 'Save Password',
        onSubmit: () {
          if (!formKey.currentState!.validate()) return;
          final error = auth.changePassword(
            currentPassword: current.text,
            newPassword: next.text,
          );
          if (error != null) {
            showAppSnackBar(ctx, error, isError: true);
            return;
          }
          Navigator.pop(ctx, true);
        },
        children: [
          if (user.hasPassword)
            PasswordField(
              label: 'Current Password',
              controller: current,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
          PasswordField(
            label: 'New Password',
            controller: next,
            hint: 'At least 6 characters',
            validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
          ),
          PasswordField(
            label: 'Confirm New Password',
            controller: confirm,
            hint: 'Re-enter new password',
            validator: (v) => v != next.text ? 'Passwords do not match' : null,
          ),
        ],
      ),
    );
    if (saved == true && context.mounted) showAppSnackBar(context, 'Password updated!');
  }

  Future<void> _showSecurityQuestion(
      BuildContext context, AuthState auth, UserAccount user) async {
    final formKey = GlobalKey<FormState>();
    final answer = TextEditingController();
    var question =
        user.hasSecurityQuestion ? user.securityQuestion : securityQuestions.first;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => _BottomForm(
          title: 'Security Question',
          formKey: formKey,
          submitLabel: 'Save',
          onSubmit: () {
            if (!formKey.currentState!.validate()) return;
            auth.updateSecurityQuestion(question, answer.text);
            Navigator.pop(ctx, true);
          },
          children: [
            DropdownButtonFormField<String>(
              initialValue: question,
              isExpanded: true,
              dropdownColor: AppTheme.pureWhite,
              style: TextStyle(color: AppTheme.textDark, fontSize: 13),
              decoration: AppTheme.inputDecoration(
                hint: 'Choose a question',
                icon: Icons.help_outline_rounded,
              ),
              items: securityQuestions
                  .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                  .toList(),
              onChanged: (v) => setSheetState(() => question = v ?? question),
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: 'Answer',
              controller: answer,
              hint: 'Your answer',
              icon: Icons.question_answer_outlined,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
    if (saved == true && context.mounted) showAppSnackBar(context, 'Security question saved!');
  }

  Future<void> _confirmLogout(BuildContext context, AuthState auth) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to log in again to continue shopping.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out', style: TextStyle(color: AppTheme.badgeRed)),
          ),
        ],
      ),
    );
    if (confirm == true) auth.logout();
  }
}

/// Bottom sheet with a form, title and submit button.
class _BottomForm extends StatelessWidget {
  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final String submitLabel;
  final VoidCallback onSubmit;

  const _BottomForm({
    required this.title,
    required this.formKey,
    required this.children,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              ...children,
              const SizedBox(height: 6),
              PrimaryButton(label: submitLabel, onPressed: onSubmit),
            ],
          ),
        ),
      ),
    );
  }
}

/// Edit profile info: full name, username, phone and delivery address.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final user = AuthStateScope.of(context).currentUser!;
    _nameController = TextEditingController(text: user.fullName);
    _usernameController = TextEditingController(text: user.username);
    _phoneController = TextEditingController(text: user.phone);
    _addressController = TextEditingController(text: user.address);
    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final error = AuthStateScope.of(context).updateProfile(
      fullName: _nameController.text,
      username: _usernameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
    );
    if (error != null) {
      showAppSnackBar(context, error, isError: true);
      return;
    }
    showAppSnackBar(context, 'Profile updated!');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthStateScope.of(context).currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        child: Column(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: AppTheme.darkBluePrimary,
              child: Text(
                user.initials,
                style: TextStyle(
                  color: AppTheme.pureWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SectionCard(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    LabeledField(
                      label: 'Full Name',
                      controller: _nameController,
                      hint: 'Your full name',
                      icon: Icons.badge_outlined,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                    ),
                    LabeledField(
                      label: 'Username',
                      controller: _usernameController,
                      hint: 'Username',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => AuthState.isValidUsername(v ?? '')
                          ? null
                          : 'Use 4-20 letters, numbers, "_" or "."',
                    ),
                    LabeledField(
                      label: 'Gmail',
                      controller: TextEditingController(text: user.gmail ?? 'Not connected'),
                      hint: '',
                      icon: Icons.alternate_email_rounded,
                      enabled: false,
                    ),
                    LabeledField(
                      label: 'Mobile Number',
                      controller: _phoneController,
                      hint: '09XX XXX XXXX',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final digits = v.replaceAll(RegExp(r'\D'), '');
                        return RegExp(r'^09\d{9}$').hasMatch(digits)
                            ? null
                            : 'Enter a valid 11-digit PH number (09XXXXXXXXX)';
                      },
                    ),
                    LabeledField(
                      label: 'Delivery Address',
                      controller: _addressController,
                      hint: 'House no., street, barangay, city',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 6),
                    PrimaryButton(label: 'Save Changes', icon: Icons.save_rounded, onPressed: _save),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
