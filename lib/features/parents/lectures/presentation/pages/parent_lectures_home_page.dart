import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/core/widgets/custom_loader.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Pallete.primaryColor,
        elevation: 0,
        title: const Text(
          'Lectures',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
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
                    child: _buildActionCard(
                      context,
                      'Request Lecture',
                      Icons.add_circle_outline,
                      Pallete.primaryColor,
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
                      Icons.list_alt,
                      Pallete.secondaryColor,
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
                      Icons.assignment,
                      Colors.orange,
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
                      Icons.calendar_today,
                      Colors.green,
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
              const SizedBox(height: 32),
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<LecturesBloc, LecturesState>(
                builder: (context, state) {
                  if (state is LecturesLoading) {
                    return const Center(child: CustomLoader());
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
