class LectureNotification {
  final String id;
  final String? lectureId; // null for template-based notifications (virtual instances)
  final String? templateId; // null for one-time lecture notifications
  final DateTime scheduledFor; // When the notification should fire
  final String notificationType; // 'lecture_reminder', 'lecture_starting', 'lecture_cancelled', etc.
  final bool isSent;
  final DateTime? sentAt;
  final String? fcmMessageId; // Firebase Cloud Messaging ID (for tracking)
  final String? errorMessage; // If notification failed to send
  final DateTime createdAt;
  final DateTime updatedAt;

  const LectureNotification({
    required this.id,
    this.lectureId,
    this.templateId,
    required this.scheduledFor,
    required this.notificationType,
    this.isSent = false,
    this.sentAt,
    this.fcmMessageId,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  LectureNotification copyWith({
    String? id,
    String? lectureId,
    String? templateId,
    DateTime? scheduledFor,
    String? notificationType,
    bool? isSent,
    DateTime? sentAt,
    String? fcmMessageId,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LectureNotification(
      id: id ?? this.id,
      lectureId: lectureId ?? this.lectureId,
      templateId: templateId ?? this.templateId,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      notificationType: notificationType ?? this.notificationType,
      isSent: isSent ?? this.isSent,
      sentAt: sentAt ?? this.sentAt,
      fcmMessageId: fcmMessageId ?? this.fcmMessageId,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LectureNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LectureNotification(id: $id, type: $notificationType, scheduledFor: $scheduledFor, sent: $isSent)';
  }
}
