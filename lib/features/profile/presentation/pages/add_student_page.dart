import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/core/widgets/project_button.dart';
import 'package:aparna_education/core/widgets/project_textfield.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({Key? key}) : super(key: key);

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController standardController = TextEditingController();

  // Subject management
  final TextEditingController subjectController = TextEditingController();
  final List<String> subjects = [];

  String selectedBoard = 'CBSE';
  String selectedMedium = 'English';

  // Board options
  final List<String> boards = ['CBSE', 'ICSE', 'State Board', 'IB'];

  // Medium options
  final List<String> mediums = ['English', 'Hindi', 'Regional'];

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    standardController.dispose();
    subjectController.dispose();
    super.dispose();
  }

  void _addSubject() {
    final subject = subjectController.text.trim();
    if (subject.isNotEmpty && !subjects.contains(subject)) {
      setState(() {
        subjects.add(subject);
        subjectController.clear();
      });
    }
  }

  void _removeSubject(String subject) {
    setState(() {
      subjects.remove(subject);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          } else if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name fields
                  ProjectTextfield(
                    controller: firstNameController,
                    text: 'First Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  ProjectTextfield(
                    controller: middleNameController,
                    text: 'Middle Name',
                  ),
                  const SizedBox(height: 16),

                  ProjectTextfield(
                    controller: lastNameController,
                    text: 'Last Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Education Information
                  const Text(
                    'Education Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ProjectTextfield(
                    controller: standardController,
                    text: 'Standard/Grade',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter standard/grade';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Board Selection
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Board',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedBoard,
                    items: boards
                        .map((board) => DropdownMenuItem(
                              value: board,
                              child: Text(board),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBoard = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a board';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Medium Selection
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Medium',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedMedium,
                    items: mediums
                        .map((medium) => DropdownMenuItem(
                              value: medium,
                              child: Text(medium),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMedium = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select medium';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Subjects
                  const Text(
                    'Subjects',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: ProjectTextfield(
                          controller: subjectController,
                          text: 'Enter a subject',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addSubject,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (subjects.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No subjects added yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: subjects
                          .map((subject) => Chip(
                                label: Text(subject),
                                deleteIcon: const Icon(Icons.clear, size: 16),
                                onDeleted: () => _removeSubject(subject),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 32),

                  // Submit Button
                  ProjectButton(
                    text: 'Add Student',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (subjects.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please add at least one subject'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        context.read<ProfileBloc>().add(AddStudentProfile(
                              firstName: firstNameController.text,
                              middleName: middleNameController.text,
                              lastName: lastNameController.text,
                              standard: standardController.text,
                              subjects: subjects,
                              board: selectedBoard,
                              medium: selectedMedium,
                            ));
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
