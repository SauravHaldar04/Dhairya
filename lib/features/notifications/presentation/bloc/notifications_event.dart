sealed class NotificationsEvent {
  const NotificationsEvent();
}

class FetchUserNotifications extends NotificationsEvent {
  final String userId;
  const FetchUserNotifications(this.userId);
}

class MarkNotificationAsRead extends NotificationsEvent {
  final String notificationId;
  const MarkNotificationAsRead(this.notificationId);
}
