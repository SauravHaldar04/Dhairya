import 'package:aparna_education/core/widgets/app_loading.dart';
import 'package:aparna_education/core/widgets/project_button.dart';
import 'package:aparna_education/core/utils/snackbar.dart';
import 'package:aparna_education/features/lectures/domain/entities/lecture_entity.dart';
import 'package:aparna_education/features/lectures/presentation/bloc/lectures_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherLectureDetailsPage extends StatefulWidget {
  final Lecture lecture;

  static route(Lecture lecture) => MaterialPageRoute(
        builder: (context) => TeacherLectureDetailsPage(lecture: lecture),
      );

  const TeacherLectureDetailsPage({super.key, required this.lecture});

  @override
  State<TeacherLectureDetailsPage> createState() => _TeacherLectureDetailsPageState();
}

class _TeacherLectureDetailsPageState extends State<TeacherLectureDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lecture Details'), centerTitle: true),
      body: BlocConsumer<LecturesBloc, LecturesState>(
        listener: (context, state) {
          if (state is LecturesError) showSnackbar(context, state.message);
          if (state is LectureRescheduled) {
            showSnackbar(context, 'Lecture rescheduled successfully');
            Navigator.of(context).pop();
          }
          if (state is LectureCancelled) {
            showSnackbar(context, 'Lecture cancelled successfully');
            Navigator.of(context).pop();
          }
          if (state is AttendanceMarked) {
            showSnackbar(context, 'Attendance marked successfully');
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is LecturesLoading) return AppLoading.centered();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.lecture.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.lecture.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(widget.lecture.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Subject
                Text(widget.lecture.subject, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                
                // Date & Time
                Row(
                  children: [
                    Icon(PhosphorIconsRegular.calendarBlank, color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(DateFormat('EEEE, MMMM d, y').format(widget.lecture.scheduledDate), style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(PhosphorIconsRegular.clock, color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('${widget.lecture.scheduledTime.startTime} - ${widget.lecture.scheduledTime.endTime}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
                
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                // Student Info
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(PhosphorIconsRegular.user, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  title: const Text('Student ID'),
                  subtitle: Text(widget.lecture.studentUid.substring(0, 12) + '...'),
                ),
                
                // Meeting Link
                if (widget.lecture.meetingLink != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: ListTile(
                      leading: Icon(PhosphorIconsRegular.videoCamera, color: Theme.of(context).colorScheme.onPrimaryContainer),
                      title: const Text('Meeting Link'),
                      subtitle: Text(widget.lecture.meetingLink!, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: Icon(PhosphorIconsRegular.arrowSquareOut, color: Theme.of(context).colorScheme.primary),
                        onPressed: () async {
                          final uri = Uri.parse(widget.lecture.meetingLink!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            if (mounted) showSnackbar(context, 'Could not open meeting link');
                          }
                        },
                      ),
                    ),
                  ),
                ],
                
                // Notes
                if (widget.lecture.notes != null) ...[
                  const SizedBox(height: 16),
                  Text('Notes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(widget.lecture.notes!),
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Actions
                if (widget.lecture.status == 'scheduled') ...[
                  ProjectButton(
                    text: 'Mark Attendance',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Mark Attendance'),
                          content: const Text('Did the student attend this lecture?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                context.read<LecturesBloc>().add(
                                  MarkAttendanceEvent(lectureId: widget.lecture.id, attended: false),
                                );
                                Navigator.pop(dialogContext);
                              },
                              child: const Text('Absent'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.read<LecturesBloc>().add(
                                  MarkAttendanceEvent(lectureId: widget.lecture.id, attended: true),
                                );
                                Navigator.pop(dialogContext);
                              },
                              child: const Text('Present'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => showSnackbar(context, 'Reschedule feature coming soon'),
                    child: const Text('Reschedule'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Cancel Lecture'),
                          content: const Text('Are you sure you want to cancel this lecture?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('No'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.read<LecturesBloc>().add(CancelLectureEvent(lectureId: widget.lecture.id));
                                Navigator.pop(dialogContext);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Yes, Cancel'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Cancel Lecture'),
                  ),
                ],
                
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled': return Colors.blue;
      case 'in_progress': return Colors.orange;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'rescheduled': return Colors.purple;
      default: return Colors.grey;
    }
  }
}
