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
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TeacherLayoutPage extends StatefulWidget {
  const TeacherLayoutPage({super.key});

  @override
  State<TeacherLayoutPage> createState() => _TeacherLayoutPageState();
}

class _TeacherLayoutPageState extends State<TeacherLayoutPage> 
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabController;
  bool _hasRequestedTeacherData = false;

  // Teacher dashboard sections with teacherUid
  List<Widget> _getPages(String teacherUid) => [
    const TeacherHomePage(),
    const TeacherStudentsPage(), 
    TeacherLecturesHomePage(teacherUid: teacherUid),
    const TeacherReportsPage(),
    const TeacherProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabController.forward();
    
    // Fetch teacher data to check verification status
    context.read<ProfileBloc>().add(GetCurrentUser());
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _fabController.reset();
    _fabController.forward();
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
          return _buildDashboard(teacher.uid);
        }
        
        // For ProfileUser state without teacher data yet loaded
        if (state is ProfileUser) {
          return _buildDashboard(state.user.uid);
        }
        
        // Default loading state
        return Scaffold(body: AppLoading.fullScreen());
      },
    );
  }
  
  Widget _buildDashboard(String teacherUid) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: _getPages(teacherUid)[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.house),
            selectedIcon: Icon(PhosphorIconsFill.house),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.users),
            selectedIcon: Icon(PhosphorIconsFill.users),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.chalkboardTeacher),
            selectedIcon: Icon(PhosphorIconsFill.chalkboardTeacher),
            label: 'Lectures',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.chartBar),
            selectedIcon: Icon(PhosphorIconsFill.chartBar),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.userCircle),
            selectedIcon: Icon(PhosphorIconsFill.userCircle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
