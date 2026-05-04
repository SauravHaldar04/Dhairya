import '../../domain/entities/user_notification_entity.dart';

class UserNotificationModel extends UserNotificationEntity {
  const UserNotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.message,
    required super.notificationType,
    super.relatedLectureRequestId,
    super.relatedAssignmentId,
    required super.isRead,
    required super.createdAt,
    super.readAt,
  });

  factory UserNotificationModel.fromJson(Map<String, dynamic> json) {
    return UserNotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      notificationType: json['notification_type'] as String,
      relatedLectureRequestId: json['related_lecture_request_id'] as String?,
      relatedAssignmentId: json['related_assignment_id'] as String?,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };

    if (relatedLectureRequestId != null) {
      map['related_lecture_request_id'] = relatedLectureRequestId;
    }
    if (relatedAssignmentId != null) {
      map['related_assignment_id'] = relatedAssignmentId;
    }
    if (readAt != null) {
      map['read_at'] = readAt!.toIso8601String();
    }

    return map;
  }

  UserNotificationEntity toEntity() {
    return UserNotificationEntity(
      id: id,
      userId: userId,
      title: title,
      message: message,
      notificationType: notificationType,
      relatedLectureRequestId: relatedLectureRequestId,
      relatedAssignmentId: relatedAssignmentId,
      isRead: isRead,
      createdAt: createdAt,
      readAt: readAt,
    );
  }
}
