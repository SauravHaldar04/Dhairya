import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/lecture_request_entity.dart';
import '../entities/teacher_interest_entity.dart';
import '../entities/user_notification_entity.dart';

abstract interface class LectureRequestRepository {
  Future<Either<Failure, LectureRequestEntity>> createLectureRequest({
    required String parentUid,
    required String studentId,
    required List<String> subjects,
    required Map<String, dynamic> preferredTimeSlots,
    int? priorityLevel,
    String? additionalNotes,
    DateTime? requestedStartDate,
    String? frequency,
  });

  Future<Either<Failure, List<LectureRequestEntity>>> getParentLectureRequests(
      String parentUid);

  Future<Either<Failure, LectureRequestEntity>> getLectureRequestById(
      String requestId);

  Future<Either<Failure, List<LectureRequestEntity>>> getTeacherOpportunities(
      String teacherId);

  Future<Either<Failure, TeacherInterestEntity>> respondToOpportunity({
    required String lectureRequestId,
    required String teacherUid,
    required String studentId,
    required String subject,
    required Map<String, dynamic> preferredTimeSlots,
    required String studentGrade,
    required String interestStatus,
  });

  Future<Either<Failure, List<UserNotificationEntity>>> getUserNotifications(
      String userId);

  Future<Either<Failure, void>> markNotificationAsRead(String notificationId);
}
