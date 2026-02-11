import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/core/widgets/custom_loader.dart';
import 'package:aparna_education/features/lectures/presentation/bloc/lectures_bloc.dart';
import 'package:intl/intl.dart';

class ParentStudentAssignmentsPage extends StatefulWidget {
  final String parentUid;

  const ParentStudentAssignmentsPage({
    Key? key,
    required this.parentUid,
  }) : super(key: key);

  @override
  State<ParentStudentAssignmentsPage> createState() => _ParentStudentAssignmentsPageState();
}

class _ParentStudentAssignmentsPageState extends State<ParentStudentAssignmentsPage> {
  String? selectedStudentUid;

  @override
  void initState() {
    super.initState();
    // Load assignments when student is selected
  }

  void _loadAssignments() {
    if (selectedStudentUid != null) {
      context.read<LecturesBloc>().add(GetStudentAssignmentsEvent(selectedStudentUid!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Pallete.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Student Assignments',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Select Student'),
                  value: selectedStudentUid,
                  items: const [
                    DropdownMenuItem(value: 'student1', child: Text('Student 1')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedStudentUid = value);
                    _loadAssignments();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<LecturesBloc, LecturesState>(
              builder: (context, state) {
                if (state is LecturesLoading) {
                  return const Center(child: CustomLoader());
                }

                if (state is StudentAssignmentsLoaded) {
                  if (state.assignments.isEmpty) {
                    return const Center(child: Text('No assignments found'));
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadAssignments(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.assignments.length,
                      itemBuilder: (context, index) {
                        final assignment = state.assignments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Pallete.primaryColor.withOpacity(0.1),
                                      child: Icon(Icons.person, color: Pallete.primaryColor),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Teacher: ${assignment.teacherUid}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            assignment.subjects.join(', '),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Assigned: ${DateFormat('MMM dd, yyyy').format(assignment.createdAt)}',
                                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                return Center(
                  child: Text(
                    selectedStudentUid == null ? 'Select a student to view assignments' : 'No assignments found',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
