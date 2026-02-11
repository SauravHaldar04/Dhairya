import 'package:fpdart/fpdart.dart';
import '../entities/lecture_request_entity.dart';
import '../entities/lecture_entity.dart';
import '../entities/teacher_availability_entity.dart';
import '../entities/teacher_student_assignment_entity.dart';
import '../entities/time_slot_entity.dart';
import '../../../../core/error/server_exception.dart';

abstract interface class LecturesRepository {
  // ============================================================
  // LECTURE REQUESTS (Parents)
  // ============================================================
  
  /// Get lecture requests for a parent or filtered by status
  Future<Either<ServerException, List<LectureRequest>>> getLectureRequests({
    String? parentUid, 
    String? status
  });
  
  /// Create a new lecture request (parent initiates)
  Future<Either<ServerException, String>> createLectureRequest({
    required String parentUid,
    required String studentUid,
    required List<String> subjects,
    required List<TimeSlot> preferredTimeSlots,
    String? additionalNotes,
    DateTime? requestedStartDate,
    String frequency = 'weekly',
    int priorityLevel = 1,
  });
  
  /// Cancel a pending lecture request (only if status is 'pending')
  Future<Either<ServerException, void>> cancelLectureRequest(String requestId);
  
  // ============================================================
  // TEACHER-STUDENT ASSIGNMENTS (Teachers view, Admin creates)
  // Admin creates these in separate admin dashboard
  // ============================================================
  
  /// Get assignments for a teacher (shows which students are assigned to them)
  Future<Either<ServerException, List<TeacherStudentAssignment>>> getTeacherAssignments({
    required String teacherUid,
    String? assignmentStatus, // active, paused, completed, cancelled
  });
  
  /// Get assignments for a student (shows which teacher is teaching them)
  Future<Either<ServerException, List<TeacherStudentAssignment>>> getStudentAssignments({
    required String studentUid,
  });
  
  // ============================================================
  // LECTURES (Teachers create and manage)
  // ============================================================
  
  /// Get lectures for teacher or student, optionally filtered by status
  Future<Either<ServerException, List<Lecture>>> getLectures({
    String? teacherUid, 
    String? studentUid, 
    String? status,
    DateTime? fromDate, // Filter lectures from this date
    DateTime? toDate,   // Filter lectures to this date
  });
  
  /// Create a single one-time lecture (teacher creates)
  Future<Either<ServerException, String>> createOneTimeLecture({
    required String assignmentId,
    required String teacherUid,
    required String studentUid,
    required String subject,
    required DateTime scheduledDate,
    required TimeSlot scheduledTime,
    String? notes,
    String? meetingLink,
  });
  
  /// Create recurring lectures (daily or weekly pattern)
  Future<Either<ServerException, List<String>>> createRecurringLectures({
    required String assignmentId,
    required String teacherUid,
    required String studentUid,
    required String subject,
    required DateTime startDate,
    required DateTime endDate,
    required TimeSlot timeSlot,
    required String recurrencePattern, // 'daily' or 'weekly'
    List<String>? recurrenceDays, // For weekly: ['monday', 'wednesday', 'friday']
    String? notes,
    String? meetingLink,
  });
  
  /// Reschedule a lecture to a new date/time
  Future<Either<ServerException, void>> rescheduleLecture({
    required String lectureId,
    required DateTime newDate,
    required TimeSlot newTime,
    String? reason,
  });
  
  /// Cancel a lecture
  Future<Either<ServerException, void>> cancelLecture({
    required String lectureId,
    String? reason,
  });
  
  /// Update lecture status (in_progress, completed, etc.)
  Future<Either<ServerException, void>> updateLectureStatus(
    String lectureId, 
    String status, {
    String? notes,
  });
  
  /// Mark attendance for a lecture
  Future<Either<ServerException, void>> markAttendance({
    required String lectureId,
    required bool attended,
    String? notes,
  });
  
  /// Get upcoming lectures for teacher or student
  Future<Either<ServerException, List<Lecture>>> getUpcomingLectures({
    String? teacherUid,
    String? studentUid,
    int daysAhead = 7, // Get lectures for next 7 days
  });
  
  /// Get lecture series (all lectures in a recurring series)
  Future<Either<ServerException, List<Lecture>>> getLectureSeries(String seriesId);
  
  // ============================================================
  // TEACHER AVAILABILITY
  // ============================================================
  
  /// Get teacher's availability
  Future<Either<ServerException, TeacherAvailability?>> getTeacherAvailability(
    String teacherUid
  );
  
  /// Update teacher's availability (teacher manages their own)
  Future<Either<ServerException, void>> updateTeacherAvailability({
    required String teacherUid,
    required List<String> availableDays,
    required List<TimeSlot> timeSlots,
    required List<String> subjectsOffered,
  });
}