import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../domain/entities/lecture_entity.dart';
import '../../../../core/theme/app_colors.dart';

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

  Color _statusColor(ColorScheme cs) {
    final s = lectures.first.status;
    switch (s) {
      case 'scheduled':
      case 'rescheduled':
        return cs.primary;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'in_progress':
        return AppColors.warning;
      default:
        return cs.outline;
    }
  }

  IconData _statusIcon() {
    switch (lectures.first.status) {
      case 'scheduled':
      case 'rescheduled':
        return PhosphorIcons.clock();
      case 'completed':
        return PhosphorIcons.checkCircle();
      case 'cancelled':
        return PhosphorIcons.xCircle();
      case 'in_progress':
        return PhosphorIcons.playCircle();
      default:
        return PhosphorIcons.info();
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

  String _recurrenceDaysLabel() {
    final days = lectures.first.recurrenceDays;
    if (days == null || days.isEmpty) return 'Daily';
    return days.map((d) => d.substring(0, 3).toUpperCase()).join(' · ');
  }

  String _dateRangeLabel() {
    if (lectures.isEmpty) return '';
    final sorted = List<Lecture>.from(lectures)
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    final first = sorted.first.scheduledDate;
    final last = sorted.last.scheduledDate;
    if (first == last) return DateFormat('dd MMM yyyy').format(first);
    return '${DateFormat('dd MMM').format(first)} – ${DateFormat('dd MMM yyyy').format(last)}';
  }

  @override
  Widget build(BuildContext context) {
    if (lectures.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final first = lectures.first;
    final sColor = _statusColor(cs);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: sColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(PhosphorIcons.bookOpen(), color: sColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          first.subject,
                          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(_statusIcon(), size: 14, color: sColor),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                first.status.replaceAll('_', ' ').toUpperCase(),
                                style: tt.labelSmall?.copyWith(
                                  color: sColor,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Days badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(PhosphorIcons.arrowsClockwise(), size: 14, color: cs.onSecondaryContainer),
                        const SizedBox(width: 4),
                        Text(
                          _recurrenceDaysLabel(),
                          style: tt.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Count pill ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIcons.calendarCheck(), size: 16, color: cs.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${lectures.length} ${lectures.length == 1 ? 'lecture' : 'lectures'}',
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Date range + time ──
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(PhosphorIcons.calendarBlank(), size: 16, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _dateRangeLabel(),
                            style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(PhosphorIcons.clock(), size: 16, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_formatTime(first.scheduledTime.startTime)} – ${_formatTime(first.scheduledTime.endTime)}',
                            style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Student name ──
              if (first.studentFirstName != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(PhosphorIcons.user(), size: 16, color: cs.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${first.studentFirstName} ${first.studentMiddleName ?? ''} ${first.studentLastName ?? ''}'.trim(),
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // ── Meeting link ──
              if (first.meetingLink != null && first.meetingLink!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.info.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.videoCamera(), size: 16, color: AppColors.info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Online Lectures',
                          style: tt.bodySmall?.copyWith(color: cs.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Notes ──
              if (first.notes != null && first.notes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(PhosphorIcons.notepad(), size: 16, color: cs.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          first.notes!,
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Actions ──
              if (showActions &&
                  (first.status == 'scheduled' || first.status == 'rescheduled')) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (onReschedule != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReschedule,
                          icon: Icon(PhosphorIcons.clockClockwise(), size: 16),
                          label: const Text('Reschedule'),
                        ),
                      ),
                    if (onReschedule != null && onCancel != null) const SizedBox(width: 10),
                    if (onCancel != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onCancel,
                          icon: Icon(PhosphorIcons.x(), size: 16),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.error,
                            side: BorderSide(color: cs.error),
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
