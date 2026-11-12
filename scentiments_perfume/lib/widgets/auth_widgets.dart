import 'package:flutter/material.dart';
import '../state/auth_state.dart';
import '../theme/app_theme.dart';

/// Labeled text form field used across the auth & settings forms.
class LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;

  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            maxLines: obscure ? 1 : maxLines,
            enabled: enabled,
            style: TextStyle(color: AppTheme.textDark, fontSize: 14),
            decoration: AppTheme.inputDecoration(hint: hint, icon: icon, suffix: suffix),
            validator: validator,
          ),
        ],
      ),
    );
  }
}

/// Password field with a show / hide toggle.
class PasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = 'Enter your password',
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: widget.label,
      controller: widget.controller,
      hint: widget.hint,
      icon: Icons.key_outlined,
      obscure: _obscure,
      validator: widget.validator,
      suffix: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppTheme.darkBlueIcon,
          size: 20,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}

/// White card container used by the auth & settings screens.
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
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
      child: child,
    );
  }
}

/// Primary full-width button.
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  const PrimaryButton({super.key, required this.label, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.darkBluePrimary,
          foregroundColor: AppTheme.pureWhite,
          elevation: 3,
          shadowColor: AppTheme.darkBluePrimary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppTheme.pureWhite, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: AppTheme.pureWhite,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Continue with Gmail" outlined button with a Google-style "G" mark.
class GmailButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const GmailButton({super.key, this.label = 'Continue with Gmail', required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppTheme.pureWhite,
          side: BorderSide(color: AppTheme.borderSubtle, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GoogleMark(),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleMark extends StatelessWidget {
  final double size;
  const GoogleMark({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFF4285F4), Color(0xFF34A853), Color(0xFFFBBC05), Color(0xFFEA4335)],
          stops: [0.0, 0.4, 0.7, 1.0],
        ).createShader(bounds),
        child: Text(
          'G',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.72,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

/// Simulated Google account picker. Returns `(gmail, fullName)` or null.
Future<(String, String)?> showGmailSignInSheet(
  BuildContext context, {
  String title = 'Sign in with Google',
  String subtitle = 'to continue to Scentiments',
  bool askName = true,
}) {
  return showModalBottomSheet<(String, String)>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _GmailSheet(title: title, subtitle: subtitle, askName: askName),
  );
}

class _GmailSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool askName;

  const _GmailSheet({required this.title, required this.subtitle, required this.askName});

  @override
  State<_GmailSheet> createState() => _GmailSheetState();
}

class _GmailSheetState extends State<_GmailSheet> {
  final _formKey = GlobalKey<FormState>();
  final _gmailController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _gmailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, (_gmailController.text.trim(), _nameController.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const GoogleMark(size: 40),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              LabeledField(
                label: 'Gmail address',
                controller: _gmailController,
                hint: 'yourname@gmail.com',
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => AuthState.isValidGmail(v ?? '')
                    ? null
                    : 'Please enter a valid @gmail.com address',
              ),
              if (widget.askName)
                LabeledField(
                  label: 'Full name (for new accounts)',
                  controller: _nameController,
                  hint: 'Optional',
                  icon: Icons.person_outline_rounded,
                ),
              const SizedBox(height: 6),
              PrimaryButton(label: 'Continue', onPressed: _submit),
              const SizedBox(height: 10),
              Text(
                'Demo mode: Google sign-in is simulated on this device.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simulated Gmail inbox dialog that shows the password reset code.
Future<void> showSimulatedResetEmail(BuildContext context, String gmail, String code) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.pureWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          const GoogleMark(size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Gmail • New message',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('To: $gmail', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            'Scentiments password reset',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Use this code to reset your password. It expires in 10 minutes.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.softGrey,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                code,
                style: TextStyle(
                  color: AppTheme.darkBluePrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Demo mode: e-mail delivery is simulated.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Got it', style: TextStyle(color: AppTheme.darkBluePrimary)),
        ),
      ],
    ),
  );
}

void showAppSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppTheme.badgeRed : AppTheme.darkBluePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: isError ? AppTheme.alwaysWhite : AppTheme.pureWhite,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isError ? AppTheme.alwaysWhite : AppTheme.pureWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
