import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/lectures_repository.dart';

/// Use Case: Schedule a lecture notification
/// Creates a notification record to be sent at specified time
/// Used for lecture reminders (e.g., 10 minutes before)
class ScheduleLectureNotification implements Usecase<String, ScheduleLectureNotificationParams> {
  final LecturesRepository repository;

  ScheduleLectureNotification(this.repository);

  @override
  Future<Either<Failure, String>> call(ScheduleLectureNotificationParams params) async {
    final result = await repository.scheduleNotification(
      lectureId: params.lectureId,
      templateId: params.templateId,
      scheduledFor: params.scheduledFor,
      notificationType: params.notificationType,
    );
    
    return result.fold(
      (serverException) => Left(Failure(serverException.message)),
      (notificationId) => Right(notificationId),
    );
  }
}

class ScheduleLectureNotificationParams {
  final String? lectureId;
  final String? templateId;
  final DateTime scheduledFor;
  final String notificationType; // 'lecture_reminder', 'lecture_starting', etc.

  ScheduleLectureNotificationParams({
    this.lectureId,
    this.templateId,
    required this.scheduledFor,
    required this.notificationType,
  });
}
