import 'package:aparna_education/core/widgets/project_button.dart';
import 'package:aparna_education/features/auth/presentation/pages/landing_page.dart';
import 'package:aparna_education/features/profile/presentation/pages/language_learner_profile_completion.dart';
import 'package:aparna_education/features/profile/presentation/pages/parent_profile_completion.dart';
import 'package:aparna_education/features/profile/presentation/pages/teacher_profile_completion.dart';
import 'package:aparna_education/features/profile/presentation/widgets/profile_type_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool teacherIsSelected = false;
  bool parentIsSelected = false;
  bool languageLearnerIsSelected = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile Selection',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement((MaterialPageRoute(
                    builder: (context) => const LandingPage())));
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        if (teacherIsSelected) {
                          setState(() {
                            teacherIsSelected = false;
                          });
                          return;
                        }
                        setState(() {
                          teacherIsSelected = true;
                          parentIsSelected = false;
                          languageLearnerIsSelected = false;
                        });
                      },
                      child: ProfileTypeWidget(
                        isSelected: teacherIsSelected,
                        profileType: ProfileType.teacher,
                        imageUrl: 'assets/images/teacher.png',
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        if (parentIsSelected) {
                          setState(() {
                            parentIsSelected = false;
                          });
                          return;
                        }
                        setState(() {
                          parentIsSelected = true;
                          teacherIsSelected = false;
                          languageLearnerIsSelected = false;
                        });
                      },
                      child: ProfileTypeWidget(
                        isSelected: parentIsSelected,
                        profileType: ProfileType.parent,
                        imageUrl: 'assets/images/student.png',
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        if (languageLearnerIsSelected) {
                          setState(() {
                            languageLearnerIsSelected = false;
                          });
                          return;
                        }
                        setState(() {
                          languageLearnerIsSelected = true;
                          teacherIsSelected = false;
                          parentIsSelected = false;
                        });
                      },
                      child: ProfileTypeWidget(
                        isSelected: languageLearnerIsSelected,
                        profileType: ProfileType.languagelearner,
                        imageUrl: 'assets/images/learner.png',
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.8,
                  left: MediaQuery.of(context).size.width * 0.2,
                  right: MediaQuery.of(context).size.width * 0.2,
                  child: ProjectButton(
                      text: "Get Started",
                      onPressed: !teacherIsSelected &&
                              !parentIsSelected &&
                              !languageLearnerIsSelected
                          ? () {}
                          : () {
                              if (teacherIsSelected) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const TeacherProfileCompletion()));
                              } else if (parentIsSelected) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const ParentProfileCompletion()));
                              } else if (languageLearnerIsSelected) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const LanguageLearnerProfileCompletion()));
                              }
                            },
                      isInverted: !teacherIsSelected &&
                              !parentIsSelected &&
                              !languageLearnerIsSelected
                          ? true
                          : false)),
            ],
          ),
        ),
      ),
    );
  }
}
