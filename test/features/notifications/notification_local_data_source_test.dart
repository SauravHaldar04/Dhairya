import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';
import 'package:aparna_education/features/notifications/data/datasources/notification_local_data_source.dart';
import 'package:aparna_education/features/notifications/data/models/notification_model.dart';

void main() {
  setUp(() async {
    await setUpTestHive();
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('caches and returns notifications for user', () async {
    final dataSource = NotificationLocalDataSourceImpl();
    const userId = 'user-1';

    final notification = NotificationModel(
      id: 'n1',
      userId: userId,
      title: 'Test',
      message: 'Hello',
      notificationType: 'teacher_verified',
      isRead: false,
      createdAt: DateTime.now(),
    );

    await dataSource.cacheNotifications(userId, [notification]);
    final cached = await dataSource.getCachedNotifications(userId);

    expect(cached.length, 1);
    expect(cached.first.id, 'n1');
    expect(cached.first.isRead, false);
  });

  test('marks notification as read across cache', () async {
    final dataSource = NotificationLocalDataSourceImpl();
    const userId = 'user-2';

    final notification = NotificationModel(
      id: 'n2',
      userId: userId,
      title: 'Test',
      message: 'Hello',
      notificationType: 'teacher_rejected',
      isRead: false,
      createdAt: DateTime.now(),
    );

    await dataSource.cacheNotifications(userId, [notification]);
    await dataSource.markAsRead('n2');
    final cached = await dataSource.getCachedNotifications(userId);

    expect(cached.first.isRead, true);
  });
}
