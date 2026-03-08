import 'time_slot_entity.dart';

class Lecture {
  final String id;
  final String assignmentId; // Links to teacher_student_assignment
  final String teacherUid;
  final String studentUid;
  final String subject;
  
  // Scheduling
  final DateTime scheduledDate;
  final TimeSlot scheduledTime;
  
  // Template relationship (for recurring lectures)
  final String? templateId; // Links to recurring_lecture_templates (null = one-time lecture)
  final bool isMaterialized; // true = stored in DB, false = virtual (calculated from template)
  
  // Recurrence (for recurring lectures created by teacher)
  final bool isRecurring;
  final String? seriesId; // Groups recurring lectures together
  final String recurrencePattern; // one-time, daily, weekly
  final List<String>? recurrenceDays; // For weekly: [monday, wednesday, friday]
  final DateTime? recurrenceEndDate;
  
  // Status
  final String status; // scheduled, in_progress, completed, cancelled, rescheduled
  
  // Rescheduling
  final DateTime? originalDate;
  final TimeSlot? originalTime;
  final String? rescheduledReason;
  
  // Additional
  final String? notes;
  final String? meetingLink;
  final bool attendanceMarked;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Student details (from join)
  final String? studentFirstName;
  final String? studentMiddleName;
  final String? studentLastName;
  final String? studentStandard;

  const Lecture({
    required this.id,
    required this.assignmentId,
    required this.teacherUid,
    required this.studentUid,
    required this.subject,
    required this.scheduledDate,
    required this.scheduledTime,
    this.templateId,
    this.isMaterialized = true,
    this.isRecurring = false,
    this.seriesId,
    this.recurrencePattern = 'one-time',
    this.recurrenceDays,
    this.recurrenceEndDate,
    required this.status,
    this.originalDate,
    this.originalTime,
    this.rescheduledReason,
    this.notes,
    this.meetingLink,
    this.attendanceMarked = false,
    required this.createdAt,
    required this.updatedAt,
    this.studentFirstName,
    this.studentMiddleName,
    this.studentLastName,
    this.studentStandard,
  });
  
  String get studentFullName {
    if (studentFirstName == null) return 'Unknown Student';
    return [studentFirstName, studentMiddleName, studentLastName]
        .where((n) => n != null && n.isNotEmpty)
        .join(' ');
  }

  Lecture copyWith({
    String? id,
    String? assignmentId,
    String? teacherUid,
    String? studentUid,
    String? subject,
    DateTime? scheduledDate,
    TimeSlot? scheduledTime,
    String? templateId,
    bool? isMaterialized,
    bool? isRecurring,
    String? seriesId,
    String? recurrencePattern,
    List<String>? recurrenceDays,
    DateTime? recurrenceEndDate,
    String? status,
    DateTime? originalDate,
    TimeSlot? originalTime,
    String? rescheduledReason,
    String? notes,
    String? meetingLink,
    bool? attendanceMarked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lecture(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      teacherUid: teacherUid ?? this.teacherUid,
      studentUid: studentUid ?? this.studentUid,
      subject: subject ?? this.subject,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      templateId: templateId ?? this.templateId,
      isMaterialized: isMaterialized ?? this.isMaterialized,
      isRecurring: isRecurring ?? this.isRecurring,
      seriesId: seriesId ?? this.seriesId,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      recurrenceDays: recurrenceDays ?? this.recurrenceDays,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      status: status ?? this.status,
      originalDate: originalDate ?? this.originalDate,
      originalTime: originalTime ?? this.originalTime,
      rescheduledReason: rescheduledReason ?? this.rescheduledReason,
      notes: notes ?? this.notes,
      meetingLink: meetingLink ?? this.meetingLink,
      attendanceMarked: attendanceMarked ?? this.attendanceMarked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Lecture && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}