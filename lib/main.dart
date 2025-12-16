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
import 'features/splash/orbital_extraction_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/home/home_screen.dart';
import 'features/auth/login_screen.dart';
import 'core/services/security_service.dart';
import 'core/repositories/local_game_repository.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';
import 'core/models/notification_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(UpgradeModelAdapter());
  Hive.registerAdapter(AchievementModelAdapter());
  Hive.registerAdapter(OwnedUpgradeAdapter());
  Hive.registerAdapter(NotificationModelAdapter());

  // Initialize Local Repository
  await LocalGameRepository().init();

  // Initialize Firebase (keep online checks safe)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed (offline?): $e");
  }

  // Initialize AdMob
  await AdMobService().initialize();

  // Initialize Security Service
  await SecurityService().initialize();

  // Initialize Notification Service
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint("Notification init failed: $e");
  }

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
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _appState = user != null ? AppState.home : AppState.login;
    });
  }

  void _onLoginComplete() {
    setState(() => _appState = AppState.home);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main App Content - Only visible when connected
        if (_isConnected) _buildContent(),

        // Blocking Offline Screen
        if (!_isConnected)
          Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  const Text(
                    'No Internet Connection',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please enable internet to continue playing.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _initConnectivity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_appState) {
      case AppState.splash:
        return OrbitalExtractionSplash(onComplete: _onSplashComplete);
      case AppState.login:
        return LoginScreen(onLoginSuccess: _onLoginComplete);
      case AppState.home:
        return const HomeScreen();
    }
  }
}

enum AppState { splash, login, home }
