import 'package:hive_flutter/hive_flutter.dart';
import 'package:aparna_education/features/notifications/data/models/notification_model.dart';

abstract class NotificationLocalDataSource {
  Future<List<NotificationModel>> getCachedNotifications(String userId);
  Future<void> cacheNotifications(String userId, List<NotificationModel> notifications);
  Future<void> markAsRead(String notificationId);
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  static const String _boxName = 'notifications_cache';

  Future<Box> _box() async {
    return Hive.openBox(_boxName);
  }

  @override
  Future<List<NotificationModel>> getCachedNotifications(String userId) async {
    final box = await _box();
    final cached = box.get(userId);
    if (cached is List) {
      return cached
          .whereType<Map>()
          .map((json) => NotificationModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    return [];
  }

  @override
  Future<void> cacheNotifications(
    String userId,
    List<NotificationModel> notifications,
  ) async {
    final box = await _box();
    final data = notifications.map((n) => n.toJson()).toList();
    await box.put(userId, data);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final box = await _box();
    for (final key in box.keys) {
      final cached = box.get(key);
      if (cached is! List) {
        continue;
      }

      final updated = cached
          .whereType<Map>()
          .map((json) => Map<String, dynamic>.from(json))
          .map((json) {
            if (json['id'] == notificationId) {
              json['is_read'] = true;
              json['read_at'] = DateTime.now().toIso8601String();
            }
            return json;
          })
          .toList();

      await box.put(key, updated);
    }
  }
}
