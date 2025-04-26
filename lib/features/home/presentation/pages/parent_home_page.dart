import 'package:aparna_education/features/profile/presentation/pages/add_student_page.dart';
import 'package:flutter/material.dart';

class ParentHomePage extends StatefulWidget {
  const ParentHomePage({super.key});

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  final List<LectureInfo> lectures = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        elevation: 0,
        actions: [
          // Add student button in app bar
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Student',
            onPressed: () => _navigateToAddStudent(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Student management card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Student Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your children to manage their education profile',
                    style: TextStyle(color: Colors.grey),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Student'),
                    onPressed: () => _navigateToAddStudent(),
                  ),
                ],
              ),
            ),
          ),

          // Lectures section
          Expanded(
            child: lectures.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No lectures added yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: lectures.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final lecture = lectures[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text(lecture.subject),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Student: ${lecture.studentName}'),
                              Text(
                                'Time: ${_formatDateTime(lecture.dateTime)}',
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              setState(() {
                                lectures.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLectureDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _navigateToAddStudent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStudentPage()),
    );

    // If student was added successfully, you might want to refresh parent data
    if (result == true) {
      // Optionally refresh parent data to show new student
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showAddLectureDialog(BuildContext context) async {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController studentNameController = TextEditingController();
    DateTime selectedDateTime = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Lecture'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'Enter subject name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: studentNameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  hintText: 'Enter student name',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Select Date & Time'),
                subtitle: Text(_formatDateTime(selectedDateTime)),
                onTap: () async {
                  final DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: selectedDateTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                    );
                    if (time != null) {
                      setState(() {
                        selectedDateTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (subjectController.text.isNotEmpty &&
                  studentNameController.text.isNotEmpty) {
                setState(() {
                  lectures.add(
                    LectureInfo(
                      subject: subjectController.text,
                      studentName: studentNameController.text,
                      dateTime: selectedDateTime,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class LectureInfo {
  final String subject;
  final String studentName;
  final DateTime dateTime;

  LectureInfo({
    required this.subject,
    required this.studentName,
    required this.dateTime,
  });
}
