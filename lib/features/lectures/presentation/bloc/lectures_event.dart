part of 'lectures_bloc.dart';

// ============================================================
// BASE EVENT
// ============================================================
sealed class LecturesEvent {}

// ============================================================
// LECTURE REQUEST EVENTS
// ============================================================
class GetLectureRequestsEvent extends LecturesEvent {
  final String? parentUid;
  final String? status;

  GetLectureRequestsEvent({this.parentUid, this.status});
}

class CreateLectureRequestEvent extends LecturesEvent {
  final String parentUid;
  final String studentUid;
  final List<String> subjects;
  final List<TimeSlot> preferredTimeSlots;
  final String? additionalNotes;
  final DateTime? requestedStartDate;
  final String frequency;
  final int priorityLevel;

  CreateLectureRequestEvent({
    required this.parentUid,
    required this.studentUid,
    required this.subjects,
    required this.preferredTimeSlots,
    this.additionalNotes,
    this.requestedStartDate,
    this.frequency = 'weekly',
    this.priorityLevel = 1,
  });
}

class CancelLectureRequestEvent extends LecturesEvent {
  final String requestId;

  CancelLectureRequestEvent(this.requestId);
}

// ============================================================
// TEACHER-STUDENT ASSIGNMENT EVENTS
// ============================================================
class GetTeacherAssignmentsEvent extends LecturesEvent {
  final String teacherUid;
  final String? assignmentStatus;

  GetTeacherAssignmentsEvent({
    required this.teacherUid,
    this.assignmentStatus,
  });
}

class GetStudentAssignmentsEvent extends LecturesEvent {
  final String studentUid;

  GetStudentAssignmentsEvent(this.studentUid);
}

// ============================================================
// LECTURE EVENTS
// ============================================================
class GetLecturesEvent extends LecturesEvent {
  final String? teacherUid;
  final String? studentUid;
  final String? status;
  final DateTime? fromDate;
  final DateTime? toDate;

  GetLecturesEvent({
    this.teacherUid,
    this.studentUid,
    this.status,
    this.fromDate,
    this.toDate,
  });
}

class CreateOneTimeLectureEvent extends LecturesEvent {
  final String assignmentId;
  final String teacherUid;
  final String studentUid;
  final String subject;
  final DateTime scheduledDate;
  final TimeSlot scheduledTime;
  final String? notes;
  final String? meetingLink;

  CreateOneTimeLectureEvent({
    required this.assignmentId,
    required this.teacherUid,
    required this.studentUid,
    required this.subject,
    required this.scheduledDate,
    required this.scheduledTime,
    this.notes,
    this.meetingLink,
  });
}

class CreateRecurringLectureTemplateEvent extends LecturesEvent {
  final String assignmentId;
  final String teacherUid;
  final String studentUid;
  final String subject;
  final DateTime startDate;
  final DateTime endDate;
  final TimeSlot timeSlot;
  final String recurrencePattern;
  final List<String> recurrenceDays;
  final String? notes;
  final String? meetingLink;

  CreateRecurringLectureTemplateEvent({
    required this.assignmentId,
    required this.teacherUid,
    required this.studentUid,
    required this.subject,
    required this.startDate,
    required this.endDate,
    required this.timeSlot,
    required this.recurrencePattern,
    required this.recurrenceDays,
    this.notes,
    this.meetingLink,
  });
}

class RescheduleLectureEvent extends LecturesEvent {
  final String lectureId;
  final DateTime newDate;
  final TimeSlot newTime;
  final String? reason;

  RescheduleLectureEvent({
    required this.lectureId,
    required this.newDate,
    required this.newTime,
    this.reason,
  });
}

class CancelLectureEvent extends LecturesEvent {
  final String lectureId;
  final String? reason;

  CancelLectureEvent({
    required this.lectureId,
    this.reason,
  });
}

class UpdateLectureStatusEvent extends LecturesEvent {
  final String lectureId;
  final String status;
  final String? notes;

  UpdateLectureStatusEvent({
    required this.lectureId,
    required this.status,
    this.notes,
  });
}

class MarkAttendanceEvent extends LecturesEvent {
  final String lectureId;
  final bool attended;
  final String? notes;

  MarkAttendanceEvent({
    required this.lectureId,
    required this.attended,
    this.notes,
  });
}

class GetUpcomingLecturesEvent extends LecturesEvent {
  final String? teacherUid;
  final String? studentUid;
  final int daysAhead;

  GetUpcomingLecturesEvent({
    this.teacherUid,
    this.studentUid,
    this.daysAhead = 7,
  });
}

class GetLectureSeriesEvent extends LecturesEvent {
  final String seriesId;

  GetLectureSeriesEvent(this.seriesId);
}

// ============================================================
// RECURRING LECTURE TEMPLATE EVENTS (Alarm-Clock Pattern)
// ============================================================
class GetTemplatesEvent extends LecturesEvent {
  final String? teacherUid;
  final String? studentUid;
  final bool? isActive;

  GetTemplatesEvent({
    this.teacherUid,
    this.studentUid,
    this.isActive,
  });
}

class UpdateTemplateEvent extends LecturesEvent {
  final String templateId;
  final DateTime? startDate;
  final DateTime? endDate;
  final TimeSlot? scheduledTime;
  final List<String>? recurrenceDays;
  final bool? isActive;
  final bool? notificationEnabled;
  final int? notificationMinutesBefore;
  final String? notes;
  final String? meetingLink;

  UpdateTemplateEvent({
    required this.templateId,
    this.startDate,
    this.endDate,
    this.scheduledTime,
    this.recurrenceDays,
    this.isActive,
    this.notificationEnabled,
    this.notificationMinutesBefore,
    this.notes,
    this.meetingLink,
  });
}

class DeleteTemplateEvent extends LecturesEvent {
  final String templateId;

  DeleteTemplateEvent(this.templateId);
}

class MaterializeLectureEvent extends LecturesEvent {
  final String virtualLectureId;
  final String templateId;
  final DateTime scheduledDate;
  final TimeSlot scheduledTime;
  final String? reason;

  MaterializeLectureEvent({
    required this.virtualLectureId,
    required this.templateId,
    required this.scheduledDate,
    required this.scheduledTime,
    this.reason,
  });
}

// ============================================================
// LECTURE NOTIFICATION EVENTS
// ============================================================
class ScheduleLectureNotificationEvent extends LecturesEvent {
  final String? lectureId;
  final String? templateId;
  final DateTime scheduledFor;
  final String notificationType;

  ScheduleLectureNotificationEvent({
    this.lectureId,
    this.templateId,
    required this.scheduledFor,
    required this.notificationType,
  });
}

class GetLectureNotificationsEvent extends LecturesEvent {
  final String? lectureId;
  final String? templateId;
  final bool? isSent;
  final DateTime? fromDate;
  final DateTime? toDate;

  GetLectureNotificationsEvent({
    this.lectureId,
    this.templateId,
    this.isSent,
    this.fromDate,
    this.toDate,
  });
}

// ============================================================
// TEACHER AVAILABILITY EVENTS
// ============================================================
class GetTeacherAvailabilityEvent extends LecturesEvent {
  final String teacherUid;

  GetTeacherAvailabilityEvent(this.teacherUid);
}

class UpdateTeacherAvailabilityEvent extends LecturesEvent {
  final String teacherUid;
  final List<String> availableDays;
  final List<TimeSlot> timeSlots;
  final List<String> subjectsOffered;

  UpdateTeacherAvailabilityEvent({
    required this.teacherUid,
    required this.availableDays,
    required this.timeSlots,
    required this.subjectsOffered,
  });
}
