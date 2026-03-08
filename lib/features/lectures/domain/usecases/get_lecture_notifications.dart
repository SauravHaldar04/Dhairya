import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/lecture_notification_entity.dart';
import '../repositories/lectures_repository.dart';

/// Use Case: Get lecture notifications
/// Retrieves notification history filtered by lecture/template/sent status
class GetLectureNotifications implements Usecase<List<LectureNotification>, GetLectureNotificationsParams> {
  final LecturesRepository repository;

  GetLectureNotifications(this.repository);

  @override
  Future<Either<Failure, List<LectureNotification>>> call(GetLectureNotificationsParams params) async {
    final result = await repository.getNotifications(
      lectureId: params.lectureId,
      templateId: params.templateId,
      isSent: params.isSent,
      fromDate: params.fromDate,
      toDate: params.toDate,
    );
    
    return result.fold(
      (serverException) => Left(Failure(serverException.message)),
      (notifications) => Right(notifications),
    );
  }
}

class GetLectureNotificationsParams {
  final String? lectureId;
  final String? templateId;
  final bool? isSent;
  final DateTime? fromDate;
  final DateTime? toDate;

  GetLectureNotificationsParams({
    this.lectureId,
    this.templateId,
    this.isSent,
    this.fromDate,
    this.toDate,
  });
}
