import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/notification_model.dart';
import '../models/user_model.dart'; // Import user model for checking settings

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Box<NotificationModel>? _notificationsBox;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Init Hive box
    if (!Hive.isBoxOpen('notifications')) {
      _notificationsBox =
          await Hive.openBox<NotificationModel>('notifications');
    } else {
      _notificationsBox = Hive.box<NotificationModel>('notifications');
    }

    // Init Timezone
    tz.initializeTimeZones();

    // Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );

    _initialized = true;
  }

  /// Show local notification and save to history
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String type = 'info',
    bool saveToHistory = true,
    UserModel? user, // Pass user to check settings
  }) async {
    // Check if notifications enabled in settings
    if (user != null && !user.isNotificationsEnabled) {
      // Even if disabled, we might want to save to history?
      // User request: "dump those notification in an dedicated screen".
      // Usually "Turn off notifications" means turn off PUSH/LOCAL alerts.
      // The history dump is likely desired regardless.
      if (saveToHistory) {
        _saveToHistory(title, body, type);
      }
      return;
    }

    if (saveToHistory) {
      _saveToHistory(title, body, type);
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'mining_app_channel',
      'Mining App Notifications',
      channelDescription: 'Game alerts and rewards',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // Unique ID
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mining_app_scheduled',
          'Scheduled Notifications',
          channelDescription: 'Energy full, daily bonus, etc.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Save to local history
  Future<void> _saveToHistory(String title, String body, String type) async {
    if (_notificationsBox == null) return;

    final notification = NotificationModel.create(
      title: title,
      body: body,
      type: type,
    );
    await _notificationsBox!.add(notification);
  }

  /// Get all notifications from history
  List<NotificationModel> getHistory() {
    if (_notificationsBox == null) return [];
    final list = _notificationsBox!.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first
    return list;
  }

  /// Clear history
  Future<void> clearHistory() async {
    await _notificationsBox?.clear();
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    if (_notificationsBox == null) return;
    // Hive values are direct objects. To update, we usually put back at key.
    // But box.values doesn't give keys directly easily in loop.
    final keys = _notificationsBox!.keys;
    for (var key in keys) {
      final n = _notificationsBox!.get(key);
      if (n != null && !n.isRead) {
        _notificationsBox!.put(key, n.copyWith(isRead: true));
      }
    }
  }
}
