import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:installed_apps/installed_apps.dart';

/// Security service for anti-cheat measures (F10.1)
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  bool _initialized = false;
  bool _isRooted = false;
  bool _isDebugMode = false;
  bool _isEmulator = false;
  final List<String> _securityFlags = [];

  /// Initialize security checks
  Future<void> initialize() async {
    if (_initialized) return;

    _isDebugMode = kDebugMode;

    if (Platform.isAndroid) {
      await _checkAndroidSecurity();
    } else if (Platform.isIOS) {
      await _checkIOSSecurity();
    }

    _initialized = true;
    debugPrint('Security Service initialized');
    debugPrint('Root/Jailbreak: $_isRooted');
    debugPrint('Debug Mode: $_isDebugMode');
    debugPrint('Emulator: $_isEmulator');
    debugPrint('Flags: $_securityFlags');
  }

  /// Check Android security
  Future<void> _checkAndroidSecurity() async {
    try {
      // Check for common root indicators
      final rootIndicators = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
        '/system/sd/xbin/su',
        '/system/bin/failsafe/su',
        '/data/local/su',
        '/su/bin/su',
        '/system/xbin/daemonsu',
        '/system/etc/init.d/99telegramhideroot',
        '/sbin/daemonsu',
      ];

      for (final path in rootIndicators) {
        if (File(path).existsSync()) {
          _isRooted = true;
          _securityFlags.add('root_binary_found:$path');
          break;
        }
      }

      // Check for Magisk
      if (Directory('/data/adb/magisk').existsSync() ||
          Directory('/sbin/.magisk').existsSync()) {
        _isRooted = true;
        _securityFlags.add('magisk_detected');
      }

      // Root management apps (for future package check)
      // ignore: unused_local_variable
      final rootApps = [
        'com.noshufou.android.su',
        'com.noshufou.android.su.elite',
        'eu.chainfire.supersu',
        'com.koushikdutta.superuser',
        'com.thirdparty.superuser',
        'com.yellowes.su',
        'com.topjohnwu.magisk',
        'com.kingroot.kinguser',
        'com.kingo.root',
        'com.smedialink.onecleanmaster',
      ];

      // Check installed packages
      for (final appPackage in rootApps) {
        try {
          bool? isInstalled = await InstalledApps.isAppInstalled(appPackage);
          if (isInstalled == true) {
            _isRooted = true;
            _securityFlags.add('potentially_dangerous_app:$appPackage');
          }
        } catch (e) {
          // Ignore error checking package
        }
      }

      // Check for test-keys (indicates custom ROM)
      await _checkBuildTags();

      // Check for emulator
      await _checkEmulator();
    } catch (e) {
      debugPrint('Security check error: $e');
      _securityFlags.add('check_error:$e');
    }
  }

  /// Check iOS security (Jailbreak)
  Future<void> _checkIOSSecurity() async {
    try {
      // Check for common jailbreak files
      final jailbreakPaths = [
        '/Applications/Cydia.app',
        '/Library/MobileSubstrate/MobileSubstrate.dylib',
        '/bin/bash',
        '/usr/sbin/sshd',
        '/etc/apt',
        '/private/var/lib/apt/',
        '/private/var/lib/cydia',
        '/private/var/tmp/cydia.log',
        '/Applications/RockApp.app',
        '/Applications/Icy.app',
        '/Applications/WinterBoard.app',
        '/Applications/SBSettings.app',
        '/Applications/MxTube.app',
        '/Applications/IntelliScreen.app',
        '/Applications/FakeCarrier.app',
        '/Applications/blackra1n.app',
        '/private/var/stash',
        '/usr/libexec/sftp-server',
        '/usr/bin/sshd',
        '/Library/MobileSubstrate/DynamicLibraries',
        '/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist',
      ];

      for (final path in jailbreakPaths) {
        if (File(path).existsSync()) {
          _isRooted = true;
          _securityFlags.add('jailbreak_file:$path');
          break;
        }
      }

      // Check if app can write outside sandbox
      try {
        final testFile = File('/private/jailbreak_test');
        testFile.writeAsStringSync('test');
        testFile.deleteSync();
        _isRooted = true;
        _securityFlags.add('sandbox_escape');
      } catch (_) {
        // Good - sandbox is working
      }
    } catch (e) {
      debugPrint('iOS security check error: $e');
      _securityFlags.add('ios_check_error:$e');
    }
  }

  /// Check Android build tags for test-keys
  Future<void> _checkBuildTags() async {
    try {
      final result = await Process.run('getprop', ['ro.build.tags']);
      final tags = result.stdout.toString().trim();
      if (tags.contains('test-keys')) {
        _securityFlags.add('test_keys');
      }
    } catch (_) {
      // Ignore - property may not be accessible
    }
  }

  /// Check if running on emulator
  Future<void> _checkEmulator() async {
    try {
      // Check common emulator indicators via build properties
      final emulatorIndicators = await _getEmulatorIndicators();

      if (emulatorIndicators.any((indicator) => indicator)) {
        _isEmulator = true;
        _securityFlags.add('emulator_detected');
      }
    } catch (_) {
      // Ignore errors
    }
  }

  /// Get emulator indicators
  Future<List<bool>> _getEmulatorIndicators() async {
    final indicators = <bool>[];

    try {
      // Check for emulator fingerprint
      final fingerprintResult = await Process.run('getprop', [
        'ro.build.fingerprint',
      ]);
      final fingerprint = fingerprintResult.stdout.toString().toLowerCase();
      indicators.add(
        fingerprint.contains('generic') ||
            fingerprint.contains('emulator') ||
            fingerprint.contains('sdk'),
      );

      // Check hardware
      final hardwareResult = await Process.run('getprop', ['ro.hardware']);
      final hardware = hardwareResult.stdout.toString().toLowerCase();
      indicators.add(
        hardware.contains('goldfish') ||
            hardware.contains('ranchu') ||
            hardware.contains('vbox'),
      );

      // Check product
      final productResult = await Process.run('getprop', ['ro.product.model']);
      final product = productResult.stdout.toString().toLowerCase();
      indicators.add(
        product.contains('sdk') ||
            product.contains('emulator') ||
            product.contains('android sdk'),
      );
    } catch (_) {
      // Properties not accessible
    }

    return indicators;
  }

  /// Get security status
  SecurityStatus get status => SecurityStatus(
    isRooted: _isRooted,
    isDebugMode: _isDebugMode,
    isEmulator: _isEmulator,
    flags: List.unmodifiable(_securityFlags),
    isSafe: !_isRooted && !_isDebugMode,
  );

  /// Check if earnings should be limited
  bool get shouldLimitEarnings => _isRooted || _isDebugMode;

  /// Check if app is running in safe mode
  bool get isSafeMode => !_isRooted && !_isDebugMode && !_isEmulator;

  /// Get warning message for user if compromised
  String? get securityWarning {
    if (_isRooted) {
      return 'Root/jailbreak detected. Some features may be limited for security.';
    }
    if (_isDebugMode) {
      return 'Debug mode detected. Earnings are disabled in development builds.';
    }
    return null;
  }

  /// Report security status to server
  Map<String, dynamic> toReportJson() {
    return {
      'isRooted': _isRooted,
      'isDebugMode': _isDebugMode,
      'isEmulator': _isEmulator,
      'flags': _securityFlags,
      'platform': Platform.operatingSystem,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Verify if high-value actions should be allowed
  bool isActionAllowed({bool highValue = false}) {
    if (highValue && (_isRooted || _isEmulator)) {
      return false;
    }
    return true;
  }
}

/// Security status model
class SecurityStatus {
  final bool isRooted;
  final bool isDebugMode;
  final bool isEmulator;
  final List<String> flags;
  final bool isSafe;

  const SecurityStatus({
    required this.isRooted,
    required this.isDebugMode,
    required this.isEmulator,
    required this.flags,
    required this.isSafe,
  });

  @override
  String toString() {
    return 'SecurityStatus(rooted: $isRooted, debug: $isDebugMode, emulator: $isEmulator, safe: $isSafe)';
  }
}
