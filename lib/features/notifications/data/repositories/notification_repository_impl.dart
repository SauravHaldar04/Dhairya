import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/network/check_internet_connection.dart';
import 'package:aparna_education/features/notifications/data/datasources/notification_local_data_source.dart';
import 'package:aparna_education/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:aparna_education/features/notifications/domain/entities/notification_entity.dart';
import 'package:aparna_education/features/notifications/domain/repositories/notification_repository.dart';
import 'package:fpdart/fpdart.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NotificationLocalDataSource localDataSource;
  final CheckInternetConnection checkInternetConnection;

  NotificationRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.checkInternetConnection,
  );

  @override
  Future<Either<Failure, List<NotificationEntity>>> getUserNotifications(String userId) async {
    try {
      if (!await checkInternetConnection.isConnected) {
        final cached = await localDataSource.getCachedNotifications(userId);
        return right(cached);
      }
      final notifications = await remoteDataSource.getUserNotifications(userId);
      await localDataSource.cacheNotifications(userId, notifications);
      return right(notifications);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> getCachedNotifications(String userId) async {
    try {
      final cached = await localDataSource.getCachedNotifications(userId);
      return right(cached);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await localDataSource.markAsRead(notificationId);
      if (!await checkInternetConnection.isConnected) {
        return right(null);
      }
      await remoteDataSource.markAsRead(notificationId);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
