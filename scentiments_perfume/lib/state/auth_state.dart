import 'dart:math';
import 'package:flutter/material.dart';
import '../models/user_account.dart';

/// Handles log in, sign up, Gmail sign in, forgot password and profile edits.
///
/// NOTE: This is a local (in-memory) implementation so the app works offline
/// without a backend. Gmail sign-in and the reset e-mail are simulated.
class AuthState extends ChangeNotifier {
  final Random _random = Random();

  final List<UserAccount> _accounts = [
    // Demo account created with username + password AND connected to Gmail
    UserAccount(
      id: 'u1',
      fullName: 'Scentiments VIP Connoisseur',
      username: 'scentvip',
      password: 'scent123',
      gmail: 'member.scentiments@gmail.com',
      phone: '0917 123 4567',
      address: 'Quezon City, Metro Manila',
      securityQuestion: securityQuestions[2],
      securityAnswer: 'amber',
    ),
    // Demo account created with username + password only
    UserAccount(
      id: 'u2',
      fullName: 'Juan Dela Cruz',
      username: 'juandelacruz',
      password: 'password123',
      phone: '0998 765 4321',
      address: 'Cebu City, Cebu',
      securityQuestion: securityQuestions[0],
      securityAnswer: 'bantay',
    ),
  ];

  UserAccount? _currentUser;

  // Forgot-password reset codes "sent" to Gmail: accountId -> code
  final Map<String, String> _resetCodes = {};
  final Map<String, DateTime> _resetCodeExpiry = {};

  UserAccount? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static bool isValidGmail(String value) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(value.trim());
  }

  static bool isValidUsername(String value) {
    return RegExp(r'^[a-zA-Z0-9_.]{4,20}$').hasMatch(value.trim());
  }

  /// Finds an account by its username or connected Gmail address.
  UserAccount? findAccount(String identifier) {
    final id = identifier.trim().toLowerCase();
    if (id.isEmpty) return null;
    for (final a in _accounts) {
      if (a.username.toLowerCase() == id) return a;
      if (a.gmail != null && a.gmail!.toLowerCase() == id) return a;
    }
    return null;
  }

  bool _usernameTaken(String username, {String? exceptId}) {
    final u = username.trim().toLowerCase();
    return _accounts.any((a) => a.id != exceptId && a.username.toLowerCase() == u);
  }

  bool _gmailTaken(String gmail, {String? exceptId}) {
    final g = gmail.trim().toLowerCase();
    return _accounts.any(
        (a) => a.id != exceptId && a.gmail != null && a.gmail!.toLowerCase() == g);
  }

  String _newId() => 'u${DateTime.now().microsecondsSinceEpoch}';

  // ---------------------------------------------------------------------------
  // Log in / Sign up / Log out
  // ---------------------------------------------------------------------------

  /// Logs in with a username (or Gmail) and password.
  /// Returns an error message, or null on success.
  String? login(String identifier, String password) {
    final account = findAccount(identifier);
    if (account == null) {
      return 'No account found for "$identifier".';
    }
    if (!account.hasPassword) {
      return 'This account was created with Gmail. Use "Continue with Gmail" '
          'or set a password via "Forgot password".';
    }
    if (account.password != password) {
      return 'Incorrect password. Please try again.';
    }
    _currentUser = account;
    notifyListeners();
    return null;
  }

  /// Creates a username + password account (optionally connected to Gmail).
  String? signUp({
    required String fullName,
    required String username,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
    String? gmail,
  }) {
    if (!isValidUsername(username)) {
      return 'Username must be 4-20 letters, numbers, "_" or ".".';
    }
    if (_usernameTaken(username)) {
      return 'Username "$username" is already taken.';
    }
    if (gmail != null && gmail.trim().isNotEmpty) {
      if (!isValidGmail(gmail)) return 'Please enter a valid @gmail.com address.';
      if (_gmailTaken(gmail)) return 'That Gmail is already connected to another account.';
    }
    final account = UserAccount(
      id: _newId(),
      fullName: fullName.trim(),
      username: username.trim(),
      password: password,
      gmail: (gmail == null || gmail.trim().isEmpty) ? null : gmail.trim().toLowerCase(),
      securityQuestion: securityQuestion,
      securityAnswer: securityAnswer.trim().toLowerCase(),
    );
    _accounts.add(account);
    _currentUser = account;
    notifyListeners();
    return null;
  }

  /// Simulated "Continue with Gmail". Logs into the account connected to that
  /// Gmail, or creates a new Gmail account if none exists yet.
  /// Returns an error message, or null on success.
  String? signInWithGmail(String gmail, {String? fullName}) {
    if (!isValidGmail(gmail)) return 'Please enter a valid @gmail.com address.';
    final email = gmail.trim().toLowerCase();
    final existing = findAccount(email);
    if (existing != null && existing.gmail == email) {
      _currentUser = existing;
      notifyListeners();
      return null;
    }

    // Build a unique username from the Gmail prefix
    var base = email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_.]'), '');
    if (base.length < 4) base = '${base}user';
    if (base.length > 16) base = base.substring(0, 16);
    var username = base;
    var n = 1;
    while (_usernameTaken(username)) {
      username = '$base$n';
      n++;
    }

    final name = (fullName == null || fullName.trim().isEmpty)
        ? _nameFromEmail(email)
        : fullName.trim();

    final account = UserAccount(
      id: _newId(),
      fullName: name,
      username: username,
      gmail: email,
    );
    _accounts.add(account);
    _currentUser = account;
    notifyListeners();
    return null;
  }

  String _nameFromEmail(String email) {
    final prefix = email.split('@').first.replaceAll(RegExp(r'[._0-9]+'), ' ').trim();
    if (prefix.isEmpty) return 'Scentiments Member';
    return prefix
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Forgot password
  // ---------------------------------------------------------------------------

  /// Generates a 6-digit code and "sends" it to the account's Gmail.
  /// Returns the code so the demo UI can display the simulated e-mail.
  String sendResetCode(UserAccount account) {
    final code = (100000 + _random.nextInt(900000)).toString();
    _resetCodes[account.id] = code;
    _resetCodeExpiry[account.id] = DateTime.now().add(const Duration(minutes: 10));
    return code;
  }

  /// Returns an error message, or null if the code is correct.
  String? verifyResetCode(UserAccount account, String code) {
    final expected = _resetCodes[account.id];
    final expiry = _resetCodeExpiry[account.id];
    if (expected == null || expiry == null) return 'Please request a new code.';
    if (DateTime.now().isAfter(expiry)) return 'This code has expired. Request a new one.';
    if (code.trim() != expected) return 'Incorrect code. Please check your Gmail.';
    return null;
  }

  bool verifySecurityAnswer(UserAccount account, String answer) {
    return account.hasSecurityQuestion &&
        account.securityAnswer == answer.trim().toLowerCase();
  }

  void resetPassword(UserAccount account, String newPassword) {
    account.password = newPassword;
    _resetCodes.remove(account.id);
    _resetCodeExpiry.remove(account.id);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Settings / Profile
  // ---------------------------------------------------------------------------

  String? updateProfile({
    required String fullName,
    required String username,
    required String phone,
    required String address,
  }) {
    final user = _currentUser;
    if (user == null) return 'You are not logged in.';
    if (fullName.trim().isEmpty) return 'Full name is required.';
    if (!isValidUsername(username)) {
      return 'Username must be 4-20 letters, numbers, "_" or ".".';
    }
    if (_usernameTaken(username, exceptId: user.id)) {
      return 'Username "$username" is already taken.';
    }
    user.fullName = fullName.trim();
    user.username = username.trim();
    user.phone = phone.trim();
    user.address = address.trim();
    notifyListeners();
    return null;
  }

  /// Changes (or sets, for Gmail-only accounts) the password.
  String? changePassword({String? currentPassword, required String newPassword}) {
    final user = _currentUser;
    if (user == null) return 'You are not logged in.';
    if (user.hasPassword && user.password != currentPassword) {
      return 'Your current password is incorrect.';
    }
    if (newPassword.length < 6) return 'Password must be at least 6 characters.';
    user.password = newPassword;
    notifyListeners();
    return null;
  }

  String? connectGmail(String gmail) {
    final user = _currentUser;
    if (user == null) return 'You are not logged in.';
    if (!isValidGmail(gmail)) return 'Please enter a valid @gmail.com address.';
    if (_gmailTaken(gmail, exceptId: user.id)) {
      return 'That Gmail is already connected to another account.';
    }
    user.gmail = gmail.trim().toLowerCase();
    notifyListeners();
    return null;
  }

  String? disconnectGmail() {
    final user = _currentUser;
    if (user == null) return 'You are not logged in.';
    if (!user.hasPassword) {
      return 'Set a password first so you can still log in without Gmail.';
    }
    user.gmail = null;
    notifyListeners();
    return null;
  }

  void updateSecurityQuestion(String question, String answer) {
    final user = _currentUser;
    if (user == null) return;
    user.securityQuestion = question;
    user.securityAnswer = answer.trim().toLowerCase();
    notifyListeners();
  }
}

class AuthStateScope extends InheritedNotifier<AuthState> {
  const AuthStateScope({
    super.key,
    required AuthState super.notifier,
    required super.child,
  });

  static AuthState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthStateScope>()!.notifier!;
  }
}
