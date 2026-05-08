
import 'package:aparna_education/features/notifications/domain/entities/notification_entity.dart';
import 'package:aparna_education/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:aparna_education/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:aparna_education/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aparna_education/core/utils/loader.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/pages/teacher_interest_list_page.dart' as aparna_education_interest_page;

class NotificationsPage extends StatefulWidget {
  final String userId;

  const NotificationsPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(FetchUserNotifications(widget.userId));
  }

  void _onNotificationTap(NotificationEntity notification) {
    if (!notification.isRead) {
      context.read<NotificationsBloc>().add(MarkNotificationAsRead(notification.id));
    }

    // Handle routing depending on type
    if (notification.notificationType == 'TEACHER_INTEREST_REQUEST') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => aparna_education_interest_page.TeacherInterestListPage(
            teacherUid: widget.userId,
          ),
        ),
      );
    }
  }

  Widget _buildNotificationItem(NotificationEntity notification) {
    final bool isUnread = !notification.isRead;
    return InkWell(
      onTap: () => _onNotificationTap(notification),
      child: Container(
        color: isUnread ? Theme.of(context).colorScheme.primary.withOpacity(0.06) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: isUnread ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
              radius: 20,
              child: Icon(
                Icons.notifications,
                color: isUnread ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      color: isUnread ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTimeAgo(notification.createdAt),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 7) {
      return "${date.day}/${date.month}/${date.year}";
    } else if (difference.inDays > 0) {
      return "${difference.inDays} days ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hours ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} mins ago";
    } else {
      return "Just now";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Loader();
          } else if (state is NotificationsError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is NotificationsLoaded) {
            final notifications = state.notifications;
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _buildNotificationItem(notifications[index]);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
