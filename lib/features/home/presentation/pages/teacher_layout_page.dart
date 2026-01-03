import 'package:aparna_education/features/auth/presentation/pages/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aparna_education/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aparna_education/core/widgets/custom_loader.dart';
import 'package:aparna_education/core/widgets/animations.dart';
import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/features/profile/presentation/pages/teacher_home_page.dart';
import 'package:aparna_education/features/profile/presentation/pages/teacher_students_page.dart';
import 'package:aparna_education/features/profile/presentation/pages/teacher_classes_page.dart';
import 'package:aparna_education/features/profile/presentation/pages/teacher_reports_page.dart';
import 'package:aparna_education/features/profile/presentation/pages/teacher_profile_page.dart';
import 'package:aparna_education/features/profile/presentation/pages/teacher_pending_verification_page.dart';
import 'package:aparna_education/features/profile/presentation/pages/teacher_rejected_page.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';

class TeacherLayoutPage extends StatefulWidget {
  const TeacherLayoutPage({super.key});

  @override
  State<TeacherLayoutPage> createState() => _TeacherLayoutPageState();
}

class _TeacherLayoutPageState extends State<TeacherLayoutPage> 
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabController;

  // Placeholder pages for teacher dashboard sections
  final List<Widget> _pages = [
    const TeacherHomePage(),
    const TeacherStudentsPage(), 
    const TeacherClassesPage(),
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

  Future<void> _handleLogout() async {
    // Show modern confirmation dialog
    bool? shouldLogout = await showDialog<bool>(
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
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Confirm Logout',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Are you sure you want to logout? You will need to sign in again to access your account.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        );
      },
    );

    if (shouldLogout == true) {
      try {
        // Show loading overlay
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomLoader(size: 50),
                    SizedBox(height: 16),
                    Text('Logging out...'),
                  ],
                ),
              ),
            ),
          ),
        );

        context.read<AuthBloc>().add(AuthLogout());
        
        // Small delay for better UX
        await Future.delayed(const Duration(milliseconds: 800));
        
        if (context.mounted) {
          // Navigate to landing page - this will clear all routes including the loading dialog
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LandingPage(),
            ),
            (route) => false,
          );
        }
      } catch (error) {
        Navigator.of(context).pop(); // Close loading dialog
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $error'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
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
        
        // When user data is loaded, fetch teacher data
        if (state is ProfileUser) {
          context.read<ProfileBloc>().add(GetTeacherData(uid: state.user.uid));
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            body: CustomLoader(),
          );
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
            );
          }
          // If approved, continue with normal dashboard
        }
        
        return Scaffold(
          appBar: AppBar(
            title: FadeInSlide(
              delay: const Duration(milliseconds: 200),
              child: const Text('Teacher Dashboard'),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Pallete.primaryColor.withOpacity(0.1),
                    Colors.white,
                  ],
                ),
              ),
            ),
            actions: [
          ScaleInAnimation(
            delay: const Duration(milliseconds: 400),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _handleLogout,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Pallete.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Pallete.primaryColor.withOpacity(0.05),
              Colors.white,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: _pages[_selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            selectedItemColor: Pallete.primaryColor,
            unselectedItemColor: Colors.grey.shade600,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            iconSize: 24,
            items: [
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(_selectedIndex == 0 ? 8 : 4),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0
                        ? Pallete.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.home_rounded),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(_selectedIndex == 1 ? 8 : 4),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 1
                        ? Pallete.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.people_rounded),
                ),
                label: 'Students',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(_selectedIndex == 2 ? 8 : 4),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 2
                        ? Pallete.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.class_rounded),
                ),
                label: 'Classes',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(_selectedIndex == 3 ? 8 : 4),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 3
                        ? Pallete.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.assessment_rounded),
                ),
                label: 'Reports',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(_selectedIndex == 4 ? 8 : 4),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 4
                        ? Pallete.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_rounded),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}
