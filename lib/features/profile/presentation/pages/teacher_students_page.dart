import 'package:flutter/material.dart';
import 'package:aparna_education/core/widgets/animations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aparna_education/features/lectures/presentation/bloc/lectures_bloc.dart';
import 'package:aparna_education/features/lectures/domain/entities/teacher_student_assignment_entity.dart';
import 'package:aparna_education/features/profile/presentation/pages/teacher_student_details_page.dart';


class TeacherStudentsPage extends StatefulWidget {
  final String teacherUid;
  const TeacherStudentsPage({super.key, required this.teacherUid});

  @override
  State<TeacherStudentsPage> createState() => _TeacherStudentsPageState();
}

class _TeacherStudentsPageState extends State<TeacherStudentsPage> {
  @override
  void initState() {
    super.initState();
    // Request teacher assignments so we can derive students
    context.read<LecturesBloc>().add(GetTeacherAssignmentsEvent(teacherUid: widget.teacherUid, assignmentStatus: 'active'));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<LecturesBloc, LecturesState>(
      builder: (context, state) {
        final assignments = state is TeacherAssignmentsLoaded
            ? state.assignments.where((a) => a.teacherUid == widget.teacherUid).toList()
            : <TeacherStudentAssignment>[];

        final Map<String, TeacherStudentAssignment> studentsById = {};
        for (final assignment in assignments) {
          studentsById[assignment.studentUid] = assignment;
        }
        final students = studentsById.values.toList();

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Students',
                  style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search students…',
                    prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
                  ),
                ),
              ),
            ),
            if (state is LecturesLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (students.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: FadeInSlide(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.school_outlined,
                              size: 64,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No students yet',
                            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Students will appear here once they\nare assigned to you.',
                            textAlign: TextAlign.center,
                            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final student = students[index];
                      final fullName = [
                        student.studentFirstName,
                        student.studentMiddleName,
                        student.studentLastName,
                      ].whereType<String>().where((text) => text.isNotEmpty).join(' ');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AnimatedCard(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TeacherStudentDetailsPage(
                                  assignment: student,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: cs.surfaceVariant,
                                backgroundImage: student.studentProfilePic != null && student.studentProfilePic!.isNotEmpty
                                    ? NetworkImage(student.studentProfilePic!)
                                    : null,
                                child: student.studentProfilePic == null || student.studentProfilePic!.isEmpty
                                    ? Icon(Icons.person, color: cs.onSurfaceVariant)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fullName.isNotEmpty ? fullName : 'Unknown Student',
                                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${student.studentStandard ?? '-'} • ${student.studentBoard ?? '-'}',
                                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: students.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
