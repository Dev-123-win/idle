import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for handling push notifications via FCM
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Notification channel IDs
  static const String _highImportanceChannelId = 'high_importance_channel';
  static const String _dailyReminderChannelId = 'daily_reminder_channel';
  static const String _achievementChannelId = 'achievement_channel';

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Android initialization
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels (Android 8.0+)
    await _createNotificationChannels();

    _initialized = true;
    debugPrint('Notification Service initialized');
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      // High importance channel for immediate notifications
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _highImportanceChannelId,
          'High Importance Notifications',
          description: 'Channel for important notifications like withdrawals',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // Daily reminder channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _dailyReminderChannelId,
          'Daily Reminders',
          description: 'Daily login streak and passive earnings reminders',
          importance: Importance.defaultImportance,
          playSound: true,
        ),
      );

      // Achievement channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _achievementChannelId,
          'Achievements',
          description: 'Achievement unlock notifications',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final iosPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    bool granted = false;

    if (androidPlugin != null) {
      granted = await androidPlugin.requestNotificationsPermission() ?? false;
    }

    if (iosPlugin != null) {
      granted =
          await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return granted;
  }

  /// Show daily streak reminder
  Future<void> showStreakReminder(int currentStreak) async {
    await _showNotification(
      id: 1,
      title: "Don't break your streak! 🔥",
      body:
          'Day $currentStreak streak is at risk! Open the app to claim your daily bonus.',
      channelId: _dailyReminderChannelId,
      payload: 'streak_reminder',
    );
  }

  /// Show passive earnings ready notification
  Future<void> showPassiveEarningsReady(int coins) async {
    await _showNotification(
      id: 2,
      title: 'Your coins are waiting! 💰',
      body: 'You have $coins coins from passive mining. Claim them now!',
      channelId: _dailyReminderChannelId,
      payload: 'passive_ready',
    );
  }

  /// Show achievement unlocked notification
  Future<void> showAchievementUnlocked(
    String achievementName,
    int reward,
  ) async {
    await _showNotification(
      id: 3,
      title: 'Achievement Unlocked! 🏆',
      body: '$achievementName - Claim $reward coins!',
      channelId: _achievementChannelId,
      payload: 'achievement_unlocked',
    );
  }

  /// Show referral active notification
  Future<void> showReferralActive(String referralName) async {
    await _showNotification(
      id: 4,
      title: 'Referral Bonus Earned! 🎉',
      body: '$referralName is now active! Claim your 20,000 coin bonus!',
      channelId: _highImportanceChannelId,
      payload: 'referral_active',
    );
  }

  /// Show withdrawal status notification
  Future<void> showWithdrawalStatus(String status, double amount) async {
    String title;
    String body;

    switch (status) {
      case 'processing':
        title = 'Withdrawal Processing 🔄';
        body = 'Your ₹$amount withdrawal is being processed.';
        break;
      case 'completed':
        title = 'Withdrawal Complete! ✅';
        body = '₹$amount has been sent to your account!';
        break;
      case 'rejected':
        title = 'Withdrawal Rejected ❌';
        body = 'Your ₹$amount withdrawal was rejected. Please check details.';
        break;
      default:
        title = 'Withdrawal Update';
        body = 'Your ₹$amount withdrawal status: $status';
    }

    await _showNotification(
      id: 5,
      title: title,
      body: body,
      channelId: _highImportanceChannelId,
      payload: 'withdrawal_$status',
    );
  }

  /// Schedule daily streak reminder using periodic notification
  Future<void> scheduleDailyStreakReminder() async {
    // Cancel existing
    await _localNotifications.cancel(100);

    // Schedule daily reminder using periodicallyShow (avoids timezone issues)
    await _localNotifications.periodicallyShow(
      100,
      "Don't break your streak! 🔥",
      'Open CryptoMiner to claim your daily bonus!',
      RepeatInterval.daily,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyReminderChannelId,
          'Daily Reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Schedule passive earnings reminder
  /// Note: Uses app-level scheduling since exact time scheduling requires timezone package
  Future<void> schedulePassiveReminder() async {
    await _localNotifications.cancel(101);
    // Passive reminder should be triggered by game logic when 6 hours have passed
    // This is a placeholder for future implementation with WorkManager or similar
    debugPrint('Passive reminder scheduling - use game logic to trigger');
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllScheduled() async {
    await _localNotifications.cancelAll();
  }

  /// Show a notification
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == _highImportanceChannelId
          ? 'High Importance'
          : channelId == _achievementChannelId
          ? 'Achievements'
          : 'Daily Reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Navigation based on payload would be handled via a callback or global navigator
    // Example payloads: 'streak_reminder', 'passive_ready', 'achievement_unlocked'
  }

  /// Handle iOS local notification (foreground)
  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    debugPrint('iOS notification received: $title');
  }
}
