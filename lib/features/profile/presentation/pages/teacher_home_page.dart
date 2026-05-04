import 'package:flutter/material.dart';
import 'package:aparna_education/core/widgets/animations.dart';
import 'package:aparna_education/features/notifications/presentation/pages/notifications_page.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/pages/teacher_interest_list_page.dart';
class TeacherHomePage extends StatefulWidget {
  final String teacherUid;
  const TeacherHomePage({super.key, required this.teacherUid});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100), // Added bottom padding for navbar
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
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Welcome back, Teacher!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_active_rounded, color: Colors.white),
                      onPressed: () {
                        // Import navigation later
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => 
                              NotificationsPage(userId: widget.teacherUid),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Ready to inspire and educate today?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.school_rounded,
                  title: 'Students',
                  value: '0',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.class_rounded,
                  title: 'Classes',
                  value: '0',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.assignment_rounded,
                  title: 'Assignments',
                  value: '0',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.event_rounded,
                  title: 'Lectures',
                  value: '0',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildActionCard(
            icon: Icons.group_add_rounded,
            title: 'Add Students',
            subtitle: 'Enroll new students to your classes',
            color: Theme.of(context).colorScheme.primary,
          ),
          
          const SizedBox(height: 12),
          
          _buildActionCard(
            icon: Icons.video_call_rounded,
            title: 'Start Lecture',
            subtitle: 'Begin a live session with your students',
            color: Theme.of(context).colorScheme.secondary,
          ),
          
          const SizedBox(height: 12),
          
          _buildActionCard(
            icon: Icons.assignment_rounded,
            title: 'Create Assignment',
            subtitle: 'Design new homework or projects',
            color: Colors.green,
          ),
          
          const SizedBox(height: 12),
          
          _buildActionCard(
            icon: Icons.assignment_ind_rounded,
            title: 'Teaching Opportunities',
            subtitle: 'View and accept new student requests',
            color: Colors.deepPurple,
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
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
