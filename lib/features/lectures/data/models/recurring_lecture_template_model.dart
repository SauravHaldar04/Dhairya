import '../../domain/entities/recurring_lecture_template_entity.dart';
import '../../domain/entities/time_slot_entity.dart';

class RecurringLectureTemplateModel extends RecurringLectureTemplate {
  const RecurringLectureTemplateModel({
    required super.id,
    required super.assignmentId,
    required super.teacherUid,
    required super.studentId,
    required super.subject,
    required super.recurrencePattern,
    required super.recurrenceDays,
    required super.startDate,
    super.endDate,
    required super.scheduledTime,
    super.notes,
    super.meetingLink,
    super.jitsiRoomName,
    super.jitsiMeetingUrl,
    super.notificationEnabled = true,
    super.notificationMinutesBefore = 10,
    super.isActive = true,
    required super.seriesId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory RecurringLectureTemplateModel.fromMap(Map<String, dynamic> map) {
    return RecurringLectureTemplateModel(
      id: map['id'] as String,
      assignmentId: map['assignment_id'] as String,
      teacherUid: map['teacher_uid'] as String,
      studentId: map['student_id'] as String,
      subject: map['subject'] as String,
      recurrencePattern: map['recurrence_pattern'] as String,
      recurrenceDays: List<String>.from(map['recurrence_days'] as List),
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String) : null,
      scheduledTime: TimeSlot.fromMap(map['scheduled_time'] as Map<String, dynamic>),
      notes: map['notes'] as String?,
      meetingLink: map['meeting_link'] as String?,
      jitsiRoomName: map['jitsi_room_name'] as String?,
      jitsiMeetingUrl: map['jitsi_meeting_url'] as String?,
      notificationEnabled: map['notification_enabled'] as bool? ?? true,
      notificationMinutesBefore: map['notification_minutes_before'] as int? ?? 10,
      isActive: map['is_active'] as bool? ?? true,
      seriesId: map['series_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'teacher_uid': teacherUid,
      'student_id': studentId,
      'subject': subject,
      'recurrence_pattern': recurrencePattern,
      'recurrence_days': recurrenceDays,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'scheduled_time': scheduledTime.toMap(),
      'notes': notes,
      'meeting_link': meetingLink,
      'jitsi_room_name': jitsiRoomName,
      'jitsi_meeting_url': jitsiMeetingUrl,
      'notification_enabled': notificationEnabled,
      'notification_minutes_before': notificationMinutesBefore,
      'is_active': isActive,
      'series_id': seriesId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory RecurringLectureTemplateModel.fromEntity(RecurringLectureTemplate entity) {
    return RecurringLectureTemplateModel(
      id: entity.id,
      assignmentId: entity.assignmentId,
      teacherUid: entity.teacherUid,
      studentId: entity.studentId,
      subject: entity.subject,
      recurrencePattern: entity.recurrencePattern,
      recurrenceDays: entity.recurrenceDays,
      startDate: entity.startDate,
      endDate: entity.endDate,
      scheduledTime: entity.scheduledTime,
      notes: entity.notes,
      meetingLink: entity.meetingLink,
      jitsiRoomName: entity.jitsiRoomName,
      jitsiMeetingUrl: entity.jitsiMeetingUrl,
      notificationEnabled: entity.notificationEnabled,
      notificationMinutesBefore: entity.notificationMinutesBefore,
      isActive: entity.isActive,
      seriesId: entity.seriesId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  RecurringLectureTemplate toEntity() => this;
}
