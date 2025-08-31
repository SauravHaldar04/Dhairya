import 'package:aparna_education/features/home/presentation/widgets/student_card.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:aparna_education/features/profile/presentation/pages/add_student_page.dart';
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
    // TODO: Navigate to student details/edit page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Student details for ${student.firstName}'),
        action: SnackBarAction(
          label: 'Edit',
          onPressed: () {
            // TODO: Implement edit functionality
            _showEditStudentDialog(student);
          },
        ),
      ),
    );
  }

  void _showEditStudentDialog(student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${student.firstName}'),
        content:
            const Text('Student editing feature will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to edit student page
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students Management'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddStudent,
            tooltip: 'Add Student',
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
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
                  // Header card with student count and add button
                  // Card(
                  //   margin: const EdgeInsets.all(16),
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(16),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Column(
                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //           children: [
                  //             const Text(
                  //               'Student Management',
                  //               style: TextStyle(
                  //                 fontSize: 18,
                  //                 fontWeight: FontWeight.bold,
                  //               ),
                  //             ),
                  //             TextButton.icon(
                  //               onPressed: _navigateToAddStudent,
                  //               icon: const Icon(Icons.add),
                  //               label: const Text('Add Student'),
                  //             ),
                  //           ],
                  //         ),
                  //         const SizedBox(height: 8),
                  //         const Text(
                  //           'Manage your children\'s education profiles',
                  //           style: TextStyle(color: Colors.grey),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  // Students list section
                  if (state is ProfileLoading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading students...'),
                        ],
                      ),
                    )
                  else if (state is StudentsLoaded) ...[
                    if (state.students.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Text(
                              'Your Students',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${state.students.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.students.length,
                        itemBuilder: (context, index) {
                          final student = state.students[index];
                          return StudentCard(
                            student: student,
                            onTap: () => _navigateToStudentDetails(student),
                          );
                        },
                      ),
                    ] else
                      Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Students Added Yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Add your children to start managing their education profiles',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _navigateToAddStudent,
                                icon: const Icon(Icons.add),
                                label: const Text('Add First Student'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ] else
                    // Initial state - show loading or empty
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Loading Students...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddStudent,
        tooltip: 'Add Student',
        child: const Icon(Icons.add),
      ),
    );
  }
}
