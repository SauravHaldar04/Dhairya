import '../../domain/entities/time_slot_entity.dart';
import '../../domain/entities/lecture_entity.dart';

class LectureModel extends Lecture {
  const LectureModel({
    required super.id,
    required super.assignmentId,
    required super.teacherUid,
    required super.studentUid,
    required super.subject,
    required super.scheduledDate,
    required super.scheduledTime,
    super.isRecurring = false,
    super.seriesId,
    super.recurrencePattern = 'one-time',
    super.recurrenceDays,
    super.recurrenceEndDate,
    required super.status,
    super.originalDate,
    super.originalTime,
    super.rescheduledReason,
    super.notes,
    super.meetingLink,
    super.attendanceMarked = false,
    required super.createdAt,
    required super.updatedAt,
  });

  factory LectureModel.fromMap(Map<String, dynamic> map) {
    return LectureModel(
      id: map['id'] as String,
      assignmentId: map['assignment_id'] as String,
      teacherUid: map['teacher_uid'] as String,
      studentUid: map['student_uid'] as String,
      subject: map['subject'] as String,
      scheduledDate: DateTime.parse(map['scheduled_date'] as String),
      scheduledTime: TimeSlot.fromMap(map['scheduled_time'] as Map<String, dynamic>),
      isRecurring: map['is_recurring'] as bool? ?? false,
      seriesId: map['series_id'] as String?,
      recurrencePattern: map['recurrence_pattern'] as String? ?? 'one-time',
      recurrenceDays: map['recurrence_days'] != null 
          ? List<String>.from(map['recurrence_days'] as List) 
          : null,
      recurrenceEndDate: map['recurrence_end_date'] != null 
          ? DateTime.parse(map['recurrence_end_date'] as String) 
          : null,
      status: map['status'] as String? ?? 'scheduled',
      originalDate: map['original_date'] != null 
          ? DateTime.parse(map['original_date'] as String) 
          : null,
      originalTime: map['original_time'] != null 
          ? TimeSlot.fromMap(map['original_time'] as Map<String, dynamic>) 
          : null,
      rescheduledReason: map['rescheduled_reason'] as String?,
      notes: map['notes'] as String?,
      meetingLink: map['meeting_link'] as String?,
      attendanceMarked: map['attendance_marked'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'teacher_uid': teacherUid,
      'student_uid': studentUid,
      'subject': subject,
      'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
      'scheduled_time': scheduledTime.toMap(),
      'is_recurring': isRecurring,
      'series_id': seriesId,
      'recurrence_pattern': recurrencePattern,
      'recurrence_days': recurrenceDays,
      'recurrence_end_date': recurrenceEndDate?.toIso8601String().split('T')[0],
      'status': status,
      'original_date': originalDate?.toIso8601String().split('T')[0],
      'original_time': originalTime?.toMap(),
      'rescheduled_reason': rescheduledReason,
      'notes': notes,
      'meeting_link': meetingLink,
      'attendance_marked': attendanceMarked,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory LectureModel.fromEntity(Lecture entity) {
    return LectureModel(
      id: entity.id,
      assignmentId: entity.assignmentId,
      teacherUid: entity.teacherUid,
      studentUid: entity.studentUid,
      subject: entity.subject,
      scheduledDate: entity.scheduledDate,
      scheduledTime: entity.scheduledTime,
      isRecurring: entity.isRecurring,
      seriesId: entity.seriesId,
      recurrencePattern: entity.recurrencePattern,
      recurrenceDays: entity.recurrenceDays,
      recurrenceEndDate: entity.recurrenceEndDate,
      status: entity.status,
      originalDate: entity.originalDate,
      originalTime: entity.originalTime,
      rescheduledReason: entity.rescheduledReason,
      notes: entity.notes,
      meetingLink: entity.meetingLink,
      attendanceMarked: entity.attendanceMarked,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Lecture toEntity() => this;
}
