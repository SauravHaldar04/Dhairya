import 'package:aparna_education/core/theme/theme.dart';
import 'package:aparna_education/features/auth/view/pages/landing_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aparna Education',
      theme: AppTheme.appTheme,
      home: const LandingPage(),
    );
  }
}
