import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'notification_model.g.dart';

enum NotificationType { info, reward, system }

@HiveType(typeId: 4)
class NotificationModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final bool isRead;

  @HiveField(5)
  final String type; // 'info', 'reward', 'system'

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.type = 'info',
  });

  factory NotificationModel.create({
    required String title,
    required String body,
    String type = 'info',
  }) {
    return NotificationModel(
      id: const Uuid().v4(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    String? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}
