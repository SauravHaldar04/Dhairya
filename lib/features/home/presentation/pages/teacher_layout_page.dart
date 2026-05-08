import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aparna_education/core/widgets/app_loading.dart';
import 'package:aparna_education/features/profile/presentation/pages/teacher_home_page.dart';
import 'package:aparna_education/features/profile/presentation/pages/teacher_students_page.dart';
import 'package:aparna_education/features/profile/presentation/pages/teacher_reports_page.dart';
import 'package:aparna_education/features/profile/presentation/pages/teacher_profile_page.dart';
import 'package:aparna_education/features/profile/presentation/pages/teacher_pending_verification_page.dart';
import 'package:aparna_education/features/profile/presentation/pages/teacher_rejected_page.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:aparna_education/features/lectures/presentation/pages/teacher_lectures_home_page.dart';
import 'package:aparna_education/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:aparna_education/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:aparna_education/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:aparna_education/features/notifications/presentation/pages/notifications_page.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/bloc/teacher_interest_bloc.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/bloc/teacher_interest_event.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class _TeacherDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _TeacherDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

class TeacherLayoutPage extends StatefulWidget {
  const TeacherLayoutPage({super.key});

  @override
  State<TeacherLayoutPage> createState() => _TeacherLayoutPageState();
}

class _TeacherLayoutPageState extends State<TeacherLayoutPage> 
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _hasRequestedTeacherData = false;
  String? _bootstrappedTeacherUid;

  static const List<_TeacherDestination> _destinations = [
    _TeacherDestination(
      label: 'Home',
      icon: PhosphorIconsRegular.house,
      selectedIcon: PhosphorIconsFill.house,
    ),
    _TeacherDestination(
      label: 'Students',
      icon: PhosphorIconsRegular.users,
      selectedIcon: PhosphorIconsFill.users,
    ),
    _TeacherDestination(
      label: 'Lectures',
      icon: PhosphorIconsRegular.chalkboardTeacher,
      selectedIcon: PhosphorIconsFill.chalkboardTeacher,
    ),
    _TeacherDestination(
      label: 'Reports',
      icon: PhosphorIconsRegular.chartBar,
      selectedIcon: PhosphorIconsFill.chartBar,
    ),
    _TeacherDestination(
      label: 'Profile',
      icon: PhosphorIconsRegular.userCircle,
      selectedIcon: PhosphorIconsFill.userCircle,
    ),
  ];

  // Teacher dashboard sections with teacherUid
  List<Widget> _getPages(String teacherUid) => [
    TeacherHomePage(teacherUid: teacherUid),
    TeacherStudentsPage(teacherUid: teacherUid), 
    TeacherLecturesHomePage(teacherUid: teacherUid),
    TeacherReportsPage(),
    TeacherProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Fetch teacher data to check verification status
    context.read<ProfileBloc>().add(GetCurrentUser());
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _bootstrapTeacher(String teacherUid) {
    if (_bootstrappedTeacherUid == teacherUid) return;
    _bootstrappedTeacherUid = teacherUid;

    context.read<NotificationsBloc>().add(FetchUserNotifications(teacherUid));
    context.read<TeacherInterestBloc>().add(FetchPendingInterests(teacherUid));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
        
        // When user data is loaded, fetch teacher data (only once)
        if (state is ProfileUser && !_hasRequestedTeacherData) {
          _hasRequestedTeacherData = true;
          context.read<ProfileBloc>().add(GetTeacherData(uid: state.user.uid));
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) {
          return Scaffold(body: AppLoading.fullScreen());
        }
        
        // Check verification status for teachers
        if (state is TeacherDataLoaded) {
          final teacher = state.teacher;
          final verificationStatus = teacher.verificationStatus;
          
          if (verificationStatus == 'pending') {
            return const TeacherPendingVerificationPage();
          } else if (verificationStatus == 'rejected') {
            return TeacherRejectedPage(
              rejectionReason: teacher.rejectionReason ?? 
                'Your application did not meet our requirements.',
              teacher: teacher,
            );
          }
          // If approved, continue with normal dashboard - render with teacher UID
          _bootstrapTeacher(teacher.uid);
          return _buildDashboard(teacher.uid);
        }
        
        // For ProfileUser state without teacher data yet loaded
        if (state is ProfileUser) {
          _bootstrapTeacher(state.user.uid);
          return _buildDashboard(state.user.uid);
        }
        
        // Default loading state
        return Scaffold(body: AppLoading.fullScreen());
      },
    );
  }
  
  Widget _buildDashboard(String teacherUid) {
    final cs = Theme.of(context).colorScheme;

    Widget content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: _getPages(teacherUid)[_selectedIndex],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        if (isWide) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_destinations[_selectedIndex].label),
              actions: [
                _NotificationsAction(userId: teacherUid),
                const SizedBox(width: 8),
              ],
            ),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  labelType: NavigationRailLabelType.all,
                  destinations: _destinations
                      .map(
                        (d) => NavigationRailDestination(
                          icon: Icon(d.icon),
                          selectedIcon: Icon(d.selectedIcon),
                          label: Text(d.label),
                        ),
                      )
                      .toList(),
                ),
                VerticalDivider(width: 1, thickness: 1, color: cs.outlineVariant),
                Expanded(child: content),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_destinations[_selectedIndex].label),
            actions: [
              _NotificationsAction(userId: teacherUid),
              const SizedBox(width: 8),
            ],
          ),
          drawer: NavigationDrawer(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              _onItemTapped(index);
              Navigator.of(context).pop();
            },
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Teacher',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              ..._destinations.map(
                (d) => NavigationDrawerDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label),
                ),
              ),
            ],
          ),
          body: content,
        );
      },
    );
  }
}

class _NotificationsAction extends StatelessWidget {
  final String userId;

  const _NotificationsAction({required this.userId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        int unreadCount = 0;
        if (state is NotificationsLoaded) {
          unreadCount = state.notifications.where((n) => !n.isRead).length;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Notifications',
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsPage(userId: userId),
                  ),
                );
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.error,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: cs.surface, width: 1.5),
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onError,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
