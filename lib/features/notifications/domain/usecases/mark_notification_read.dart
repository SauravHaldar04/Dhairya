import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/notifications/domain/repositories/notification_repository.dart';
import 'package:fpdart/fpdart.dart';

class MarkNotificationRead implements Usecase<void, String> {
  final NotificationRepository repository;

  MarkNotificationRead(this.repository);

  @override
  Future<Either<Failure, void>> call(String notificationId) async {
    return await repository.markAsRead(notificationId);
  }
}
