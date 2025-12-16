import 'package:flutter/material.dart';
import '../../core/models/notification_model.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = NotificationService().getHistory();
    });
    // Mark as read when opening screen
    NotificationService().markAllAsRead();
  }

  void _clearHistory() async {
    await NotificationService().clearHistory();
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // Confirm dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.cardBackground,
                  title: const Text('Clear History'),
                  content: const Text(
                      'Are you sure you want to delete all notifications?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text('Clear',
                          style: TextStyle(color: AppColors.error)),
                      onPressed: () {
                        Navigator.pop(context);
                        _clearHistory();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_off_outlined,
                      size: 60, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No notifications', style: AppTextStyles.bodyLarge),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    Color iconColor;
    IconData iconData;

    switch (notification.type) {
      case 'reward':
        iconColor = AppColors.secondary; // Goldish
        iconData = Icons.emoji_events;
        break;
      case 'system':
        iconColor = AppColors.error;
        iconData = Icons.info_outline;
        break;
      default:
        iconColor = AppColors.primary;
        iconData = Icons.notifications;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cardBorder.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(
          notification.title,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.body, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMM d, h:mm a').format(notification.timestamp),
              style:
                  AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
