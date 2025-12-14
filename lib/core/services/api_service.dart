import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Service for backend API calls to Cloudflare Worker
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConstants.cloudflareWorkerBaseUrl;
  String _requestSecret =
      'default-secret'; // Will be overwritten by secure storage

  /// Initialize API service
  Future<void> initialize() async {
    const storage = FlutterSecureStorage();
    _requestSecret =
        await storage.read(key: 'request_secret') ?? 'your-secret-here';
  }

  /// Validate taps with backend
  Future<TapValidationResult> validateTaps({
    required String uid,
    required int taps,
    required String deviceId,
    required String sessionId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/validate-taps'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-Secret': _requestSecret,
        },
        body: jsonEncode({
          'uid': uid,
          'taps': taps,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'deviceId': deviceId,
          'sessionId': sessionId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TapValidationResult(
          valid: data['valid'] ?? false,
          reason: data['reason'],
          adjustedTaps: data['adjustedTaps'] ?? taps,
          warning: data['warning'] ?? false,
          totalTaps: data['totalTaps'] ?? 0,
          dailyTaps: data['dailyTaps'] ?? 0,
        );
      } else {
        debugPrint('Tap validation failed: ${response.body}');
        return TapValidationResult(
          valid: true, // Fallback to client-side
          adjustedTaps: taps,
        );
      }
    } catch (e) {
      debugPrint('Tap validation error: $e');
      // Fallback to allowing the taps if backend is unreachable
      return TapValidationResult(valid: true, adjustedTaps: taps);
    }
  }

  /// Verify purchase with backend
  Future<bool> verifyPurchase({
    required String uid,
    required String productId,
    required String paymentId,
    required String signature,
    required String orderId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/verify-purchase'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-Secret': _requestSecret,
        },
        body: jsonEncode({
          'uid': uid,
          'productId': productId,
          'paymentId': paymentId,
          'signature': signature,
          'orderId': orderId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valid'] ?? false;
      }
      return false; // Fail secure
    } catch (e) {
      debugPrint('Purchase verification error: $e');
      return false; // Fail secure
    }
  }

  /// Get user stats from backend
  Future<UserStats?> getUserStats(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/get-stats?uid=$uid'),
        headers: {'X-Request-Secret': _requestSecret},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserStats(
          totalTaps: data['totalTaps'] ?? 0,
          dailyTaps: data['dailyTaps'] ?? 0,
          suspiciousCount: data['suspiciousCount'] ?? 0,
          banned: data['banned'] ?? false,
          banReason: data['banReason'],
        );
      }
      return null;
    } catch (e) {
      debugPrint('Get stats error: $e');
      return null;
    }
  }

  /// Get leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/leaderboard?limit=$limit'),
        headers: {'X-Request-Secret': _requestSecret},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['leaderboard'] as List<dynamic>? ?? [];
        return list
            .map(
              (e) => LeaderboardEntry(
                uid: e['uid'] ?? '',
                displayName: e['displayName'] ?? 'Anonymous',
                coins: e['coins'] ?? 0,
                rank: e['rank'] ?? 0,
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get leaderboard error: $e');
      return [];
    }
  }

  /// Report suspicious activity
  Future<void> reportSuspicious(String uid, String reason) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/api/report-suspicious'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-Secret': _requestSecret,
        },
        body: jsonEncode({'uid': uid, 'reason': reason}),
      );
    } catch (e) {
      debugPrint('Report suspicious error: $e');
    }
  }

  /// Health check
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/health'),
        headers: {'X-Request-Secret': _requestSecret},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// Response classes

class TapValidationResult {
  final bool valid;
  final String? reason;
  final int adjustedTaps;
  final bool warning;
  final int totalTaps;
  final int dailyTaps;

  TapValidationResult({
    required this.valid,
    this.reason,
    required this.adjustedTaps,
    this.warning = false,
    this.totalTaps = 0,
    this.dailyTaps = 0,
  });
}

class UserStats {
  final int totalTaps;
  final int dailyTaps;
  final int suspiciousCount;
  final bool banned;
  final String? banReason;

  UserStats({
    required this.totalTaps,
    required this.dailyTaps,
    required this.suspiciousCount,
    required this.banned,
    this.banReason,
  });
}

class LeaderboardEntry {
  final String uid;
  final String displayName;
  final int coins;
  final int rank;

  LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.coins,
    required this.rank,
  });
}
