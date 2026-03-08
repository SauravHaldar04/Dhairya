import 'package:aparna_education/core/theme/app_theme.dart';
import 'package:aparna_education/features/auth/presentation/pages/landing_page.dart';
import 'package:aparna_education/features/profile/presentation/pages/language_learner_profile_completion.dart';
import 'package:aparna_education/features/profile/presentation/pages/parent_profile_completion.dart';
import 'package:aparna_education/features/profile/presentation/pages/teacher_profile_completion.dart';
import 'package:aparna_education/features/profile/presentation/widgets/profile_type_widget.dart';
import 'package:aparna_education/features/auth/presentation/widgets/auth_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aparna_education/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool teacherIsSelected = false;
  bool parentIsSelected = false;
  bool languageLearnerIsSelected = false;

  bool get _hasSelection =>
      teacherIsSelected || parentIsSelected || languageLearnerIsSelected;

  void _onSelect(ProfileType type) {
    setState(() {
      teacherIsSelected = type == ProfileType.teacher;
      parentIsSelected = type == ProfileType.parent;
      languageLearnerIsSelected = type == ProfileType.languagelearner;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Top row with logout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    'Choose your role',
                    style: theme.textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogout());
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const LandingPage(),
                        ),
                      );
                    },
                    icon: Icon(
                      PhosphorIcons.signOut(),
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Header
              Text(
                'How will you\nuse Dhairya?',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your profile type to get started.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 32),

              // Profile cards
              GestureDetector(
                onTap: () => _onSelect(ProfileType.teacher),
                child: ProfileTypeWidget(
                  isSelected: teacherIsSelected,
                  profileType: ProfileType.teacher,
                  imageUrl: 'assets/images/teacher.png',
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => _onSelect(ProfileType.parent),
                child: ProfileTypeWidget(
                  isSelected: parentIsSelected,
                  profileType: ProfileType.parent,
                  imageUrl: 'assets/images/student.png',
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => _onSelect(ProfileType.languagelearner),
                child: ProfileTypeWidget(
                  isSelected: languageLearnerIsSelected,
                  profileType: ProfileType.languagelearner,
                  imageUrl: 'assets/images/learner.png',
                ),
              ),

              const Spacer(),

              // Get Started button
              AuthButton(
                text: 'Get Started',
                icon: _hasSelection ? PhosphorIcons.arrowRight(PhosphorIconsStyle.bold) : null,
                onPressed: _hasSelection
                    ? () {
                        Widget page;
                        if (teacherIsSelected) {
                          page = const TeacherProfileCompletion();
                        } else if (parentIsSelected) {
                          page = const ParentProfileCompletion();
                        } else {
                          page = const LanguageLearnerProfileCompletion();
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => page),
                        );
                      }
                    : null,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
