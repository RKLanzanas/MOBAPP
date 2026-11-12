import 'package:flutter/material.dart';
import '../../models/user_account.dart';
import '../../state/auth_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_widgets.dart';

enum _ResetStep { findAccount, chooseMethod, verifyGmailCode, answerQuestion, newPassword, done }

/// Forgot password flow.
///  * Accounts connected to Gmail  -> a 6-digit code is sent to the Gmail.
///  * Username & password accounts -> answer the security question.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _codeController = TextEditingController();
  final _answerController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  _ResetStep _step = _ResetStep.findAccount;
  UserAccount? _account;

  @override
  void dispose() {
    _identifierController.dispose();
    _codeController.dispose();
    _answerController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _maskGmail(String gmail) {
    final parts = gmail.split('@');
    final name = parts.first;
    final visible = name.length <= 2 ? name : name.substring(0, 2);
    final stars = (name.length - visible.length).clamp(3, 8).toInt();
    return '$visible${'*' * stars}@${parts.last}';
  }

  void _findAccount() {
    if (!_formKey.currentState!.validate()) return;
    final account = AuthStateScope.of(context).findAccount(_identifierController.text);
    if (account == null) {
      showAppSnackBar(context, 'No account found with that username or Gmail.', isError: true);
      return;
    }
    setState(() {
      _account = account;
      if (account.isGmailConnected && account.hasSecurityQuestion) {
        _step = _ResetStep.chooseMethod;
      } else if (account.isGmailConnected) {
        _step = _ResetStep.verifyGmailCode;
      } else if (account.hasSecurityQuestion) {
        _step = _ResetStep.answerQuestion;
      } else {
        showAppSnackBar(context, 'This account has no recovery option set up.', isError: true);
      }
    });
    if (_step == _ResetStep.verifyGmailCode) _sendCode();
  }

  Future<void> _sendCode() async {
    final account = _account!;
    final code = AuthStateScope.of(context).sendResetCode(account);
    setState(() => _step = _ResetStep.verifyGmailCode);
    showAppSnackBar(context, 'Reset code sent to ${_maskGmail(account.gmail!)}');
    // Simulated e-mail delivery (no backend): show the e-mail the user received.
    await showSimulatedResetEmail(context, account.gmail!, code);
  }

  void _verifyCode() {
    if (!_formKey.currentState!.validate()) return;
    final error = AuthStateScope.of(context).verifyResetCode(_account!, _codeController.text);
    if (error != null) {
      showAppSnackBar(context, error, isError: true);
      return;
    }
    setState(() => _step = _ResetStep.newPassword);
  }

  void _verifyAnswer() {
    if (!_formKey.currentState!.validate()) return;
    final ok = AuthStateScope.of(context).verifySecurityAnswer(_account!, _answerController.text);
    if (!ok) {
      showAppSnackBar(context, 'Incorrect answer. Please try again.', isError: true);
      return;
    }
    setState(() => _step = _ResetStep.newPassword);
  }

  void _saveNewPassword() {
    if (!_formKey.currentState!.validate()) return;
    AuthStateScope.of(context).resetPassword(_account!, _passwordController.text);
    setState(() => _step = _ResetStep.done);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Forgot Password'), centerTitle: true),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: AppTheme.softGrey, shape: BoxShape.circle),
              child: Icon(
                _step == _ResetStep.done ? Icons.verified_rounded : Icons.lock_reset_rounded,
                size: 46,
                color: AppTheme.darkBluePrimary,
              ),
            ),
            const SizedBox(height: 20),
            SectionCard(
              child: Form(
                key: _formKey,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(key: ValueKey(_step), child: _buildStep()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: AppTheme.textDark, fontSize: 19, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4)),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _ResetStep.findAccount:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(
              'Find your account',
              'Enter the username or the Gmail connected to your account.',
            ),
            LabeledField(
              label: 'Username or Gmail',
              controller: _identifierController,
              hint: 'e.g. juandelacruz or name@gmail.com',
              icon: Icons.person_search_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter your username or Gmail' : null,
            ),
            PrimaryButton(label: 'Continue', onPressed: _findAccount),
          ],
        );

      case _ResetStep.chooseMethod:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title('Choose a recovery method', 'Hi ${_account!.fullName}, how do you want to verify?'),
            _methodTile(
              leading: const GoogleMark(size: 28),
              title: 'Send a code to my Gmail',
              subtitle: _maskGmail(_account!.gmail!),
              onTap: _sendCode,
            ),
            const SizedBox(height: 10),
            _methodTile(
              leading: Icon(Icons.help_outline_rounded, color: AppTheme.darkBlueIcon),
              title: 'Answer my security question',
              subtitle: 'For username & password accounts',
              onTap: () => setState(() => _step = _ResetStep.answerQuestion),
            ),
          ],
        );

      case _ResetStep.verifyGmailCode:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(
              'Check your Gmail',
              'We sent a 6-digit code to ${_maskGmail(_account!.gmail!)}.',
            ),
            LabeledField(
              label: 'Verification code',
              controller: _codeController,
              hint: '6-digit code',
              icon: Icons.pin_outlined,
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || v.trim().length != 6) ? 'Enter the 6-digit code' : null,
            ),
            PrimaryButton(label: 'Verify Code', onPressed: _verifyCode),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _sendCode,
                child: Text(
                  'Resend code',
                  style: TextStyle(color: AppTheme.darkBlueAccent, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        );

      case _ResetStep.answerQuestion:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title('Security question', _account!.securityQuestion),
            LabeledField(
              label: 'Your answer',
              controller: _answerController,
              hint: 'Answer (not case-sensitive)',
              icon: Icons.question_answer_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter your answer' : null,
            ),
            PrimaryButton(label: 'Verify Answer', onPressed: _verifyAnswer),
          ],
        );

      case _ResetStep.newPassword:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title('Create a new password', 'For account @${_account!.username}'),
            PasswordField(
              label: 'New Password',
              controller: _passwordController,
              hint: 'At least 6 characters',
              validator: (v) => (v == null || v.length < 6)
                  ? 'Password must be at least 6 characters'
                  : null,
            ),
            PasswordField(
              label: 'Confirm New Password',
              controller: _confirmController,
              hint: 'Re-enter new password',
              validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
            ),
            PrimaryButton(label: 'Save Password', icon: Icons.save_rounded, onPressed: _saveNewPassword),
          ],
        );

      case _ResetStep.done:
        return Column(
          children: [
            _title(
              'Password updated!',
              'You can now log in as @${_account!.username} with your new password.',
            ),
            PrimaryButton(
              label: 'Back to Log In',
              icon: Icons.login_rounded,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
    }
  }

  Widget _methodTile({
    required Widget leading,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(subtitle, style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
