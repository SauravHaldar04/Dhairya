import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/core/widgets/project_button.dart';
import 'package:aparna_education/core/utils/snackbar.dart';
import 'package:aparna_education/features/lectures/presentation/bloc/lectures_bloc.dart';
import 'package:aparna_education/features/lectures/domain/entities/time_slot_entity.dart';
import 'package:aparna_education/features/lectures/presentation/widgets/day_selector.dart';
import 'package:aparna_education/features/lectures/presentation/widgets/time_slot_picker.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:aparna_education/features/profile/domain/entities/student_entity.dart';

class ParentRequestLecturePage extends StatefulWidget {
  final String parentUid;

  const ParentRequestLecturePage({
    Key? key,
    required this.parentUid,
  }) : super(key: key);

  @override
  State<ParentRequestLecturePage> createState() => _ParentRequestLecturePageState();
}

class _ParentRequestLecturePageState extends State<ParentRequestLecturePage> {
  String? selectedStudentUid;
  final List<String> selectedSubjects = [];
  final List<TimeSlot> preferredTimeSlots = [];
  List<Student> students = [];
  List<String> availableSubjects = [];

  @override
  void initState() {
    super.initState();
    // Fetch parent's students
    context.read<ProfileBloc>().add(GetStudentsbyParent(uid: widget.parentUid));
  }

  void _addTimeSlot(TimeSlot timeSlot, String day) {
    setState(() {
      preferredTimeSlots.add(TimeSlot(
        day: day,
        startTime: timeSlot.startTime,
        endTime: timeSlot.endTime,
      ));
    });
  }

  void _submitRequest() {
    if (selectedStudentUid == null || selectedSubjects.isEmpty || preferredTimeSlots.isEmpty) {
      showSnackbar(context, 'Please fill all fields');
      return;
    }

    context.read<LecturesBloc>().add(CreateLectureRequestEvent(
          parentUid: widget.parentUid,
          studentUid: selectedStudentUid!,
          subjects: selectedSubjects,
          preferredTimeSlots: preferredTimeSlots,
        ));
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
          'Request Lecture',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is StudentsLoaded) {
            setState(() {
              students = state.students;
            });
          }
        },
        child: BlocConsumer<LecturesBloc, LecturesState>(
          listener: (context, state) {
            if (state is LectureRequestCreated) {
              showSnackbar(context, 'Lecture request submitted successfully');
              Navigator.pop(context);
            } else if (state is LecturesError) {
              showSnackbar(context, state.message);
            }
          },
          builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Select Student'),
                      value: selectedStudentUid,
                      items: students.map((student) {
                        return DropdownMenuItem<String>(
                          value: student.uid,
                          child: Text('${student.firstName} ${student.lastName}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStudentUid = value;
                          selectedSubjects.clear();
                          // Update available subjects based on selected student
                          final selectedStudent = students.firstWhere((s) => s.uid == value);
                          availableSubjects = selectedStudent.subjects;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Subjects',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (availableSubjects.isEmpty)
                  const Text(
                    'Please select a student first',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  )
                else
                  Wrap(
                    spacing: 8,
                    children: availableSubjects.map((subject) {
                      final isSelected = selectedSubjects.contains(subject);
                      return FilterChip(
                        label: Text(subject),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedSubjects.add(subject);
                            } else {
                            selectedSubjects.remove(subject);
                          }
                        });
                      },
                      selectedColor: Pallete.primaryColor.withOpacity(0.3),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Preferred Time Slots',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DaySelector(
                  selectedDays: preferredTimeSlots.map((ts) => ts.day).toSet().toList(),
                  onDaysChanged: (days) {
                    // When a new day is added, show time picker
                    final existingDays = preferredTimeSlots.map((ts) => ts.day).toSet();
                    for (final day in days) {
                      if (!existingDays.contains(day)) {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => Padding(
                            padding: const EdgeInsets.all(16),
                            child: TimeSlotPicker(
                              onTimeSlotSelected: (timeSlot) {
                                _addTimeSlot(timeSlot, day);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      }
                    }
                    // Remove time slots for deselected days
                    setState(() {
                      preferredTimeSlots.removeWhere((ts) => !days.contains(ts.day));
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (preferredTimeSlots.isNotEmpty) ...[
                  ...preferredTimeSlots.map(
                    (ts) => Card(
                      child: ListTile(
                        title: Text('${ts.day} ${ts.startTime} - ${ts.endTime}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => setState(() => preferredTimeSlots.remove(ts)),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                ProjectButton(
                  text: 'Submit Request',
                  onPressed: state is LecturesLoading ? null : _submitRequest,
                ),
              ],
            ),
          );
        },
        ),
      ),
    );
  }
}
