import 'package:aparna_education/core/theme/theme.dart';
import 'package:aparna_education/features/teachers/teacher_interest/domain/entities/teacher_interest_entity.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/bloc/teacher_interest_bloc.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/bloc/teacher_interest_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherInterestDetailsPage extends StatelessWidget {
  final TeacherInterestEntity interest;

  const TeacherInterestDetailsPage({Key? key, required this.interest}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunity Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.lightTheme.primaryColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Subject Needed', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('${interest.subject} (${interest.studentGrade})', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const Divider(height: 30),
                  
                  const Text('Student', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text("${interest.studentFirstName ?? 'Unknown'} ${interest.studentLastName ?? ''}", 
                    style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  
                  const Text('Parent', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text("${interest.parentFirstName ?? 'Unknown'} ${interest.parentLastName ?? ''}", 
                    style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Preferred Time Slots',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            if (interest.preferredTimeSlots.isEmpty)
              const Text('No preferred time slots specified.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interest.preferredTimeSlots.map((slot) {
                  // Assuming slot is a string map or just a string from JSONB. Handle accordingly.
                  final slotStr = slot.toString();
                  return Chip(label: Text(slotStr));
                }).toList(),
              ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<TeacherInterestBloc>().add(
                        UpdateInterestStatusEvent(interest.id, 'rejected')
                      );
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<TeacherInterestBloc>().add(
                        UpdateInterestStatusEvent(interest.id, 'interested')
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Show Interest'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
