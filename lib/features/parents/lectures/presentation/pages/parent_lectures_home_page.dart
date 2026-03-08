import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:aparna_education/core/widgets/app_loading.dart';
import 'package:aparna_education/features/lectures/presentation/bloc/lectures_bloc.dart';
import 'package:aparna_education/features/parents/lectures/presentation/pages/parent_request_lecture_page.dart';
import 'package:aparna_education/features/parents/lectures/presentation/pages/parent_lecture_requests_page.dart';
import 'package:aparna_education/features/parents/lectures/presentation/pages/parent_student_assignments_page.dart';
import 'package:aparna_education/features/parents/lectures/presentation/pages/parent_upcoming_lectures_page.dart';

class ParentLecturesHomePage extends StatefulWidget {
  final String parentUid;

  const ParentLecturesHomePage({
    Key? key,
    required this.parentUid,
  }) : super(key: key);

  @override
  State<ParentLecturesHomePage> createState() => _ParentLecturesHomePageState();
}

class _ParentLecturesHomePageState extends State<ParentLecturesHomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<LecturesBloc>().add(GetLectureRequestsEvent(parentUid: widget.parentUid));
    context.read<LecturesBloc>().add(GetUpcomingLecturesEvent(studentUid: null));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lectures'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quick Actions', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      'Request Lecture',
                      PhosphorIcons.plusCircle(),
                      cs.primary,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ParentRequestLecturePage(parentUid: widget.parentUid),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      'View Requests',
                      PhosphorIcons.listBullets(),
                      cs.secondary,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ParentLectureRequestsPage(parentUid: widget.parentUid),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      'Assignments',
                      PhosphorIcons.bookOpenText(),
                      cs.tertiary,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ParentStudentAssignmentsPage(parentUid: widget.parentUid),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      'Upcoming',
                      PhosphorIcons.calendarCheck(),
                      cs.primary,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ParentUpcomingLecturesPage(parentUid: widget.parentUid),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text('Overview', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              BlocBuilder<LecturesBloc, LecturesState>(
                builder: (context, state) {
                  if (state is LecturesLoading) {
                    return AppLoading.centered();
                  }

                  int pendingRequests = 0;
                  int upcomingLectures = 0;

                  if (state is LectureRequestsLoaded) {
                    pendingRequests = state.requests.where((r) => r.status == 'Pending').length;
                  }
                  if (state is UpcomingLecturesLoaded) {
                    upcomingLectures = state.lectures.length;
                  }

                  return Column(
                    children: [
                      _buildStatCard('Pending Requests', pendingRequests.toString(), Icons.pending_actions, Colors.orange),
                      const SizedBox(height: 12),
                      _buildStatCard('Upcoming Lectures', upcomingLectures.toString(), Icons.event, Colors.green),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(value, style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
