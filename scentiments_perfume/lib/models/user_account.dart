/// A registered Scentiments member.
///
/// An account can be created in two ways:
///  * with a username + password only (recovered using a security question)
///  * by connecting a Gmail address (recovered using a code sent to Gmail)
/// A username/password account may later connect a Gmail address in Settings.
class UserAccount {
  final String id;
  String fullName;
  String username;
  String? password;
  String? gmail;
  String phone;
  String address;
  String securityQuestion;
  String securityAnswer;

  UserAccount({
    required this.id,
    required this.fullName,
    required this.username,
    this.password,
    this.gmail,
    this.phone = '',
    this.address = '',
    this.securityQuestion = '',
    this.securityAnswer = '',
  });

  bool get hasPassword => password != null && password!.isNotEmpty;
  bool get isGmailConnected => gmail != null && gmail!.isNotEmpty;
  bool get hasSecurityQuestion =>
      securityQuestion.isNotEmpty && securityAnswer.isNotEmpty;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return username.isNotEmpty ? username[0].toUpperCase() : '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

const List<String> securityQuestions = [
  'What is the name of your first pet?',
  'What city were you born in?',
  'What is your favorite perfume scent?',
  'What was the name of your elementary school?',
  'What is your mother\'s maiden name?',
];
