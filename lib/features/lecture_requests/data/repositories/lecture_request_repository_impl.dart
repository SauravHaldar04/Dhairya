import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/server_exception.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/user_notification_entity.dart';
import '../../domain/entities/lecture_request_entity.dart';
import '../../domain/entities/teacher_interest_entity.dart';
import '../../domain/repository/lecture_request_repository.dart';
import '../datasources/lecture_request_remote_datasource.dart';
import '../models/lecture_request_model.dart';

class LectureRequestRepositoryImpl implements LectureRequestRepository {
  final LectureRequestRemoteDataSource remoteDataSource;

  LectureRequestRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, LectureRequestEntity>> createLectureRequest({
    required String parentUid,
    required String studentId,
    required List<String> subjects,
    required Map<String, dynamic> preferredTimeSlots,
    int? priorityLevel,
    String? additionalNotes,
    DateTime? requestedStartDate,
    String? frequency,
  }) async {
    try {
      final request = LectureRequestModel(
        id: const Uuid().v4(),
        parentUid: parentUid,
        studentId: studentId,
        subjects: subjects,
        preferredTimeSlots: preferredTimeSlots,
        status: 'pending',
        priorityLevel: priorityLevel,
        additionalNotes: additionalNotes,
        requestedStartDate: requestedStartDate,
        frequency: frequency,
        createdAt: DateTime.now(),
      );

      final result = await remoteDataSource.createLectureRequest(request);
      return right(result.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<LectureRequestEntity>>> getParentLectureRequests(
      String parentUid) async {
    try {
      final requests =
          await remoteDataSource.getParentLectureRequests(parentUid);
      return right(requests.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, LectureRequestEntity>> getLectureRequestById(
      String requestId) async {
    try {
      final request = await remoteDataSource.getLectureRequestById(requestId);
      return right(request.toEntity());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<LectureRequestEntity>>> getTeacherOpportunities(
      String teacherId) async {
    try {
      final opportunities =
          await remoteDataSource.getTeacherOpportunities(teacherId);
      return right(opportunities.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, TeacherInterestEntity>> respondToOpportunity({
    required String lectureRequestId,
    required String teacherUid,
    required String studentId,
    required String subject,
    required Map<String, dynamic> preferredTimeSlots,
    required String studentGrade,
    required String interestStatus,
  }) async {
    try {
      final response = await remoteDataSource.respondToOpportunity(
        lectureRequestId: lectureRequestId,
        teacherUid: teacherUid,
        studentId: studentId,
        subject: subject,
        preferredTimeSlots: preferredTimeSlots,
        studentGrade: studentGrade,
        interestStatus: interestStatus,
      );
      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<UserNotificationEntity>>> getUserNotifications(
      String userId) async {
    try {
      final notifications =
          await remoteDataSource.getUserNotifications(userId);
      return right(notifications.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> markNotificationAsRead(
      String notificationId) async {
    try {
      await remoteDataSource.markNotificationAsRead(notificationId);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
