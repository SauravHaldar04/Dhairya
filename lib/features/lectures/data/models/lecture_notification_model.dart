import '../../domain/entities/lecture_notification_entity.dart';

class LectureNotificationModel extends LectureNotification {
  const LectureNotificationModel({
    required super.id,
    super.lectureId,
    super.templateId,
    required super.scheduledFor,
    required super.notificationType,
    super.isSent = false,
    super.sentAt,
    super.fcmMessageId,
    super.errorMessage,
    required super.createdAt,
    required super.updatedAt,
  });

  factory LectureNotificationModel.fromMap(Map<String, dynamic> map) {
    return LectureNotificationModel(
      id: map['id'] as String,
      lectureId: map['lecture_id'] as String?,
      templateId: map['template_id'] as String?,
      scheduledFor: DateTime.parse(map['scheduled_for'] as String),
      notificationType: map['notification_type'] as String,
      isSent: map['is_sent'] as bool? ?? false,
      sentAt: map['sent_at'] != null 
          ? DateTime.parse(map['sent_at'] as String) 
          : null,
      fcmMessageId: map['fcm_message_id'] as String?,
      errorMessage: map['error_message'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lecture_id': lectureId,
      'template_id': templateId,
      'scheduled_for': scheduledFor.toIso8601String(),
      'notification_type': notificationType,
      'is_sent': isSent,
      'sent_at': sentAt?.toIso8601String(),
      'fcm_message_id': fcmMessageId,
      'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory LectureNotificationModel.fromEntity(LectureNotification entity) {
    return LectureNotificationModel(
      id: entity.id,
      lectureId: entity.lectureId,
      templateId: entity.templateId,
      scheduledFor: entity.scheduledFor,
      notificationType: entity.notificationType,
      isSent: entity.isSent,
      sentAt: entity.sentAt,
      fcmMessageId: entity.fcmMessageId,
      errorMessage: entity.errorMessage,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  LectureNotification toEntity() => this;
}
