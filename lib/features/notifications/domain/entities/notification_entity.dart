class NotificationEntity {
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

  const NotificationEntity({
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

  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? notificationType,
    String? relatedLectureRequestId,
    String? relatedAssignmentId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      notificationType: notificationType ?? this.notificationType,
      relatedLectureRequestId: relatedLectureRequestId ?? this.relatedLectureRequestId,
      relatedAssignmentId: relatedAssignmentId ?? this.relatedAssignmentId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}
