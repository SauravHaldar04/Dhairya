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

class RecurringLecturesCreated extends LecturesState {
  final List<String> lectureIds;
  RecurringLecturesCreated(this.lectureIds);
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
// TEACHER AVAILABILITY STATES
// ============================================================
class TeacherAvailabilityLoaded extends LecturesState {
  final TeacherAvailability? availability;
  TeacherAvailabilityLoaded(this.availability);
}

class TeacherAvailabilityUpdated extends LecturesState {}
