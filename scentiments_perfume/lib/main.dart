import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'state/auth_state.dart';
import 'state/chat_state.dart';
import 'state/shop_state.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ScentimentsApp());
}

class ScentimentsApp extends StatefulWidget {
  const ScentimentsApp({super.key});

  @override
  State<ScentimentsApp> createState() => _ScentimentsAppState();
}

class _ScentimentsAppState extends State<ScentimentsApp> {
  final ShopState _shopState = ShopState();
  final AuthState _authState = AuthState();
  final ChatState _chatState = ChatState();
  final ThemeController _themeController = ThemeController();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _themeController.addListener(_onThemeChanged);
    _authState.addListener(_onAuthChanged);
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _onAuthChanged() {
    // When the user logs out, close any open pages (Settings, Chats...)
    if (!_authState.isLoggedIn) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _themeController.removeListener(_onThemeChanged);
    _authState.removeListener(_onAuthChanged);
    _shopState.dispose();
    _authState.dispose();
    _chatState.dispose();
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      notifier: _themeController,
      child: AuthStateScope(
        notifier: _authState,
        child: ChatStateScope(
          notifier: _chatState,
          child: ShopStateScope(
            notifier: _shopState,
            child: MaterialApp(
              title: 'Scentiments',
              navigatorKey: _navigatorKey,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: _themeController.isDark ? ThemeMode.dark : ThemeMode.light,
              home: const AuthGate(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows the Log In screen until the user is signed in.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthStateScope.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: auth.isLoggedIn
          ? const MainNavigationScreen(key: ValueKey('main'))
          : const LoginScreen(key: ValueKey('login')),
    );
  }
}
