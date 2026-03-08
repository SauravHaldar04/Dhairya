import 'time_slot_entity.dart';

class RecurringLectureTemplate {
  final String id;
  final String assignmentId;
  final String teacherUid;
  final String studentId;
  final String subject;
  
  // Recurrence Configuration
  final String recurrencePattern; // 'daily' or 'weekly'
  final List<String> recurrenceDays; // For weekly: ['monday', 'wednesday', 'friday']
  final DateTime startDate;
  final DateTime? endDate; // null means indefinite
  
  // Default Time and Settings
  final TimeSlot scheduledTime;
  final String? notes;
  final String? meetingLink;
  
  // Notification settings
  final bool notificationEnabled;
  final int notificationMinutesBefore; // e.g., 10 for 10 minutes before
  
  // Status
  final bool isActive;
  final String seriesId;
  
  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringLectureTemplate({
    required this.id,
    required this.assignmentId,
    required this.teacherUid,
    required this.studentId,
    required this.subject,
    required this.recurrencePattern,
    required this.recurrenceDays,
    required this.startDate,
    this.endDate,
    required this.scheduledTime,
    this.notes,
    this.meetingLink,
    this.notificationEnabled = true,
    this.notificationMinutesBefore = 10,
    this.isActive = true,
    required this.seriesId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper: Check if this template should generate a lecture on a given date
  bool shouldOccurOn(DateTime date) {
    // Check if date is before start or after end
    if (date.isBefore(startDate)) return false;
    if (endDate != null && date.isAfter(endDate!)) return false;
    if (!isActive) return false;
    
    // Check recurrence pattern
    if (recurrencePattern == 'daily') return true;
    
    if (recurrencePattern == 'weekly') {
      final dayName = _getDayName(date.weekday);
      return recurrenceDays.contains(dayName.toLowerCase());
    }
    
    return false;
  }
  
  String _getDayName(int weekday) {
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[weekday - 1];
  }

  RecurringLectureTemplate copyWith({
    String? id,
    String? assignmentId,
    String? teacherUid,
    String? studentId,
    String? subject,
    String? recurrencePattern,
    List<String>? recurrenceDays,
    DateTime? startDate,
    DateTime? endDate,
    TimeSlot? scheduledTime,
    String? notes,
    String? meetingLink,
    bool? notificationEnabled,
    int? notificationMinutesBefore,
    bool? isActive,
    String? seriesId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringLectureTemplate(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      teacherUid: teacherUid ?? this.teacherUid,
      studentId: studentId ?? this.studentId,
      subject: subject ?? this.subject,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      recurrenceDays: recurrenceDays ?? this.recurrenceDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      notes: notes ?? this.notes,
      meetingLink: meetingLink ?? this.meetingLink,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationMinutesBefore: notificationMinutesBefore ?? this.notificationMinutesBefore,
      isActive: isActive ?? this.isActive,
      seriesId: seriesId ?? this.seriesId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecurringLectureTemplate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RecurringLectureTemplate(id: $id, subject: $subject, pattern: $recurrencePattern, days: $recurrenceDays, active: $isActive)';
  }
}
