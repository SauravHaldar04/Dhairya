import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TeacherLayoutPage extends StatefulWidget {
  const TeacherLayoutPage({super.key});

  @override
  State<TeacherLayoutPage> createState() => _TeacherLayoutPageState();
}

class _TeacherLayoutPageState extends State<TeacherLayoutPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: const Center(
        child: Text('Teacher Layout Page'),
      ),
    );
  }
}
