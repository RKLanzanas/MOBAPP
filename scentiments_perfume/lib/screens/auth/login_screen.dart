import 'package:flutter/material.dart';
import '../../state/auth_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/scentiments_logo.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    final error = AuthStateScope.of(context)
        .login(_identifierController.text, _passwordController.text);
    if (error != null) {
      showAppSnackBar(context, error, isError: true);
    }
  }

  Future<void> _loginWithGmail() async {
    final auth = AuthStateScope.of(context);
    final result = await showGmailSignInSheet(context);
    if (result == null || !mounted) return;
    final error = auth.signInWithGmail(result.$1, fullName: result.$2);
    if (error != null && mounted) showAppSnackBar(context, error, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeScope.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Toggle dark / light theme',
                  icon: Icon(
                    themeController.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: AppTheme.darkBlueIcon,
                  ),
                  onPressed: themeController.toggle,
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: ScentimentsLogo(height: 100),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Welcome back! Log in to continue shopping.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ),
              const SizedBox(height: 28),
              SectionCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log In',
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LabeledField(
                        label: 'Username or Gmail',
                        controller: _identifierController,
                        hint: 'Enter your username or Gmail',
                        icon: Icons.person_outline_rounded,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter your username or Gmail'
                            : null,
                      ),
                      PasswordField(
                        label: 'Password',
                        controller: _passwordController,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Please enter your password' : null,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          ),
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: AppTheme.darkBlueAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      PrimaryButton(label: 'Log In', icon: Icons.login_rounded, onPressed: _login),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppTheme.borderSubtle)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                            ),
                          ),
                          Expanded(child: Divider(color: AppTheme.borderSubtle)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      GmailButton(onPressed: _loginWithGmail),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppTheme.darkBlueAccent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.softGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Demo accounts:\n'
                  '• scentvip / scent123 (connected to member.scentiments@gmail.com)\n'
                  '• juandelacruz / password123 (username & password only)',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
