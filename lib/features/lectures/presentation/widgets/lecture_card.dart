import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../domain/entities/lecture_entity.dart';
import '../../../../core/theme/app_colors.dart';

class LectureCard extends StatelessWidget {
  final Lecture lecture;
  final VoidCallback? onTap;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;
  final bool showActions;

  const LectureCard({
    Key? key,
    required this.lecture,
    this.onTap,
    this.onReschedule,
    this.onCancel,
    this.showActions = true,
  }) : super(key: key);

  Color _statusColor(ColorScheme cs) {
    switch (lecture.status) {
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
    switch (lecture.status) {
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
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
                          lecture.subject,
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
                                lecture.status.replaceAll('_', ' ').toUpperCase(),
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
                  if (lecture.isRecurring)
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
                            'Recurring',
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
              const SizedBox(height: 14),

              // ── Date & Time chips ──
              Row(
                children: [
                  Expanded(child: _infoChip(
                    context,
                    icon: PhosphorIcons.calendarBlank(),
                    label: DateFormat('dd MMM yyyy').format(lecture.scheduledDate),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _infoChip(
                    context,
                    icon: PhosphorIcons.clock(),
                    label: '${_formatTime(lecture.scheduledTime.startTime)} – ${_formatTime(lecture.scheduledTime.endTime)}',
                  )),
                ],
              ),

              // ── Rescheduled banner ──
              if (lecture.status == 'rescheduled' && lecture.originalDate != null) ...[
                const SizedBox(height: 10),
                _banner(
                  context,
                  color: AppColors.warning,
                  icon: PhosphorIcons.info(),
                  text: 'Rescheduled from ${DateFormat('dd MMM').format(lecture.originalDate!)}${lecture.rescheduledReason != null ? ' — ${lecture.rescheduledReason}' : ''}',
                ),
              ],

              // ── Meeting link ──
              if (lecture.meetingLink != null && lecture.meetingLink!.isNotEmpty) ...[
                const SizedBox(height: 10),
                _banner(
                  context,
                  color: AppColors.info,
                  icon: PhosphorIcons.videoCamera(),
                  text: 'Online Lecture',
                  trailing: Icon(PhosphorIcons.arrowSquareOut(), size: 14, color: AppColors.info),
                ),
              ],

              // ── Notes ──
              if (lecture.notes != null && lecture.notes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                _banner(
                  context,
                  color: cs.outline,
                  icon: PhosphorIcons.notepad(),
                  text: lecture.notes!,
                ),
              ],

              // ── Actions ──
              if (showActions &&
                  (lecture.status == 'scheduled' || lecture.status == 'rescheduled')) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (onReschedule != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReschedule,
                          icon:  Icon(PhosphorIconsRegular.clockClockwise, size: 16),
                          label: const Text('Reschedule'),
                        ),
                      ),
                    if (onReschedule != null && onCancel != null) const SizedBox(width: 10),
                    if (onCancel != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onCancel,
                          icon: const Icon(PhosphorIconsRegular.x, size: 16),
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

  // ── Helpers ──

  Widget _infoChip(BuildContext context, {required IconData icon, required String label}) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _banner(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String text,
    Widget? trailing,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }
}
