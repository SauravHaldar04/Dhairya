import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LanguageLearnerLayoutPage extends StatefulWidget {
  const LanguageLearnerLayoutPage({super.key});

  @override
  State<LanguageLearnerLayoutPage> createState() => _LanguageLearnerLayoutPageState();
}

class _LanguageLearnerLayoutPageState extends State<LanguageLearnerLayoutPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: const Center(
        child: Text('Language Learner Layout Page'),
      ),
    );
  }
}