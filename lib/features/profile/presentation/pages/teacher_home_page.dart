import 'package:flutter/material.dart';
import 'package:aparna_education/core/widgets/animations.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/pages/teacher_interest_list_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aparna_education/features/lectures/presentation/bloc/lectures_bloc.dart' hide NotificationsLoaded;
import 'package:aparna_education/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:aparna_education/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/bloc/teacher_interest_bloc.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/bloc/teacher_interest_state.dart';

class TeacherHomePage extends StatefulWidget {
  final String teacherUid;
  const TeacherHomePage({super.key, required this.teacherUid});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: StaggeredAnimation(
        children: [
          // Welcome Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.waving_hand_rounded,
                      color: cs.onPrimary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Welcome back, Teacher!',
                        style: tt.headlineSmall?.copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready to inspire and educate today?',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onPrimary.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats
          Row(
            children: [
              Expanded(
                child: BlocBuilder<NotificationsBloc, NotificationsState>(
                  builder: (context, state) {
                    final unread = state is NotificationsLoaded
                        ? state.notifications.where((n) => !n.isRead).length
                        : 0;
                    return _buildStatCard(
                      icon: Icons.notifications_rounded,
                      title: 'Unread',
                      value: unread.toString(),
                      color: cs.primary,
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: BlocBuilder<TeacherInterestBloc, TeacherInterestState>(
                  builder: (context, state) {
                    final pending = state is TeacherInterestLoaded
                        ? state.interests.length
                        : 0;
                    return _buildStatCard(
                      icon: Icons.assignment_ind_rounded,
                      title: 'Opportunities',
                      value: pending.toString(),
                      color: cs.secondary,
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: BlocBuilder<LecturesBloc, LecturesState>(
                  builder: (context, state) {
                    final count = state is UpcomingLecturesLoaded
                        ? state.lectures.length
                        : null;
                    return _buildStatCard(
                      icon: Icons.event_rounded,
                      title: 'Upcoming (7d)',
                      value: count?.toString() ?? '—',
                      color: cs.tertiary,
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

          // Students count (full width)
          BlocBuilder<LecturesBloc, LecturesState>(
            builder: (context, state) {
              int studentsCount = 0;
              if (state is TeacherAssignmentsLoaded) {
                final ids = state.assignments
                  .where((a) => a.teacherUid == widget.teacherUid)
                  .map((a) => a.studentUid)
                  .toSet();
                studentsCount = ids.length;
              }
              return Expanded(
                //padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: _buildStatCard(
                  icon: Icons.school_rounded,
                  title: 'Students',
                  value: studentsCount > 0 ? studentsCount.toString() : '—',
                  color: cs.primary,
                ),
              );
            },
          ),
            ],
          ),
          
          

          const SizedBox(height: 16),
          
          const SizedBox(height: 16),
          
          // Quick Actions
          Text(
            'Quick Actions',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          
          const SizedBox(height: 16),
          
          _buildActionCard(
            icon: Icons.group_add_rounded,
            title: 'Add Students',
            subtitle: 'Enroll new students to your classes',
            color: cs.primary,
          ),
          
          const SizedBox(height: 12),
          
          _buildActionCard(
            icon: Icons.video_call_rounded,
            title: 'Start Lecture',
            subtitle: 'Begin a live session with your students',
            color: cs.secondary,
          ),
          
          const SizedBox(height: 12),
          
          _buildActionCard(
            icon: Icons.assignment_rounded,
            title: 'Create Assignment',
            subtitle: 'Design new homework or projects',
            color: cs.tertiary,
          ),
          
          const SizedBox(height: 12),
          
          _buildActionCard(
            icon: Icons.assignment_ind_rounded,
            title: 'Teaching Opportunities',
            subtitle: 'View and accept new student requests',
            color: cs.secondary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => 
                    TeacherInterestListPage(teacherUid: widget.teacherUid),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AnimatedCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AnimatedCard(
      onTap: onTap ?? () {},
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: cs.onSurfaceVariant.withOpacity(0.7),
          ),
        ],
      ),
    );
  }
}
