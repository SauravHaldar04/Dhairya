import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_notification_entity.dart';
import '../repository/lecture_request_repository.dart';

class GetUserNotifications
    implements Usecase<List<UserNotificationEntity>, String> {
  final LectureRequestRepository repository;

  GetUserNotifications(this.repository);

  @override
  Future<Either<Failure, List<UserNotificationEntity>>> call(
      String userId) async {
    return await repository.getUserNotifications(userId);
  }
}
