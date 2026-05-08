import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aparna_education/core/widgets/animations.dart';
import 'package:aparna_education/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aparna_education/features/auth/presentation/pages/landing_page.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:aparna_education/features/profile/domain/entities/teacher_entity.dart';
import 'package:aparna_education/features/profile/presentation/pages/edit_teacher_profile_page.dart';

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  @override
  void initState() {
    super.initState();
    // Check if teacher data is already loaded, if not fetch it
    final currentState = context.read<ProfileBloc>().state;
    if (currentState is! TeacherDataLoaded) {
      context.read<ProfileBloc>().add(GetCurrentUser());
    }
  }

  @override
  Widget build(BuildContext context) { 
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUser) {
          // Once we have the user, fetch teacher data
          context.read<ProfileBloc>().add(GetTeacherData(uid: state.user.uid));
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ProfileFailure) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        Teacher? teacher;
        if (state is TeacherDataLoaded) {
          teacher = state.teacher;
        }

        return _buildProfileContent(teacher);
      },
    );
  }

  Widget _buildProfileContent(Teacher? teacher) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: FadeInSlide(
                  child: Column(
                    children: [
                      // Action Buttons Row
                      if (teacher != null)
                        Builder(builder: (context) {
                          final cs = Theme.of(context).colorScheme;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ScaleInAnimation(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cs.onPrimary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.edit_rounded,
                                      color: cs.onPrimary,
                                    ),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditTeacherProfilePage(
                                            teacher: teacher,
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        // Refresh profile data after edit
                                        context.read<ProfileBloc>().add(GetCurrentUser());
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ScaleInAnimation(
                                delay: const Duration(milliseconds: 100),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cs.onPrimary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: cs.onPrimary,
                                    ),
                                    onSelected: (value) async {
                                      if (value == 'logout') {
                                        _showLogoutDialog();
                                      } else if (value == 'refresh') {
                                        context.read<ProfileBloc>().add(GetCurrentUser());
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'refresh',
                                        child: Row(
                                          children: [
                                            Icon(Icons.refresh, size: 20, color: cs.onSurface),
                                            const SizedBox(width: 12),
                                            Text('Refresh', style: TextStyle(color: cs.onSurface)),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'logout',
                                        child: Row(
                                          children: [
                                            Icon(Icons.logout, color: cs.error, size: 20),
                                            const SizedBox(width: 12),
                                            Text('Logout', style: TextStyle(color: cs.error)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).colorScheme.onPrimary, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                            child: teacher?.profilePic != null && teacher!.profilePic.isNotEmpty
                                ? CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(teacher.profilePic),
                                  )
                                : CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Theme.of(context).colorScheme.surface,
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        teacher != null
                            ? '${teacher.firstName} ${teacher.middleName} ${teacher.lastName}'
                            : 'Teacher Name',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        teacher?.email ?? 'teacher@example.com',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          teacher != null && teacher.subjects.isNotEmpty
                              ? '${teacher.subjects.join(", ")} Teacher'
                              : 'Teacher',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Verification Status Badge
                      if (teacher != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getStatusColor(teacher.verificationStatus),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _getStatusColor(teacher.verificationStatus).withOpacity(0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(teacher.verificationStatus),
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getStatusText(teacher.verificationStatus),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Profile Options
          Padding(
            padding: const EdgeInsets.all(20),
            child: StaggeredAnimation(
              children: [
                _buildProfileOption(
                  icon: Icons.edit_rounded,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  color: Colors.blue,
                  onTap: () {},
                ),
                
                const SizedBox(height: 12),
                
                _buildProfileOption(
                  icon: Icons.security_rounded,
                  title: 'Privacy Settings',
                  subtitle: 'Manage your privacy preferences',
                  color: Colors.purple,
                  onTap: () {},
                ),
                
                const SizedBox(height: 12),
                
                _buildProfileOption(
                  icon: Icons.settings_rounded,
                  title: 'App Settings',
                  subtitle: 'Customize app behavior',
                  color: Colors.orange,
                  onTap: () {},
                ),
                
                const SizedBox(height: 12),
                
                _buildProfileOption(
                  icon: Icons.help_rounded,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  color: Colors.green,
                  onTap: () {},
                ),
                
                const SizedBox(height: 12),
                
                _buildProfileOption(
                  icon: Icons.info_rounded,
                  title: 'About',
                  subtitle: 'App version and information',
                  color: Colors.indigo,
                  onTap: () {},
                ),
                
                const SizedBox(height: 24),
                
                // Stats Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Teaching Stats',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              icon: Icons.school_rounded,
                              value: '0',
                              label: 'Students',
                              color: Colors.blue,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              icon: Icons.class_rounded,
                              value: '0',
                              label: 'Classes',
                              color: Colors.purple,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              icon: Icons.assignment_rounded,
                              value: '0',
                              label: 'Assignments',
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedCard(
      onTap: onTap,
      child: Builder(builder: (context) {
        final tt = Theme.of(context).textTheme;
        final cs = Theme.of(context).colorScheme;
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
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
                  Text(title, style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: cs.onSurfaceVariant),
          ],
        );
      }),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Builder(builder: (context) {
      final tt = Theme.of(context).textTheme;
      final cs = Theme.of(context).colorScheme;
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(value, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 2),
          Text(label, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
      );
    });
  }

  // Helper methods for verification status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.verified_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'pending':
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Verified Teacher';
      case 'rejected':
        return 'Verification Rejected';
      case 'pending':
      default:
        return 'Verification Pending';
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ScaleInAnimation(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Confirm Logout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Are you sure you want to logout?',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthLoggedOut) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LandingPage(),
                      ),
                      (route) => false,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  
                  return ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogout());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
