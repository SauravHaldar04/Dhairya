import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/core/widgets/custom_loader.dart';
import 'package:aparna_education/core/widgets/animations.dart';
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
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Pallete.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'My Lectures',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Pallete.primaryColor,
                        Pallete.primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.schedule,
                            label: 'Availability',
                            color: Pallete.primaryColor,
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
                            icon: Icons.add_circle_outline,
                            label: 'Create Lecture',
                            color: Pallete.secondaryColor,
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
                            icon: Icons.list_alt,
                            label: 'All Lectures',
                            color: Colors.orange,
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
                            icon: Icons.people_outline,
                            label: 'Students',
                            color: Colors.green,
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upcoming Lectures',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
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
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CustomLoader()),
                    ),
                  );
                }

                if (state is UpcomingLecturesLoaded) {
                  if (state.lectures.isEmpty) {
                    return SliverToBoxAdapter(
                      child: FadeInSlide(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Upcoming Lectures',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create your first lecture to get started',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final lecture = state.lectures[index];
                          return FadeInSlide(
                            duration:
                                Duration(milliseconds: 300 + (index * 100)),
                            child: Padding(
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
                            ),
                          );
                        },
                        childCount: state.lectures.length > 3
                            ? 3
                            : state.lectures.length,
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
    showDialog(
      context: context,
      builder: (dialogContext) {
        context.read<LecturesBloc>().add(
              GetTeacherAssignmentsEvent(teacherUid: widget.teacherUid),
            );

        return ScaleInAnimation(
          child: Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 500),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Pallete.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people, color: Colors.white),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'My Students',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<LecturesBloc, LecturesState>(
                      builder: (context, state) {
                        if (state is LecturesLoading) {
                          return const Center(child: CustomLoader());
                        }

                        if (state is TeacherAssignmentsLoaded) {
                          if (state.assignments.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline,
                                      size: 64,
                                      color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No Students Assigned',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
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
    showDialog(
      context: context,
      builder: (dialogContext) {
        final reasonController = TextEditingController();
        return ScaleInAnimation(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('Cancel Lecture'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'Are you sure you want to cancel this lecture?'),
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
              ElevatedButton(
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
                    const SnackBar(
                      content: Text('Lecture cancelled successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadData();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red),
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
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
    return FadeInSlide(
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
