import 'package:aparna_education/core/widgets/custom_loader.dart';
import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/core/utils/snackbar.dart';
import 'package:aparna_education/features/lectures/domain/entities/lecture_entity.dart';
import 'package:aparna_education/features/lectures/presentation/bloc/lectures_bloc.dart';
import 'package:aparna_education/features/lectures/presentation/widgets/lecture_card.dart';
import 'package:aparna_education/features/lectures/presentation/widgets/recurring_lecture_group_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherLecturesListPage extends StatefulWidget {
  final String teacherUid;

  static route({required String teacherUid}) => MaterialPageRoute(
        builder: (context) => TeacherLecturesListPage(teacherUid: teacherUid),
      );

  const TeacherLecturesListPage({super.key, required this.teacherUid});

  @override
  State<TeacherLecturesListPage> createState() => _TeacherLecturesListPageState();
}

class _TeacherLecturesListPageState extends State<TeacherLecturesListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Lecture> _allLectures = [];
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          switch (_tabController.index) {
            case 0: _filterStatus = null; break;
            case 1: _filterStatus = 'scheduled'; break;
            case 2: _filterStatus = 'completed'; break;
            case 3: _filterStatus = 'cancelled'; break;
          }
        });
        _loadLectures();
      }
    });
    _loadLectures();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadLectures() {
    // Load lectures with a date range to ensure recurring instances are generated
    final now = DateTime.now();
    final fromDate = now.subtract(const Duration(days: 30)); // Past 30 days
    final toDate = now.add(const Duration(days: 90)); // Next 90 days
    
    context.read<LecturesBloc>().add(
      GetLecturesEvent(
        teacherUid: widget.teacherUid,
        status: _filterStatus,
        fromDate: fromDate,
        toDate: toDate,
      ),
    );
  }

  List<dynamic> _groupLectures(List<Lecture> lectures) {
    final Map<String, List<Lecture>> recurringGroups = {};
    final List<Lecture> oneTimeLectures = [];

    for (final lecture in lectures) {
      if (lecture.isRecurring && lecture.seriesId != null) {
        if (!recurringGroups.containsKey(lecture.seriesId)) {
          recurringGroups[lecture.seriesId!] = [];
        }
        recurringGroups[lecture.seriesId!]!.add(lecture);
      } else {
        oneTimeLectures.add(lecture);
      }
    }

    // Combine groups and one-time lectures, sorted by date
    final List<dynamic> result = [];
    
    // Add recurring groups (use earliest date from each group)
    for (final group in recurringGroups.values) {
      if (group.isNotEmpty) {
        result.add(group);
      }
    }
    
    // Add one-time lectures
    result.addAll(oneTimeLectures);
    
    // Sort by earliest date
    result.sort((a, b) {
      DateTime dateA;
      DateTime dateB;
      
      if (a is List<Lecture>) {
        dateA = a.first.scheduledDate;
      } else {
        dateA = (a as Lecture).scheduledDate;
      }
      
      if (b is List<Lecture>) {
        dateB = b.first.scheduledDate;
      } else {
        dateB = (b as Lecture).scheduledDate;
      }
      
      return dateA.compareTo(dateB);
    });
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Lectures', textAlign: TextAlign.center),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Pallete.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Pallete.primaryColor,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Scheduled'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: BlocConsumer<LecturesBloc, LecturesState>(
        listener: (context, state) {
          if (state is LecturesError) showSnackbar(context, state.message);
          if (state is LecturesLoaded) {
            setState(() => _allLectures = state.lectures);
          }
          if (state is LectureRescheduled) {
            showSnackbar(context, 'Lecture rescheduled successfully');
            _loadLectures();
          }
          if (state is LectureCancelled) {
            showSnackbar(context, 'Lecture cancelled successfully');
            _loadLectures();
          }
        },
        builder: (context, state) {
          if (state is LecturesLoading) return const CustomLoader();

          if (_allLectures.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No lectures found', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          final groupedLectures = _groupLectures(_allLectures);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedLectures.length,
            itemBuilder: (context, index) {
              final item = groupedLectures[index];
              
              // Recurring lecture group
              if (item is List<Lecture>) {
                final lectures = item;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RecurringLectureGroupCard(
                    lectures: lectures,
                    onTap: () {},
                    onReschedule: lectures.first.status == 'scheduled' ? () {
                      showSnackbar(context, 'Reschedule feature coming soon');
                    } : null,
                    onCancel: lectures.first.status == 'scheduled' ? () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Cancel Recurring Lectures'),
                          content: Text('Are you sure you want to cancel all ${lectures.length} lectures in this series?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('No'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Cancel all lectures in the series
                                for (final lecture in lectures) {
                                  context.read<LecturesBloc>().add(CancelLectureEvent(lectureId: lecture.id));
                                }
                                Navigator.pop(dialogContext);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Yes, Cancel All'),
                            ),
                          ],
                        ),
                      );
                    } : null,
                  ),
                );
              }
              
              // One-time lecture
              final lecture = item as Lecture;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LectureCard(
                  lecture: lecture,
                  onTap: () {},
                  onReschedule: lecture.status == 'scheduled' ? () {
                    showSnackbar(context, 'Reschedule feature coming soon');
                  } : null,
                  onCancel: lecture.status == 'scheduled' ? () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Cancel Lecture'),
                        content: const Text('Are you sure you want to cancel this lecture?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('No'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context.read<LecturesBloc>().add(CancelLectureEvent(lectureId: lecture.id));
                              Navigator.pop(dialogContext);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Yes, Cancel'),
                          ),
                        ],
                      ),
                    );
                  } : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
