import 'package:aparna_education/core/widgets/app_loading.dart';
import 'package:aparna_education/features/home/presentation/pages/parent_home_page.dart';
import 'package:aparna_education/features/profile/presentation/pages/parent_profile_page_new.dart';
import 'package:aparna_education/features/profile/presentation/pages/students_page.dart';
import 'package:aparna_education/features/parents/lectures/presentation/pages/parent_lectures_home_page.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ParentLayoutPage extends StatefulWidget {
  const ParentLayoutPage({Key? key}) : super(key: key);

  @override
  State<ParentLayoutPage> createState() => _ParentLayoutPageState();
}

class _ParentLayoutPageState extends State<ParentLayoutPage> {
  int _selectedIndex = 0;

  List<Widget> _getPages(String parentUid) => [
    const ParentHomePage(),
    const StudentsPage(),
    ParentLecturesHomePage(parentUid: parentUid),
    const Center(child: Text('Calendar — Coming Soon')),
    const ModernParentProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(GetCurrentUser());
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) => current is ProfileUser,
      builder: (context, state) {
        if (state is ProfileUser) {
          return _buildDashboard(state.user.uid);
        }
        return Scaffold(body: AppLoading.fullScreen());
      },
    );
  }

  Widget _buildDashboard(String parentUid) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: _getPages(parentUid)[_selectedIndex],
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
            icon: Icon(PhosphorIconsRegular.calendarBlank),
            selectedIcon: Icon(PhosphorIconsFill.calendarBlank),
            label: 'Calendar',
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
