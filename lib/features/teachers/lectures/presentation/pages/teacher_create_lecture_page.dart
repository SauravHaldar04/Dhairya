import 'package:aparna_education/core/widgets/custom_loader.dart';
import 'package:aparna_education/core/widgets/project_button.dart';
import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/core/utils/snackbar.dart';
import 'package:aparna_education/features/lectures/domain/entities/teacher_student_assignment_entity.dart';
import 'package:aparna_education/features/lectures/domain/entities/time_slot_entity.dart';
import 'package:aparna_education/features/lectures/presentation/bloc/lectures_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TeacherCreateLecturePage extends StatefulWidget {
  final String teacherUid;

  static route({required String teacherUid}) => MaterialPageRoute(
        builder: (context) => TeacherCreateLecturePage(teacherUid: teacherUid),
      );

  const TeacherCreateLecturePage({super.key, required this.teacherUid});

  @override
  State<TeacherCreateLecturePage> createState() => _TeacherCreateLecturePageState();
}

class _TeacherCreateLecturePageState extends State<TeacherCreateLecturePage> {
  TeacherStudentAssignment? _selectedAssignment;
  String? _selectedSubject;
  bool _isRecurring = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TimeOfDay? _selectedEndTime;
  DateTime? _endDate;
  final _notesController = TextEditingController();
  final _meetingLinkController = TextEditingController();
  List<TeacherStudentAssignment> _assignments = [];
  
  // For recurring lectures - days of the week
  final List<String> _weekDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  final Set<String> _selectedDays = {};

  @override
  void initState() {
    super.initState();
    context.read<LecturesBloc>().add(GetTeacherAssignmentsEvent(teacherUid: widget.teacherUid, assignmentStatus: 'active'));
  }

  @override
  void dispose() {
    _notesController.dispose();
    _meetingLinkController.dispose();
    super.dispose();
  }

  void _createLecture() {
    try {
      print('Create lecture button pressed');
      
      if (_selectedAssignment == null) {
        showSnackbar(context, 'Please select a student');
        return;
      }
      if (_selectedSubject == null) {
        showSnackbar(context, 'Please select a subject');
        return;
      }
      if (_selectedDate == null || _selectedTime == null || _selectedEndTime == null) {
        showSnackbar(context, 'Please select date, start time and end time');
        return;
      }

      print('Creating TimeSlot...');
      final timeSlot = TimeSlot(
        day: DateFormat('EEEE').format(_selectedDate!),
        startTime: _selectedTime!.format(context),
        endTime: _selectedEndTime!.format(context),
      );
      print('TimeSlot created: $timeSlot');

      if (_isRecurring && _endDate != null) {
        if (_selectedDays.isEmpty) {
          showSnackbar(context, 'Please select at least one day for recurring lectures');
          return;
        }
        
        print('Creating recurring lecture template for days: $_selectedDays');
        context.read<LecturesBloc>().add(
          CreateRecurringLectureTemplateEvent(
            assignmentId: _selectedAssignment!.id,
            teacherUid: widget.teacherUid,
            studentUid: _selectedAssignment!.studentUid,
            subject: _selectedSubject!,
            startDate: _selectedDate!,
            endDate: _endDate!,
            timeSlot: timeSlot,
            recurrencePattern: 'weekly',
            recurrenceDays: _selectedDays.toList(),
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            meetingLink: _meetingLinkController.text.isEmpty ? null : _meetingLinkController.text,
          ),
        );
      } else {
        print('Creating one-time lecture event');
        print('Assignment ID: ${_selectedAssignment!.id}');
        print('Teacher UID: ${widget.teacherUid}');
        print('Student UID: ${_selectedAssignment!.studentUid}');
        print('Subject: $_selectedSubject');
        
        context.read<LecturesBloc>().add(
          CreateOneTimeLectureEvent(
            assignmentId: _selectedAssignment!.id,
            teacherUid: widget.teacherUid,
            studentUid: _selectedAssignment!.studentUid,
            subject: _selectedSubject!,
            scheduledDate: _selectedDate!,
            scheduledTime: timeSlot,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            meetingLink: _meetingLinkController.text.isEmpty ? null : _meetingLinkController.text,
          ),
        );
        print('Event added to bloc');
      }
    } catch (e, stackTrace) {
      print('Error in _createLecture: $e');
      print('Stack trace: $stackTrace');
      showSnackbar(context, 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Lecture'), centerTitle: true),
      body: BlocConsumer<LecturesBloc, LecturesState>(
        listenWhen: (previous, current) => 
          current is LecturesError || 
          current is TeacherAssignmentsLoaded || 
          current is LectureCreated || 
          current is RecurringLectureTemplateCreated,
        buildWhen: (previous, current) =>
          current is LecturesLoading ||
          current is TeacherAssignmentsLoaded ||
          current is LecturesError ||
          current is LecturesInitial,
        listener: (context, state) {
          if (state is LecturesError) {
            showSnackbar(context, state.message);
          }
          if (state is TeacherAssignmentsLoaded) {
            print('Assignments loaded: ${state.assignments.length}');
            for (var assignment in state.assignments) {
              print('Assignment: ${assignment.studentFullName}, Subjects: ${assignment.subjects}');
            }
            setState(() => _assignments = state.assignments);
          }
          if (state is LectureCreated) {
            showSnackbar(context, 'Lecture created successfully');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.of(context).pop();
            });
          }
          if (state is RecurringLectureTemplateCreated) {
            showSnackbar(context, 'Recurring lecture schedule created successfully');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.of(context).pop();
            });
          }
        },
        builder: (context, state) {
          if (state is LecturesLoading) return const CustomLoader();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Selection
                Text('Select Student', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<TeacherStudentAssignment>(
                  value: _selectedAssignment,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  hint: const Text('Choose a student'),
                  items: _assignments.map((assignment) => DropdownMenuItem(
                    value: assignment,
                    child: Text(assignment.studentFullName),
                  )).toList(),
                  onChanged: (assignment) => setState(() {
                    _selectedAssignment = assignment;
                    _selectedSubject = assignment != null && assignment.subjects.isNotEmpty ? assignment.subjects.first : null;
                  }),
                ),
                if (_selectedAssignment != null && _selectedAssignment!.subjects.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Select Subject', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _selectedAssignment!.subjects.map((subject) => DropdownMenuItem(value: subject, child: Text(subject))).toList(),
                    onChanged: (subject) => setState(() => _selectedSubject = subject),
                  ),
                ],
                const SizedBox(height: 16),
                // Date Selector
                OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_selectedDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_selectedDate!)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 12),
                // Time Selectors
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime ?? TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              _selectedTime = time;
                              // Auto-set end time to 1 hour later if not already set
                              if (_selectedEndTime == null) {
                                _selectedEndTime = TimeOfDay(
                                  hour: (time.hour + 1) % 24,
                                  minute: time.minute,
                                );
                              }
                            });
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(_selectedTime == null ? 'Start Time' : _selectedTime!.format(context)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _selectedEndTime ?? TimeOfDay(hour: (_selectedTime?.hour ?? 0 + 1) % 24, minute: _selectedTime?.minute ?? 0),
                          );
                          if (time != null) {
                            // Validate end time is after start time
                            if (_selectedTime != null) {
                              final startMinutes = _selectedTime!.hour * 60 + _selectedTime!.minute;
                              final endMinutes = time.hour * 60 + time.minute;
                              if (endMinutes <= startMinutes) {
                                showSnackbar(context, 'End time must be after start time');
                                return;
                              }
                            }
                            setState(() => _selectedEndTime = time);
                          }
                        },
                        icon: const Icon(Icons.access_time_filled),
                        label: Text(_selectedEndTime == null ? 'End Time' : _selectedEndTime!.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Recurring Toggle
                SwitchListTile(
                  title: const Text('Recurring Lecture'),
                  value: _isRecurring,
                  activeColor: Pallete.primaryColor,
                  onChanged: (value) => setState(() => _isRecurring = value),
                ),
                if (_isRecurring) ...[
                  const SizedBox(height: 16),
                  Text('Select Days', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _weekDays.map((day) {
                      final isSelected = _selectedDays.contains(day);
                      return FilterChip(
                        label: Text(day[0].toUpperCase() + day.substring(1, 3)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDays.add(day);
                            } else {
                              _selectedDays.remove(day);
                            }
                          });
                        },
                        selectedColor: Pallete.primaryColor.withOpacity(0.3),
                        checkmarkColor: Pallete.primaryColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate?.add(const Duration(days: 7)) ?? DateTime.now().add(const Duration(days: 7)),
                        firstDate: _selectedDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setState(() => _endDate = date);
                    },
                    icon: const Icon(Icons.event),
                    label: Text(_endDate == null ? 'Select End Date' : 'Ends: ${DateFormat('MMM dd, yyyy').format(_endDate!)}'),
                  ),
                ],
                const SizedBox(height: 16),
                // Notes
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Meeting Link
                TextField(
                  controller: _meetingLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Meeting Link (optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 32),
                ProjectButton(text: 'Create Lecture', onPressed: _createLecture),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
