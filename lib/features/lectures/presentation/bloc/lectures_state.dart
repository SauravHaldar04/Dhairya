part of 'lectures_bloc.dart';

// ============================================================
// BASE STATE
// ============================================================
sealed class LecturesState {}

class LecturesInitial extends LecturesState {}

class LecturesLoading extends LecturesState {}

class LecturesError extends LecturesState {
  final String message;
  LecturesError(this.message);
}

// ============================================================
// LECTURE REQUEST STATES
// ============================================================
class LectureRequestsLoaded extends LecturesState {
  final List<LectureRequest> requests;
  LectureRequestsLoaded(this.requests);
}

class LectureRequestCreated extends LecturesState {
  final String requestId;
  LectureRequestCreated(this.requestId);
}

class LectureRequestCancelled extends LecturesState {}

// ============================================================
// TEACHER-STUDENT ASSIGNMENT STATES
// ============================================================
class TeacherAssignmentsLoaded extends LecturesState {
  final List<TeacherStudentAssignment> assignments;
  TeacherAssignmentsLoaded(this.assignments);
}

class StudentAssignmentsLoaded extends LecturesState {
  final List<TeacherStudentAssignment> assignments;
  StudentAssignmentsLoaded(this.assignments);
}

// ============================================================
// LECTURE STATES
// ============================================================
class LecturesLoaded extends LecturesState {
  final List<Lecture> lectures;
  LecturesLoaded(this.lectures);
}

class LectureCreated extends LecturesState {
  final String lectureId;
  LectureCreated(this.lectureId);
}

class RecurringLectureTemplateCreated extends LecturesState {
  final String templateId;
  RecurringLectureTemplateCreated(this.templateId);
}

class LectureRescheduled extends LecturesState {}

class LectureCancelled extends LecturesState {}

class LectureStatusUpdated extends LecturesState {}

class AttendanceMarked extends LecturesState {}

class UpcomingLecturesLoaded extends LecturesState {
  final List<Lecture> lectures;
  UpcomingLecturesLoaded(this.lectures);
}

class LectureSeriesLoaded extends LecturesState {
  final List<Lecture> lectures;
  LectureSeriesLoaded(this.lectures);
}

// ============================================================
// RECURRING LECTURE TEMPLATE STATES (Alarm-Clock Pattern)
// ============================================================
class TemplatesLoaded extends LecturesState {
  final List<RecurringLectureTemplate> templates;
  TemplatesLoaded(this.templates);
}

class TemplateUpdated extends LecturesState {}

class TemplateDeleted extends LecturesState {}

class LectureMaterialized extends LecturesState {
  final String lectureId;
  LectureMaterialized(this.lectureId);
}

// ============================================================
// LECTURE NOTIFICATION STATES
// ============================================================
class NotificationScheduled extends LecturesState {
  final String notificationId;
  NotificationScheduled(this.notificationId);
}

class NotificationsLoaded extends LecturesState {
  final List<LectureNotification> notifications;
  NotificationsLoaded(this.notifications);
}

// ============================================================
// TEACHER AVAILABILITY STATES
// ============================================================
class TeacherAvailabilityLoaded extends LecturesState {
  final TeacherAvailability? availability;
  TeacherAvailabilityLoaded(this.availability);
}

class TeacherAvailabilityUpdated extends LecturesState {}
