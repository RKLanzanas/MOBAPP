import 'package:flutter/material.dart';
import '../../models/user_account.dart';
import '../../state/auth_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/scentiments_logo.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _answerController = TextEditingController();
  final _gmailController = TextEditingController();
  String _question = securityQuestions.first;
  bool _connectGmail = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _answerController.dispose();
    _gmailController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (!_formKey.currentState!.validate()) return;
    final error = AuthStateScope.of(context).signUp(
      fullName: _nameController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      securityQuestion: _question,
      securityAnswer: _answerController.text,
      gmail: _connectGmail ? _gmailController.text : null,
    );
    if (error != null) {
      showAppSnackBar(context, error, isError: true);
      return;
    }
    showAppSnackBar(context, 'Welcome to Scentiments, ${_nameController.text.trim()}!');
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _signUpWithGmail() async {
    final auth = AuthStateScope.of(context);
    final result = await showGmailSignInSheet(context, title: 'Sign up with Google');
    if (result == null || !mounted) return;
    final error = auth.signInWithGmail(result.$1, fullName: result.$2);
    if (!mounted) return;
    if (error != null) {
      showAppSnackBar(context, error, isError: true);
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Create Account'), centerTitle: true),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        child: Column(
          children: [
            const Center(
              child: ScentimentsLogo(height: 72),
            ),
            const SizedBox(height: 16),
            GmailButton(label: 'Sign up with Gmail', onPressed: _signUpWithGmail),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(color: AppTheme.borderSubtle)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or use a username & password',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ),
                Expanded(child: Divider(color: AppTheme.borderSubtle)),
              ],
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabeledField(
                      label: 'Full Name',
                      controller: _nameController,
                      hint: 'Juan Dela Cruz',
                      icon: Icons.badge_outlined,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                    ),
                    LabeledField(
                      label: 'Username',
                      controller: _usernameController,
                      hint: '4-20 letters, numbers, _ or .',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => AuthState.isValidUsername(v ?? '')
                          ? null
                          : 'Use 4-20 letters, numbers, "_" or "."',
                    ),
                    PasswordField(
                      label: 'Password',
                      controller: _passwordController,
                      hint: 'At least 6 characters',
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Password must be at least 6 characters'
                          : null,
                    ),
                    PasswordField(
                      label: 'Confirm Password',
                      controller: _confirmController,
                      hint: 'Re-enter your password',
                      validator: (v) =>
                          v != _passwordController.text ? 'Passwords do not match' : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Account Recovery',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Used to reset your password if you forget it.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Security Question',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _question,
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
                      onChanged: (v) => setState(() => _question = v ?? _question),
                    ),
                    const SizedBox(height: 14),
                    LabeledField(
                      label: 'Answer',
                      controller: _answerController,
                      hint: 'Your answer',
                      icon: Icons.question_answer_outlined,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Please provide an answer' : null,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _connectGmail,
                      activeThumbColor: AppTheme.darkBluePrimary,
                      onChanged: (v) => setState(() => _connectGmail = v),
                      title: Text(
                        'Connect my Gmail',
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'Lets you log in with Gmail and receive reset codes there.',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                      ),
                    ),
                    if (_connectGmail)
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
                    const SizedBox(height: 8),
                    PrimaryButton(
                      label: 'Create Account',
                      icon: Icons.person_add_alt_1_rounded,
                      onPressed: _signUp,
                    ),
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
