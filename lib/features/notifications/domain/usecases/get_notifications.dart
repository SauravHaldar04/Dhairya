import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/notifications/domain/entities/notification_entity.dart';
import 'package:aparna_education/features/notifications/domain/repositories/notification_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetNotifications implements Usecase<List<NotificationEntity>, String> {
  final NotificationRepository repository;

  GetNotifications(this.repository);

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(String userId) async {
    return await repository.getUserNotifications(userId);
  }
}
