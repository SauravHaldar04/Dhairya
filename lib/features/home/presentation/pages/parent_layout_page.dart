import 'package:aparna_education/features/home/presentation/pages/parent_home_page.dart';
import 'package:aparna_education/features/profile/presentation/pages/parent_profile_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ParentLayoutPage extends StatefulWidget {
  const ParentLayoutPage({Key? key}) : super(key: key);

  @override
  State<ParentLayoutPage> createState() => _ParentLayoutPageState();
}

class _ParentLayoutPageState extends State<ParentLayoutPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ParentHomePage(),
    const ParentProfilePage(),
    const Center(child: Text('Lectures')),
    const Center(child: Text('Calendar')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Lectures',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }
}
