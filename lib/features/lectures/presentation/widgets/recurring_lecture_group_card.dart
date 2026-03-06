import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/lecture_entity.dart';
import '../../../../core/theme/app_pallete.dart';

class RecurringLectureGroupCard extends StatelessWidget {
  final List<Lecture> lectures;
  final VoidCallback? onTap;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;
  final bool showActions;

  const RecurringLectureGroupCard({
    Key? key,
    required this.lectures,
    this.onTap,
    this.onReschedule,
    this.onCancel,
    this.showActions = true,
  }) : super(key: key);

  Color _getStatusColor() {
    final firstLecture = lectures.first;
    switch (firstLecture.status) {
      case 'scheduled':
      case 'rescheduled':
        return Pallete.primaryColor;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in_progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    final firstLecture = lectures.first;
    switch (firstLecture.status) {
      case 'scheduled':
      case 'rescheduled':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'in_progress':
        return Icons.play_circle;
      default:
        return Icons.info;
    }
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return time;
    }
  }

  String _getRecurrenceDaysDisplay() {
    final firstLecture = lectures.first;
    if (firstLecture.recurrenceDays == null || firstLecture.recurrenceDays!.isEmpty) {
      return 'Daily';
    }

    final days = firstLecture.recurrenceDays!.map((day) {
      return day.substring(0, 3).toUpperCase();
    }).join('-');
    
    return days;
  }

  String _getDateRange() {
    if (lectures.isEmpty) return '';
    
    final sortedLectures = List<Lecture>.from(lectures)
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    
    final firstDate = sortedLectures.first.scheduledDate;
    final lastDate = sortedLectures.last.scheduledDate;
    
    if (firstDate.year == lastDate.year && 
        firstDate.month == lastDate.month && 
        firstDate.day == lastDate.day) {
      return DateFormat('dd MMM yyyy').format(firstDate);
    }
    
    return '${DateFormat('dd MMM').format(firstDate)} - ${DateFormat('dd MMM yyyy').format(lastDate)}';
  }

  @override
  Widget build(BuildContext context) {
    if (lectures.isEmpty) return const SizedBox.shrink();
    
    final firstLecture = lectures.first;
    final statusColor = _getStatusColor();

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.book_outlined,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstLecture.subject,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getStatusIcon(),
                              size: 16,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                firstLecture.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Pallete.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.repeat,
                          size: 14,
                          color: Pallete.secondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getRecurrenceDaysDisplay(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Pallete.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Pallete.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_repeat,
                      size: 16,
                      color: Pallete.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${lectures.length} ${lectures.length == 1 ? 'lecture' : 'lectures'}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Pallete.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Date Range and Time
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: Pallete.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getDateRange(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 18,
                          color: Pallete.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_formatTime(firstLecture.scheduledTime.startTime)} - ${_formatTime(firstLecture.scheduledTime.endTime)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Student name (if available)
              if (firstLecture.studentFirstName != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${firstLecture.studentFirstName} ${firstLecture.studentMiddleName ?? ''} ${firstLecture.studentLastName ?? ''}'.trim(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Meeting Link
              if (firstLecture.meetingLink != null && firstLecture.meetingLink!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.videocam_outlined,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Online Lectures',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Notes
              if (firstLecture.notes != null && firstLecture.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          firstLecture.notes!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action Buttons
              if (showActions && 
                  (firstLecture.status == 'scheduled' || firstLecture.status == 'rescheduled')) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (onReschedule != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReschedule,
                          icon: const Icon(Icons.schedule, size: 16),
                          label: const Text(
                            'Reschedule',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Pallete.primaryColor,
                            side: BorderSide(color: Pallete.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    if (onReschedule != null && onCancel != null)
                      const SizedBox(width: 12),
                    if (onCancel != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onCancel,
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
