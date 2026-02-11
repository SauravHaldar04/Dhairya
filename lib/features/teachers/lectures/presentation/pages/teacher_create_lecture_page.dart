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
  DateTime? _endDate;
  final _notesController = TextEditingController();
  final _meetingLinkController = TextEditingController();
  List<TeacherStudentAssignment> _assignments = [];

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
    if (_selectedAssignment == null) {
      showSnackbar(context, 'Please select a student');
      return;
    }
    if (_selectedSubject == null) {
      showSnackbar(context, 'Please select a subject');
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      showSnackbar(context, 'Please select date and time');
      return;
    }

    final timeSlot = TimeSlot(
      day: DateFormat('EEEE').format(_selectedDate!),
      startTime: _selectedTime!.format(context),
      endTime: TimeOfDay(hour: _selectedTime!.hour + 1, minute: _selectedTime!.minute).format(context),
    );

    if (_isRecurring && _endDate != null) {
      context.read<LecturesBloc>().add(
        CreateRecurringLecturesEvent(
          assignmentId: _selectedAssignment!.id,
          teacherUid: widget.teacherUid,
          studentUid: _selectedAssignment!.studentUid,
          subject: _selectedSubject!,
          startDate: _selectedDate!,
          endDate: _endDate!,
          timeSlot: timeSlot,
          recurrencePattern: 'weekly',
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          meetingLink: _meetingLinkController.text.isEmpty ? null : _meetingLinkController.text,
        ),
      );
    } else {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Lecture'), centerTitle: true),
      body: BlocConsumer<LecturesBloc, LecturesState>(
        listener: (context, state) {
          if (state is LecturesError) showSnackbar(context, state.message);
          if (state is TeacherAssignmentsLoaded) {
            setState(() => _assignments = state.assignments);
          }
          if (state is LectureCreated || state is RecurringLecturesCreated) {
            showSnackbar(context, 'Lecture created successfully');
            Navigator.of(context).pop();
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
                    child: Text('Student ${assignment.studentUid.substring(0, 8)}...'),
                  )).toList(),
                  onChanged: (assignment) => setState(() {
                    _selectedAssignment = assignment;
                    _selectedSubject = assignment?.subjects.first;
                  }),
                ),
                if (_selectedAssignment != null) ...[
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
                // Date & Time
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
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
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (time != null) setState(() => _selectedTime = time);
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(_selectedTime == null ? 'Select Time' : _selectedTime!.format(context)),
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
