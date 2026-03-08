import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aparna_education/core/widgets/app_loading.dart';
import 'package:aparna_education/features/lectures/presentation/bloc/lectures_bloc.dart';
import 'package:aparna_education/features/lectures/presentation/widgets/lecture_card.dart';

class ParentUpcomingLecturesPage extends StatefulWidget {
  final String parentUid;

  const ParentUpcomingLecturesPage({
    Key? key,
    required this.parentUid,
  }) : super(key: key);

  @override
  State<ParentUpcomingLecturesPage> createState() => _ParentUpcomingLecturesPageState();
}

class _ParentUpcomingLecturesPageState extends State<ParentUpcomingLecturesPage> {
  String? selectedStudentUid;

  @override
  void initState() {
    super.initState();
    _loadLectures();
  }

  void _loadLectures() {
    context.read<LecturesBloc>().add(GetUpcomingLecturesEvent(studentUid: selectedStudentUid));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Lectures'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: cs.surfaceContainerHighest.withOpacity(0.3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border.all(color: cs.outline.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Filter by Student'),
                  value: selectedStudentUid,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Students')),
                    DropdownMenuItem(value: 'student1', child: Text('Student 1')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedStudentUid = value);
                    _loadLectures();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<LecturesBloc, LecturesState>(
              builder: (context, state) {
                if (state is LecturesLoading) {
                  return const Center(child: AppLoading());
                }

                if (state is UpcomingLecturesLoaded) {
                  if (state.lectures.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 64, color: cs.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text('No upcoming lectures', style: TextStyle(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadLectures(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.lectures.length,
                      itemBuilder: (context, index) {
                        final lecture = state.lectures[index];
                        return LectureCard(
                          lecture: lecture,
                          showActions: false,
                          onTap: () {
                            // Navigate to lecture details if needed
                          },
                        );
                      },
                    ),
                  );
                }

                return const Center(child: Text('Failed to load lectures'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
