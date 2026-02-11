import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:aparna_education/features/profile/domain/entities/teacher_entity.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:aparna_education/core/theme/app_pallete.dart';

class EditTeacherProfilePage extends StatefulWidget {
  final Teacher teacher;

  const EditTeacherProfilePage({Key? key, required this.teacher})
      : super(key: key);

  @override
  State<EditTeacherProfilePage> createState() => _EditTeacherProfilePageState();
}

class _EditTeacherProfilePageState extends State<EditTeacherProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _workExpController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;
  File? _selectedImage;
  File? _selectedResume;
  bool _isLoading = false;
  
  List<String> _selectedSubjects = [];
  List<String> _selectedBoards = [];
  
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
  ];
  
  final List<String> _availableBoards = [
    'CBSE',
    'ICSE',
    'State Board',
    'IB',
    'Cambridge',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _firstNameController.text = widget.teacher.firstName;
    _middleNameController.text = widget.teacher.middleName;
    _lastNameController.text = widget.teacher.lastName;
    _phoneNumberController.text = widget.teacher.phoneNumber;
    _addressController.text = widget.teacher.address;
    _cityController.text = widget.teacher.city;
    _stateController.text = widget.teacher.state;
    _countryController.text = widget.teacher.country;
    _pincodeController.text = widget.teacher.pincode;
    _workExpController.text = widget.teacher.workExp;
    _selectedGender = widget.teacher.gender;
    _selectedDate = widget.teacher.dob;
    _selectedSubjects = List.from(widget.teacher.subjects);
    _selectedBoards = List.from(widget.teacher.board);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pincodeController.dispose();
    _workExpController.dispose();
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

  Future<void> _pickResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _selectedResume = File(result.files.single.path!);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resume selected: ${result.files.single.name}')),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedSubjects = tempSelected;
                    });
                    Navigator.pop(context);
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

  void _showBoardsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        List<String> tempSelected = List.from(_selectedBoards);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Boards'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _availableBoards.map((board) {
                    return CheckboxListTile(
                      title: Text(board),
                      value: tempSelected.contains(board),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            tempSelected.add(board);
                          } else {
                            tempSelected.remove(board);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedBoards = tempSelected;
                    });
                    Navigator.pop(context);
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
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date of birth')),
        );
        return;
      }

      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select gender')),
        );
        return;
      }

      if (_selectedSubjects.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one subject')),
        );
        return;
      }

      if (_selectedBoards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one board')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      context.read<ProfileBloc>().add(
            UpdateTeacherProfile(
              firstName: _firstNameController.text.trim(),
              middleName: _middleNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phoneNumber: _phoneNumberController.text.trim(),
              address: _addressController.text.trim(),
              city: _cityController.text.trim(),
              state: _stateController.text.trim(),
              country: _countryController.text.trim(),
              pincode: _pincodeController.text.trim(),
              workExp: _workExpController.text.trim(),
              gender: _selectedGender!,
              dob: _selectedDate!,
              subjects: _selectedSubjects,
              board: _selectedBoards,
              profilePic: _selectedImage,
              resume: _selectedResume,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Pallete.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          setState(() {
            _isLoading = false;
          });

          if (state is ProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Pop all routes and let the layout page handle routing based on verification status
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!) as ImageProvider
                              : widget.teacher.profilePic.isNotEmpty
                                  ? NetworkImage(widget.teacher.profilePic) as ImageProvider
                                  : null,
                          child: _selectedImage == null &&
                                  widget.teacher.profilePic.isEmpty
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Change Photo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Personal Information
                const Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name *',
                    border: OutlineInputBorder(),
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
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select gender';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date of Birth
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Select Date of Birth *',
                          style: TextStyle(
                            color: _selectedDate != null
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Professional Information
                const Text(
                  'Professional Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _workExpController,
                  decoration: const InputDecoration(
                    labelText: 'Work Experience *',
                    hintText: 'e.g., 5 years',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter work experience';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Subjects Selection
                InkWell(
                  onTap: _showSubjectsDialog,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedSubjects.isEmpty
                                ? 'Select Subjects *'
                                : _selectedSubjects.join(', '),
                            style: TextStyle(
                              color: _selectedSubjects.isEmpty
                                  ? Colors.grey[600]
                                  : Colors.black,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Boards Selection
                InkWell(
                  onTap: _showBoardsDialog,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedBoards.isEmpty
                                ? 'Select Boards *'
                                : _selectedBoards.join(', '),
                            style: TextStyle(
                              color: _selectedBoards.isEmpty
                                  ? Colors.grey[600]
                                  : Colors.black,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Resume Upload
                OutlinedButton.icon(
                  onPressed: _pickResume,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_selectedResume != null
                      ? 'Resume Selected'
                      : 'Upload Resume (Optional)'),
                ),
                const SizedBox(height: 24),

                // Address Information
                const Text(
                  'Address Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter state';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter country';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _pincodeController,
                  decoration: const InputDecoration(
                    labelText: 'Pincode *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pincode';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Pallete.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Update Profile',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
