import 'package:fpdart/fpdart.dart';
import '../../../../core/error/server_exception.dart';
import '../../../../core/network/check_internet_connection.dart';
import '../../domain/entities/lecture_request_entity.dart';
import '../../domain/entities/lecture_entity.dart';
import '../../domain/entities/teacher_availability_entity.dart';
import '../../domain/entities/teacher_student_assignment_entity.dart';
import '../../domain/entities/time_slot_entity.dart';
import '../../domain/repositories/lectures_repository.dart';
import '../datasources/lectures_remote_datasource.dart';

class LecturesRepositoryImpl implements LecturesRepository {
  final LecturesRemoteDataSource remoteDataSource;
  final CheckInternetConnection checkInternetConnection;

  const LecturesRepositoryImpl(
    this.remoteDataSource,
    this.checkInternetConnection,
  );

  @override
  Future<Either<ServerException, List<LectureRequest>>> getLectureRequests({
    String? parentUid,
    String? status,
  }) async {
    return _handleRequest(() async {
      final models = await remoteDataSource.getLectureRequests(
        parentUid: parentUid,
        status: status,
      );
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<ServerException, String>> createLectureRequest({
    required String parentUid,
    required String studentUid,
    required List<String> subjects,
    required List<TimeSlot> preferredTimeSlots,
    String? additionalNotes,
    DateTime? requestedStartDate,
    String frequency = 'weekly',
    int priorityLevel = 1,
  }) async {
    return _handleRequest(() => remoteDataSource.createLectureRequest(
          parentUid: parentUid,
          studentUid: studentUid,
          subjects: subjects,
          preferredTimeSlots: preferredTimeSlots,
          additionalNotes: additionalNotes,
          requestedStartDate: requestedStartDate,
          frequency: frequency,
          priorityLevel: priorityLevel,
        ));
  }

  @override
  Future<Either<ServerException, void>> cancelLectureRequest(String requestId) async {
    return _handleRequest(() => remoteDataSource.cancelLectureRequest(requestId));
  }

  @override
  Future<Either<ServerException, List<TeacherStudentAssignment>>> getTeacherAssignments({
    required String teacherUid,
    String? assignmentStatus,
  }) async {
    return _handleRequest(() async {
      final models = await remoteDataSource.getTeacherAssignments(
        teacherUid: teacherUid,
        assignmentStatus: assignmentStatus,
      );
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<ServerException, List<TeacherStudentAssignment>>> getStudentAssignments({
    required String studentUid,
  }) async {
    return _handleRequest(() async {
      final models = await remoteDataSource.getStudentAssignments(
        studentUid: studentUid,
      );
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<ServerException, List<Lecture>>> getLectures({
    String? teacherUid,
    String? studentUid,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return _handleRequest(() async {
      final models = await remoteDataSource.getLectures(
        teacherUid: teacherUid,
        studentUid: studentUid,
        status: status,
        fromDate: fromDate,
        toDate: toDate,
      );
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<ServerException, String>> createOneTimeLecture({
    required String assignmentId,
    required String teacherUid,
    required String studentUid,
    required String subject,
    required DateTime scheduledDate,
    required TimeSlot scheduledTime,
    String? notes,
    String? meetingLink,
  }) async {
    return _handleRequest(() => remoteDataSource.createOneTimeLecture(
          assignmentId: assignmentId,
          teacherUid: teacherUid,
          studentUid: studentUid,
          subject: subject,
          scheduledDate: scheduledDate,
          scheduledTime: scheduledTime,
          notes: notes,
          meetingLink: meetingLink,
        ));
  }

  @override
  Future<Either<ServerException, String>> createRecurringLectureTemplate({
    required String assignmentId,
    required String teacherUid,
    required String studentUid,
    required String subject,
    required DateTime startDate,
    required DateTime endDate,
    required TimeSlot timeSlot,
    required String recurrencePattern,
    required List<String> recurrenceDays,
    String? notes,
    String? meetingLink,
  }) async {
    return _handleRequest(() => remoteDataSource.createRecurringLectureTemplate(
          assignmentId: assignmentId,
          teacherUid: teacherUid,
          studentUid: studentUid,
          subject: subject,
          startDate: startDate,
          endDate: endDate,
          timeSlot: timeSlot,
          recurrencePattern: recurrencePattern,
          recurrenceDays: recurrenceDays,
          notes: notes,
          meetingLink: meetingLink,
        ));
  }

  @override
  Future<Either<ServerException, void>> rescheduleLecture({
    required String lectureId,
    required DateTime newDate,
    required TimeSlot newTime,
    String? reason,
  }) async {
    return _handleRequest(() => remoteDataSource.rescheduleLecture(
          lectureId: lectureId,
          newDate: newDate,
          newTime: newTime,
          reason: reason,
        ));
  }

  @override
  Future<Either<ServerException, void>> cancelLecture({
    required String lectureId,
    String? reason,
  }) async {
    return _handleRequest(() => remoteDataSource.cancelLecture(
          lectureId: lectureId,
          reason: reason,
        ));
  }

  @override
  Future<Either<ServerException, void>> updateLectureStatus(
    String lectureId,
    String status, {
    String? notes,
  }) async {
    return _handleRequest(() => remoteDataSource.updateLectureStatus(
          lectureId,
          status,
          notes: notes,
        ));
  }

  @override
  Future<Either<ServerException, void>> markAttendance({
    required String lectureId,
    required bool attended,
    String? notes,
  }) async {
    return _handleRequest(() => remoteDataSource.markAttendance(
          lectureId: lectureId,
          attended: attended,
          notes: notes,
        ));
  }

  @override
  Future<Either<ServerException, List<Lecture>>> getUpcomingLectures({
    String? teacherUid,
    String? studentUid,
    int daysAhead = 7,
  }) async {
    return _handleRequest(() async {
      final models = await remoteDataSource.getUpcomingLectures(
        teacherUid: teacherUid,
        studentUid: studentUid,
        daysAhead: daysAhead,
      );
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<ServerException, List<Lecture>>> getLectureSeries(String seriesId) async {
    return _handleRequest(() async {
      final models = await remoteDataSource.getLectureSeries(seriesId);
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<ServerException, TeacherAvailability?>> getTeacherAvailability(
    String teacherUid,
  ) async {
    return _handleRequest(() async {
      final model = await remoteDataSource.getTeacherAvailability(teacherUid);
      return model?.toEntity();
    });
  }

  @override
  Future<Either<ServerException, void>> updateTeacherAvailability({
    required String teacherUid,
    required List<String> availableDays,
    required List<TimeSlot> timeSlots,
    required List<String> subjectsOffered,
  }) async {
    return _handleRequest(() => remoteDataSource.updateTeacherAvailability(
          teacherUid: teacherUid,
          availableDays: availableDays,
          timeSlots: timeSlots,
          subjectsOffered: subjectsOffered,
        ));
  }

  Future<Either<ServerException, T>> _handleRequest<T>(
    Future<T> Function() fn,
  ) async {
    try {
      if (!await checkInternetConnection.isConnected) {
        return Left(ServerException(message: 'No internet connection'));
      }
      final result = await fn();
      return Right(result);
    } on ServerException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }
}
