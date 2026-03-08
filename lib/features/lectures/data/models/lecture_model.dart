import '../../domain/entities/time_slot_entity.dart';
import '../../domain/entities/lecture_entity.dart';
import '../../domain/entities/recurring_lecture_template_entity.dart';

class LectureModel extends Lecture {
  const LectureModel({
    required super.id,
    required super.assignmentId,
    required super.teacherUid,
    required super.studentUid,
    required super.subject,
    required super.scheduledDate,
    required super.scheduledTime,
    super.templateId,
    super.isMaterialized = true,
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
    super.studentFirstName,
    super.studentMiddleName,
    super.studentLastName,
    super.studentStandard,
  });

  factory LectureModel.fromMap(Map<String, dynamic> map) {
    // Parse student data if present (from join)
    final studentData = map['students'] as Map<String, dynamic>?;
    
    return LectureModel(
      id: map['id'] as String,
      assignmentId: map['assignment_id'] as String,
      teacherUid: map['teacher_uid'] as String,
      studentUid: map['student_id'] as String,
      subject: map['subject'] as String,
      scheduledDate: DateTime.parse(map['scheduled_date'] as String),
      scheduledTime: TimeSlot.fromMap(map['scheduled_time'] as Map<String, dynamic>),
      templateId: map['template_id'] as String?,
      isMaterialized: map['is_materialized'] as bool? ?? true,
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
      studentFirstName: studentData?['first_name'] as String?,
      studentMiddleName: studentData?['middle_name'] as String?,
      studentLastName: studentData?['last_name'] as String?,
      studentStandard: studentData?['standard'] as String?,
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
      'template_id': templateId,
      'is_materialized': isMaterialized,
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
      templateId: entity.templateId,
      isMaterialized: entity.isMaterialized,
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

  /// Creates a virtual lecture instance from a template and scheduled date
  /// Used by LectureOccurrenceCalculator
  factory LectureModel.fromTemplate(
    RecurringLectureTemplate template,
    DateTime scheduledDate,
  ) {
    // Generate deterministic ID for virtual instance
    final dateStr = scheduledDate.toIso8601String().split('T')[0];
    final virtualId = '${template.id}_$dateStr';

    return LectureModel(
      id: virtualId,
      assignmentId: template.assignmentId,
      teacherUid: template.teacherUid,
      studentUid: template.studentId,
      subject: template.subject,
      scheduledDate: scheduledDate,
      scheduledTime: template.scheduledTime,
      templateId: template.id,
      isMaterialized: false, // Virtual instance
      isRecurring: true,
      seriesId: template.seriesId,
      recurrencePattern: template.recurrencePattern,
      recurrenceDays: template.recurrenceDays,
      recurrenceEndDate: template.endDate,
      status: 'scheduled',
      notes: template.notes,
      meetingLink: template.meetingLink,
      attendanceMarked: false,
      createdAt: template.createdAt,
      updatedAt: template.updatedAt,
    );
  }

  Lecture toEntity() => this;
}
