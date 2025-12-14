import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // Added for StreamSubscription
import 'package:connectivity_plus/connectivity_plus.dart'; // Added for Connectivity
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/models/user_model.dart';
import 'core/models/upgrade_model.dart';
import 'core/models/achievement_model.dart';
import 'core/services/admob_service.dart';
import 'features/splash/kinetic_forge_splash.dart';
import 'features/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/home/home_screen.dart';
import 'core/services/security_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(UpgradeModelAdapter());
  Hive.registerAdapter(AchievementModelAdapter());
  Hive.registerAdapter(OwnedUpgradeAdapter());

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize AdMob
  await AdMobService().initialize();

  // Initialize Security Service
  await SecurityService().initialize();

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.backgroundSecondary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: MiningApp()));
}

class MiningApp extends StatelessWidget {
  const MiningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CryptoMiner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppEntry(),
    );
  }
}

/// App entry point managing splash → login → home flow with Connectivity Guard
class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  AppState _appState = AppState.splash;
  bool _isConnected = true;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException {
      result = [ConnectivityResult.none];
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _isConnected = !result.contains(ConnectivityResult.none);
    });
  }

  void _onSplashComplete() {
    setState(() => _appState = AppState.login);
  }

  void _onLoginComplete() {
    setState(() => _appState = AppState.home);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main App Content
        if (_isConnected) _buildContent() else const _NoInternetScreen(),

        // Overlay for blocking if connection drops while using
        if (!_isConnected)
          Container(
            color: Colors.black.withAlpha(204),
            width: double.infinity,
            height: double.infinity,
          ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_appState) {
      case AppState.splash:
        return KineticForgeSplash(onComplete: _onSplashComplete);
      case AppState.login:
        return LoginScreen(onLoginSuccess: _onLoginComplete);
      case AppState.home:
        return const HomeScreen();
    }
  }
}

class _NoInternetScreen extends StatelessWidget {
  const _NoInternetScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 80,
                color: AppColors.error,
              ),
              const SizedBox(height: 24),
              Text(
                'No Internet Connection',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'CryptoMiner requires an active internet connection to mine and save your progress.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum AppState { splash, login, home }
