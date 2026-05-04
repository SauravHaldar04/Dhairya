import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/features/notifications/domain/entities/notification_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getUserNotifications(String userId);
  Future<Either<Failure, List<NotificationEntity>>> getCachedNotifications(String userId);
  Future<Either<Failure, void>> markAsRead(String notificationId);
}
