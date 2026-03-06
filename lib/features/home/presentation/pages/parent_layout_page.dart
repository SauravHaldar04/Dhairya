import 'package:aparna_education/core/widgets/animations.dart';
import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aparna_education/features/home/presentation/pages/parent_home_page.dart';
import 'package:aparna_education/features/profile/presentation/pages/parent_profile_page_new.dart';
import 'package:aparna_education/features/profile/presentation/pages/students_page.dart';
import 'package:aparna_education/features/parents/lectures/presentation/pages/parent_lectures_home_page.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:aparna_education/features/auth/presentation/pages/landing_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParentLayoutPage extends StatefulWidget {
  const ParentLayoutPage({Key? key}) : super(key: key);

  @override
  State<ParentLayoutPage> createState() => _ParentLayoutPageState();
}

class _ParentLayoutPageState extends State<ParentLayoutPage> 
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  List<Widget> _getPages(String parentUid) => [
    const ParentHomePage(),
    const StudentsPage(),
    const ModernParentProfilePage(),
    ParentLecturesHomePage(parentUid: parentUid),
    const Center(child: Text('Calendar - Coming Soon')),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Fetch current user
    context.read<ProfileBloc>().add(GetCurrentUser());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
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
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Parent Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Monitor your child\'s progress',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(
                icon: Icons.home_rounded,
                title: 'Home',
                index: 0,
                isSelected: _selectedIndex == 0,
              ),
              _buildDrawerItem(
                icon: Icons.people_rounded,
                title: 'Students',
                index: 1,
                isSelected: _selectedIndex == 1,
              ),
              _buildDrawerItem(
                icon: Icons.person_rounded,
                title: 'Profile',
                index: 2,
                isSelected: _selectedIndex == 2,
              ),
              _buildDrawerItem(
                icon: Icons.school_rounded,
                title: 'Lectures',
                index: 3,
                isSelected: _selectedIndex == 3,
              ),
              _buildDrawerItem(
                icon: Icons.calendar_today_rounded,
                title: 'Calendar',
                index: 4,
                isSelected: _selectedIndex == 4,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: _showLogoutDialog,
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (previous, current) {
          // Only rebuild when transitioning to ProfileUser
          return current is ProfileUser;
        },
        builder: (context, state) {
          if (state is ProfileUser) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _getPages(state.user.uid)[_selectedIndex],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Pallete.primaryColor,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
          ),
          elevation: 0,
          items: [
            _buildBottomNavItem(Icons.home_rounded, 'Home', 0),
            _buildBottomNavItem(Icons.people_rounded, 'Students', 1),
            _buildBottomNavItem(Icons.person_rounded, 'Profile', 2),
            _buildBottomNavItem(Icons.school_rounded, 'Lectures', 3),
            _buildBottomNavItem(Icons.calendar_today_rounded, 'Calendar', 4),
          ],
      ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    required bool isSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected 
          ? Pallete.primaryColor.withOpacity(0.1) 
          : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
              ? Pallete.primaryColor.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected 
              ? Pallete.primaryColor 
              : Colors.grey.shade600,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected 
              ? Pallete.primaryColor 
              : Colors.grey.shade700,
            fontWeight: isSelected 
              ? FontWeight.w600 
              : FontWeight.w500,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(
    IconData icon, 
    String label, 
    int index,
  ) {
    final isSelected = _selectedIndex == index;
    
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected 
            ? Pallete.primaryColor.withOpacity(0.1)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}
