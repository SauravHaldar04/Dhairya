import 'package:aparna_education/core/widgets/animations.dart';
import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/features/home/presentation/widgets/student_card.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:aparna_education/features/profile/presentation/pages/add_student_page.dart';
import 'package:aparna_education/features/profile/presentation/pages/edit_student_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  @override
  void initState() {
    super.initState();
    // Get current user and their students
    context.read<ProfileBloc>().add(GetCurrentUser());
  }

  void _navigateToAddStudent() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const AddStudentPage(),
      ),
    )
        .then((_) {
      // Refresh students list when returning from add student page
      context.read<ProfileBloc>().add(GetCurrentUser());
    });
  }

  void _navigateToStudentDetails(student) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => EditStudentProfilePage(student: student),
      ),
    )
        .then((updated) {
      // Refresh students list if student was updated
      if (updated == true) {
        context.read<ProfileBloc>().add(GetCurrentUser());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with search
          Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade50,
                  Colors.blue.shade100,
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Students',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    ScaleInAnimation(
                      child: FloatingActionButton.small(
                        heroTag: "add_student_header",
                        onPressed: _navigateToAddStudent,
                        backgroundColor: Pallete.primaryColor,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search students...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is ProfileUser) {
                  // Once we get current user, fetch their students
                  context
                      .read<ProfileBloc>()
                      .add(GetStudentsbyParent(uid: state.user.uid));
                }
              },
              builder: (context, state) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProfileBloc>().add(GetCurrentUser());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        if (state is ProfileLoading)
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: FadeInSlide(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(
                                    color: Pallete.primaryColor,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Loading students...',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (state is StudentsLoaded) ...[
                          if (state.students.isNotEmpty) ...[
                            // Students count header
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  const Text(
                                    'Your Students',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Pallete.primaryColor,
                                          Pallete.primaryColor.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${state.students.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Students list
                            StaggeredAnimation(
                              children: List.generate(
                                state.students.length,
                                (index) {
                                  final student = state.students[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                    child: StudentCard(
                                      student: student,
                                      onTap: () => _navigateToStudentDetails(student),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ] else
                            // Empty state
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: FadeInSlide(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.people_outline,
                                          size: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'No Students Added Yet',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add your children to start managing\ntheir education profiles',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      AnimatedCard(
                                        onTap: _navigateToAddStudent,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Pallete.primaryColor,
                                                Pallete.primaryColor.withOpacity(0.8),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.person_add, color: Colors.white),
                                              SizedBox(width: 12),
                                              Text(
                                                'Add First Student',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ] else
                          // Initial loading state
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: FadeInSlide(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.people_outline,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Loading Students...',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 100), // Space for FAB
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleInAnimation(
        child: FloatingActionButton.extended(
          onPressed: _navigateToAddStudent,
          backgroundColor: Pallete.primaryColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text(
            'Add Student',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
