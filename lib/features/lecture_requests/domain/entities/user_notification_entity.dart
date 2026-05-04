class UserNotificationEntity {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String notificationType;
  final String? relatedLectureRequestId;
  final String? relatedAssignmentId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const UserNotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.notificationType,
    this.relatedLectureRequestId,
    this.relatedAssignmentId,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });
}
