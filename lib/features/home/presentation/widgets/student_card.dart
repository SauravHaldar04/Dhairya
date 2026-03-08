import 'package:aparna_education/features/profile/domain/entities/student_entity.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback? onTap;

  const StudentCard({
    Key? key,
    required this.student,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: cs.primaryContainer,
                    backgroundImage: student.profilePic != null
                        ? NetworkImage(student.profilePic!)
                        : null,
                    child: student.profilePic == null
                        ? Icon(PhosphorIconsRegular.user, color: cs.onPrimaryContainer, size: 24)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${student.firstName} ${student.middleName} ${student.lastName}',
                          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          student.email,
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(PhosphorIconsRegular.caretRight, size: 16, color: cs.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _infoItem(cs, tt,
                          icon: PhosphorIconsRegular.graduationCap,
                          label: 'Standard', value: student.standard)),
                        Expanded(child: _infoItem(cs, tt,
                          icon: PhosphorIconsRegular.books,
                          label: 'Board', value: student.board)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _infoItem(cs, tt,
                          icon: PhosphorIconsRegular.globe,
                          label: 'Medium', value: student.medium)),
                        Expanded(child: _infoItem(cs, tt,
                          icon: PhosphorIconsRegular.sealCheck,
                          label: 'Email Verified',
                          value: student.emailVerified ? 'Yes' : 'No')),
                      ],
                    ),
                  ],
                ),
              ),
              if (student.subjects.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Subjects:', style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: student.subjects.take(3).map((subject) {
                    return Chip(
                      label: Text(subject),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  }).toList()
                    ..addAll(
                      student.subjects.length > 3
                          ? [
                              Chip(
                                label: Text('+${student.subjects.length - 3} more'),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.zero,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ]
                          : [],
                    ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(ColorScheme cs, TextTheme tt, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              Text(value, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
