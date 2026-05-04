import 'package:aparna_education/core/theme/theme.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/bloc/teacher_interest_bloc.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/bloc/teacher_interest_event.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/bloc/teacher_interest_state.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/pages/teacher_interest_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aparna_education/core/utils/loader.dart';

class TeacherInterestListPage extends StatefulWidget {
  final String teacherUid;

  const TeacherInterestListPage({Key? key, required this.teacherUid}) : super(key: key);

  @override
  State<TeacherInterestListPage> createState() => _TeacherInterestListPageState();
}

class _TeacherInterestListPageState extends State<TeacherInterestListPage> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherInterestBloc>().add(FetchPendingInterests(widget.teacherUid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teaching Opportunities'),
      ),
      body: BlocConsumer<TeacherInterestBloc, TeacherInterestState>(
        listener: (context, state) {
          if (state is TeacherInterestStatusUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Interest status updated successfully!')),
            );
            context.read<TeacherInterestBloc>().add(FetchPendingInterests(widget.teacherUid));
          } else if (state is TeacherInterestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          if (state is TeacherInterestLoading) {
            return const Loader();
          } else if (state is TeacherInterestLoaded) {
            final interests = state.interests;
            if (interests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No new teaching opportunities',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: interests.length,
              itemBuilder: (context, index) {
                final interest = interests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.lightTheme.primaryColor.withOpacity(0.1),
                      child: Icon(Icons.person, color: AppTheme.lightTheme.primaryColor),
                    ),
                    title: Text(
                      '${interest.subject} (${interest.studentGrade})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text("Student: ${interest.studentFirstName ?? 'Unknown'} ${interest.studentLastName ?? ''}"),
                        Text("Parent: ${interest.parentFirstName ?? 'Unknown'} ${interest.parentLastName ?? ''}"),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeacherInterestDetailsPage(
                            interest: interest,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
