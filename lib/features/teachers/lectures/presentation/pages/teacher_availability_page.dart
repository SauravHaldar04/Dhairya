import 'package:aparna_education/core/widgets/custom_loader.dart';
import 'package:aparna_education/core/widgets/project_button.dart';
import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/core/utils/snackbar.dart';
import 'package:aparna_education/features/lectures/domain/entities/time_slot_entity.dart';
import 'package:aparna_education/features/lectures/presentation/bloc/lectures_bloc.dart';
import 'package:aparna_education/features/lectures/presentation/widgets/day_selector.dart';
import 'package:aparna_education/features/lectures/presentation/widgets/time_slot_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherAvailabilityPage extends StatefulWidget {
  final String teacherUid;

  static route({required String teacherUid}) => MaterialPageRoute(
        builder: (context) => TeacherAvailabilityPage(teacherUid: teacherUid),
      );

  const TeacherAvailabilityPage({super.key, required this.teacherUid});

  @override
  State<TeacherAvailabilityPage> createState() => _TeacherAvailabilityPageState();
}

class _TeacherAvailabilityPageState extends State<TeacherAvailabilityPage> {
  final List<String> _selectedDays = [];
  final List<TimeSlot> _timeSlots = [];
  final List<String> _selectedSubjects = [];

  final List<String> _availableSubjects = [
    'Mathematics', 'Physics', 'Chemistry', 'Biology', 'English', 'Hindi',
    'Computer Science', 'History', 'Geography', 'Economics', 'Accountancy', 'Business Studies',
  ];

  @override
  void initState() {
    super.initState();
    context.read<LecturesBloc>().add(GetTeacherAvailabilityEvent(widget.teacherUid));
  }

  void _saveAvailability() {
    if (_selectedDays.isEmpty) {
      showSnackbar(context, 'Please select at least one day');
      return;
    }
    if (_timeSlots.isEmpty) {
      showSnackbar(context, 'Please add at least one time slot');
      return;
    }
    if (_selectedSubjects.isEmpty) {
      showSnackbar(context, 'Please select at least one subject');
      return;
    }

    context.read<LecturesBloc>().add(
      UpdateTeacherAvailabilityEvent(
        teacherUid: widget.teacherUid,
        availableDays: _selectedDays,
        timeSlots: _timeSlots,
        subjectsOffered: _selectedSubjects,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Availability'), centerTitle: true),
      body: BlocConsumer<LecturesBloc, LecturesState>(
        listener: (context, state) {
          if (state is LecturesError) showSnackbar(context, state.message);
          if (state is TeacherAvailabilityLoaded && state.availability != null) {
            setState(() {
              _selectedDays.clear();
              _selectedDays.addAll(state.availability!.availableDays);
              _timeSlots.clear();
              _timeSlots.addAll(state.availability!.timeSlots);
              _selectedSubjects.clear();
              _selectedSubjects.addAll(state.availability!.subjectsOffered);
            });
          }
          if (state is TeacherAvailabilityUpdated) {
            showSnackbar(context, 'Availability updated successfully');
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
                Text('Available Days', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                DaySelector(
                  selectedDays: _selectedDays,
                  onDaysChanged: (days) => setState(() {
                    _selectedDays.clear();
                    _selectedDays.addAll(days);
                  }),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Time Slots', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Add Time Slot'),
                          content: TimeSlotPicker(
                            onTimeSlotSelected: (slot) {
                              setState(() => _timeSlots.add(slot));
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle),
                      color: Pallete.primaryColor,
                      iconSize: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._timeSlots.asMap().entries.map((entry) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Pallete.primaryColor.withOpacity(0.1),
                      child: Icon(Icons.access_time, color: Pallete.primaryColor),
                    ),
                    title: Text('${entry.value.startTime} - ${entry.value.endTime}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => _timeSlots.removeAt(entry.key)),
                    ),
                  ),
                )).toList(),
                const SizedBox(height: 24),
                Text('Subjects Offered', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableSubjects.map((subject) {
                    final isSelected = _selectedSubjects.contains(subject);
                    return FilterChip(
                      label: Text(subject),
                      selected: isSelected,
                      onSelected: (selected) => setState(() {
                        if (selected) _selectedSubjects.add(subject);
                        else _selectedSubjects.remove(subject);
                      }),
                      selectedColor: Pallete.primaryColor.withOpacity(0.3),
                      checkmarkColor: Pallete.primaryColor,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                ProjectButton(text: 'Save Availability', onPressed: _saveAvailability),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
