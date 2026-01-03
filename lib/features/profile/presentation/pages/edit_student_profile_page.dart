import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:aparna_education/features/profile/domain/entities/student_entity.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:aparna_education/core/theme/app_pallete.dart';

class EditStudentProfilePage extends StatefulWidget {
  final Student student;

  const EditStudentProfilePage({Key? key, required this.student})
      : super(key: key);

  @override
  State<EditStudentProfilePage> createState() => _EditStudentProfilePageState();
}

class _EditStudentProfilePageState extends State<EditStudentProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _standardController = TextEditingController();

  String? _selectedBoard;
  String? _selectedMedium;
  File? _selectedImage;
  bool _isLoading = false;
  
  List<String> _selectedSubjects = [];
  
  final List<String> _availableSubjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Hindi',
    'Computer Science',
    'History',
    'Geography',
    'Economics',
    'Accountancy',
    'Environmental Science',
    'Social Studies',
    'Sanskrit',
  ];
  
  final List<String> _availableBoards = [
    'CBSE',
    'ICSE',
    'State Board',
    'IB',
    'Cambridge',
  ];

  final List<String> _availableMediums = [
    'English',
    'Hindi',
    'Regional Language',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _firstNameController.text = widget.student.firstName;
    _middleNameController.text = widget.student.middleName;
    _lastNameController.text = widget.student.lastName;
    _standardController.text = widget.student.standard;
    _selectedBoard = widget.student.board;
    _selectedMedium = widget.student.medium;
    _selectedSubjects = List.from(widget.student.subjects);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _standardController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    }
  }

  void _showSubjectsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        List<String> tempSelected = List.from(_selectedSubjects);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Subjects'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _availableSubjects.map((subject) {
                    return CheckboxListTile(
                      title: Text(subject),
                      value: tempSelected.contains(subject),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            tempSelected.add(subject);
                          } else {
                            tempSelected.remove(subject);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedSubjects = tempSelected;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      if (_selectedSubjects.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one subject')),
        );
        return;
      }

      context.read<ProfileBloc>().add(
            UpdateStudentProfile(
              studentId: widget.student.uid,
              firstName: _firstNameController.text.trim(),
              middleName: _middleNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              standard: _standardController.text.trim(),
              subjects: _selectedSubjects,
              board: _selectedBoard!,
              medium: _selectedMedium!,
              profilePic: _selectedImage,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Student Profile'),
        elevation: 0,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is ProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate success
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Picture Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Pallete.primaryColor.withOpacity(0.1),
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (widget.student.profilePic != null
                                  ? NetworkImage(widget.student.profilePic!)
                                  : null) as ImageProvider?,
                          child: _selectedImage == null && widget.student.profilePic == null
                              ? const Icon(Icons.person, size: 60, color: Pallete.primaryColor)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Pallete.primaryColor,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Personal Information
                  Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Pallete.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _middleNameController,
                    decoration: const InputDecoration(
                      labelText: 'Middle Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Academic Information
                  Text(
                    'Academic Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Pallete.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _standardController,
                    decoration: const InputDecoration(
                      labelText: 'Standard/Grade',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                      hintText: 'e.g., 10th, 12th',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter standard';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Subjects Selection
                  InkWell(
                    onTap: _showSubjectsDialog,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Subjects',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book),
                      ),
                      child: _selectedSubjects.isEmpty
                          ? const Text('Tap to select subjects',
                              style: TextStyle(color: Colors.grey))
                          : Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: _selectedSubjects
                                  .map((subject) => Chip(
                                        label: Text(subject, style: const TextStyle(fontSize: 12)),
                                        backgroundColor: Pallete.primaryColor.withOpacity(0.1),
                                      ))
                                  .toList(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedBoard,
                    decoration: const InputDecoration(
                      labelText: 'Board',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    items: _availableBoards
                        .map((board) => DropdownMenuItem(
                              value: board,
                              child: Text(board),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBoard = value;
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

                  DropdownButtonFormField<String>(
                    value: _selectedMedium,
                    decoration: const InputDecoration(
                      labelText: 'Medium of Instruction',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language),
                    ),
                    items: _availableMediums
                        .map((medium) => DropdownMenuItem(
                              value: medium,
                              child: Text(medium),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMedium = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select medium of instruction';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Update Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Pallete.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Update Profile',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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
