import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aparna_education/features/notifications/domain/usecases/get_cached_notifications.dart';
import 'package:aparna_education/features/notifications/domain/usecases/get_notifications.dart';
import 'package:aparna_education/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:aparna_education/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:aparna_education/features/notifications/presentation/bloc/notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetCachedNotifications _getCachedNotifications;
  final GetNotifications _getNotifications;
  final MarkNotificationRead _markNotificationRead;

  NotificationsBloc({
    required GetCachedNotifications getCachedNotifications,
    required GetNotifications getNotifications,
    required MarkNotificationRead markNotificationRead,
  })  : _getCachedNotifications = getCachedNotifications,
        _getNotifications = getNotifications,
        _markNotificationRead = markNotificationRead,
        super(NotificationsInitial()) {
    on<FetchUserNotifications>(_onFetchUserNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
  }

  Future<void> _onFetchUserNotifications(
    FetchUserNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    bool emittedCache = false;

    final cachedRes = await _getCachedNotifications(event.userId);
    cachedRes.fold(
      (_) {},
      (cached) {
        if (cached.isNotEmpty) {
          emittedCache = true;
          emit(NotificationsLoaded(cached));
        }
      },
    );

    final res = await _getNotifications(event.userId);
    res.fold(
      (failure) {
        if (!emittedCache) {
          emit(NotificationsError(failure.message));
        }
      },
      (notifications) => emit(NotificationsLoaded(notifications)),
    );
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is NotificationsLoaded) {
      final currentNotifications = (state as NotificationsLoaded).notifications;
      
      // Optimistically update UI
      final updatedList = currentNotifications.map((notif) {
        if (notif.id == event.notificationId) {
          return notif.copyWith(isRead: true);
        }
        return notif;
      }).toList();

      emit(NotificationsLoaded(updatedList));

      // Fire API call
      await _markNotificationRead(event.notificationId);
    } else {
       await _markNotificationRead(event.notificationId);
    }
  }
}
