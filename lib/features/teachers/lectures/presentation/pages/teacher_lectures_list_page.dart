import 'package:aparna_education/core/widgets/custom_loader.dart';
import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/core/utils/snackbar.dart';
import 'package:aparna_education/features/lectures/domain/entities/lecture_entity.dart';
import 'package:aparna_education/features/lectures/presentation/bloc/lectures_bloc.dart';
import 'package:aparna_education/features/lectures/presentation/widgets/lecture_card.dart';
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
    context.read<LecturesBloc>().add(
      GetLecturesEvent(teacherUid: widget.teacherUid, status: _filterStatus),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Lectures'),
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _allLectures.length,
            itemBuilder: (context, index) {
              final lecture = _allLectures[index];
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
