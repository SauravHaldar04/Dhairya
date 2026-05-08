import 'package:flutter/material.dart';
import 'package:aparna_education/core/widgets/animations.dart';
import 'package:aparna_education/features/lectures/domain/entities/teacher_student_assignment_entity.dart';

class TeacherStudentDetailsPage extends StatelessWidget {
  final TeacherStudentAssignment assignment;

  const TeacherStudentDetailsPage({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fullName = [
      assignment.studentFirstName,
      assignment.studentMiddleName,
      assignment.studentLastName,
    ].whereType<String>().where((text) => text.isNotEmpty).join(' ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: FadeInSlide(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: cs.onPrimaryContainer.withOpacity(0.12),
                        backgroundImage: assignment.studentProfilePic != null && assignment.studentProfilePic!.isNotEmpty
                            ? NetworkImage(assignment.studentProfilePic!)
                            : null,
                        child: assignment.studentProfilePic == null || assignment.studentProfilePic!.isEmpty
                            ? Icon(
                                Icons.person,
                                color: cs.onPrimaryContainer,
                                size: 30,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          fullName.isNotEmpty ? fullName : 'Unknown Student',
                          style: tt.headlineSmall?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(label: 'Standard', value: assignment.studentStandard ?? '-'),
                  _InfoChip(label: 'Board', value: assignment.studentBoard ?? '-'),
                  _InfoChip(label: 'Status', value: assignment.assignmentStatus),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionCard(
                    title: 'Assigned Subjects',
                    child: assignment.subjects.isNotEmpty
                        ? Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: assignment.subjects
                                .map(
                                  (subject) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: cs.primaryContainer.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      subject,
                                      style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                )
                                .toList(),
                          )
                        : Text(
                            'No subjects assigned yet.',
                            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                          ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Assignment Timeline',
                    child: Column(
                      children: [
                        _DetailRow(label: 'Status', value: _prettyStatus(assignment.assignmentStatus)),
                        _DetailRow(label: 'Start Date', value: _formatDate(assignment.startDate)),
                        _DetailRow(
                          label: 'End Date',
                          value: assignment.endDate == null ? 'Ongoing' : _formatDate(assignment.endDate!),
                        ),
                        _DetailRow(label: 'Created At', value: _formatDateTime(assignment.createdAt)),
                        _DetailRow(label: 'Updated At', value: _formatDateTime(assignment.updatedAt)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Notes',
                    child: Text(
                      assignment.notes?.isNotEmpty == true ? assignment.notes! : 'No notes added.',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    return '$day/$month/${dateTime.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    final date = _formatDate(dateTime);
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$date $hour:$minute';
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.onPrimaryContainer.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: tt.labelSmall?.copyWith(color: cs.onPrimaryContainer.withOpacity(0.8))),
          const SizedBox(height: 2),
          Text(value, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.onPrimaryContainer)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 6,
              child: Text(
                value,
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _prettyStatus(String status) {
  switch (status.toLowerCase()) {
    case 'active':
      return 'Active';
    case 'paused':
      return 'Paused';
    case 'completed':
      return 'Completed';
    case 'cancelled':
      return 'Cancelled';
    default:
      return status.isEmpty
          ? 'Unknown'
          : status[0].toUpperCase() + status.substring(1);
  }
}
