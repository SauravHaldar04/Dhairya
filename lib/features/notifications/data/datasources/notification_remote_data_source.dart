import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/features/notifications/data/models/notification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getUserNotifications(String userId);
  Future<void> markAsRead(String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient supabaseClient;

  NotificationRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      final response = await supabaseClient
          .from('user_notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch notifications');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await supabaseClient
          .from('user_notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
    } catch (e) {
      throw ServerException(message: 'Failed to mark notification as read');
    }
  }
}
