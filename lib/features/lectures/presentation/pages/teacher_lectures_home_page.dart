import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:aparna_education/core/widgets/app_loading.dart';
import 'package:aparna_education/core/widgets/app_empty_state.dart';
import 'package:aparna_education/features/lectures/presentation/bloc/lectures_bloc.dart';
import 'package:aparna_education/features/lectures/presentation/widgets/assignment_card.dart';
import 'package:aparna_education/features/lectures/presentation/widgets/lecture_card.dart';
import 'package:aparna_education/features/teachers/lectures/presentation/pages/teacher_availability_page.dart';
import 'package:aparna_education/features/teachers/lectures/presentation/pages/teacher_create_lecture_page.dart';
import 'package:aparna_education/features/teachers/lectures/presentation/pages/teacher_lectures_list_page.dart';

class TeacherLecturesHomePage extends StatefulWidget {
  final String teacherUid;

  const TeacherLecturesHomePage({
    Key? key,
    required this.teacherUid,
  }) : super(key: key);

  @override
  State<TeacherLecturesHomePage> createState() =>
      _TeacherLecturesHomePageState();
}

class _TeacherLecturesHomePageState extends State<TeacherLecturesHomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<LecturesBloc>().add(
          GetTeacherAssignmentsEvent(
            teacherUid: widget.teacherUid,
            assignmentStatus: 'active',
          ),
        );
    context.read<LecturesBloc>().add(
          GetUpcomingLecturesEvent(
            teacherUid: widget.teacherUid,
            daysAhead: 7,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('My Lectures'),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Actions', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: PhosphorIcons.clock(),
                            label: 'Availability',
                            color: cs.primary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeacherAvailabilityPage(
                                    teacherUid: widget.teacherUid,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionCard(
                            icon: PhosphorIcons.plusCircle(),
                            label: 'Create Lecture',
                            color: cs.secondary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TeacherCreateLecturePage(
                                    teacherUid: widget.teacherUid,
                                  ),
                                ),
                              ).then((_) => _loadData());
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: PhosphorIcons.listBullets(),
                            label: 'All Lectures',
                            color: cs.tertiary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TeacherLecturesListPage(
                                    teacherUid: widget.teacherUid,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionCard(
                            icon: PhosphorIcons.users(),
                            label: 'Students',
                            color: cs.primary,
                            onTap: () {
                              _showAssignmentsDialog();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Upcoming Lectures Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Upcoming Lectures', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeacherLecturesListPage(
                              teacherUid: widget.teacherUid,
                            ),
                          ),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),

            // Lectures List
            BlocBuilder<LecturesBloc, LecturesState>(
              builder: (context, state) {
                if (state is LecturesLoading) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: AppLoading.centered(),
                    ),
                  );
                }

                if (state is UpcomingLecturesLoaded) {
                  if (state.lectures.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: AppEmptyState(
                          icon: PhosphorIcons.calendarX(),
                          title: 'No Upcoming Lectures',
                          subtitle: 'Create your first lecture to get started',
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final lecture = state.lectures[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: LectureCard(
                              lecture: lecture,
                              onTap: () {},
                              onReschedule: () {
                                _showRescheduleDialog(lecture.id);
                              },
                              onCancel: () {
                                _showCancelDialog(lecture.id);
                              },
                            ),
                          );
                        },
                        childCount: state.lectures.length > 3 ? 3 : state.lectures.length,
                      ),
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox());
              },
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
          ],
        ),
      ),
    );
  }

  void _showAssignmentsDialog() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (dialogContext) {
        context.read<LecturesBloc>().add(
              GetTeacherAssignmentsEvent(teacherUid: widget.teacherUid),
            );

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.users(), color: cs.onPrimaryContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'My Students',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: Icon(PhosphorIcons.x(), color: cs.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<LecturesBloc, LecturesState>(
                    builder: (context, state) {
                      if (state is LecturesLoading) {
                        return AppLoading.centered();
                      }

                      if (state is TeacherAssignmentsLoaded) {
                        if (state.assignments.isEmpty) {
                          return AppEmptyState(
                            icon: PhosphorIcons.users(),
                            title: 'No Students Assigned',
                            subtitle: 'Students will appear here once assigned',
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.assignments.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AssignmentCard(
                                assignment: state.assignments[index],
                                isTeacherView: true,
                              ),
                            );
                          },
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRescheduleDialog(String lectureId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reschedule feature coming soon')),
    );
  }

  void _showCancelDialog(String lectureId) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) {
        final reasonController = TextEditingController();
        return AlertDialog(
          icon: Icon(PhosphorIcons.warning(), color: cs.error),
          title: const Text('Cancel Lecture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to cancel this lecture?'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () {
                context.read<LecturesBloc>().add(
                      CancelLectureEvent(
                        lectureId: lectureId,
                        reason: reasonController.text.isEmpty
                            ? null
                            : reasonController.text,
                      ),
                    );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lecture cancelled')),
                );
                _loadData();
              },
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
