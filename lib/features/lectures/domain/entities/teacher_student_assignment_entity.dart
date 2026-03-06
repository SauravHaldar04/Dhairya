class TeacherStudentAssignment {
  final String id;
  final String lectureRequestId;
  final String teacherUid;
  final String studentUid;
  final List<String> subjects;
  final String assignedBy; // Admin UID who made the assignment
  final String assignmentStatus; // active, paused, completed, cancelled
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Student details (from join)
  final String? studentFirstName;
  final String? studentMiddleName;
  final String? studentLastName;
  final String? studentStandard;
  final String? studentBoard;

  const TeacherStudentAssignment({
    required this.id,
    required this.lectureRequestId,
    required this.teacherUid,
    required this.studentUid,
    required this.subjects,
    required this.assignedBy,
    required this.assignmentStatus,
    required this.startDate,
    this.endDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.studentFirstName,
    this.studentMiddleName,
    this.studentLastName,
    this.studentStandard,
    this.studentBoard,
  });
  
  String get studentFullName {
    if (studentFirstName == null) return 'Unknown Student';
    return [studentFirstName, studentMiddleName, studentLastName]
        .where((n) => n != null && n.isNotEmpty)
        .join(' ');
  }

  TeacherStudentAssignment copyWith({
    String? id,
    String? lectureRequestId,
    String? teacherUid,
    String? studentUid,
    List<String>? subjects,
    String? assignedBy,
    String? assignmentStatus,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeacherStudentAssignment(
      id: id ?? this.id,
      lectureRequestId: lectureRequestId ?? this.lectureRequestId,
      teacherUid: teacherUid ?? this.teacherUid,
      studentUid: studentUid ?? this.studentUid,
      subjects: subjects ?? this.subjects,
      assignedBy: assignedBy ?? this.assignedBy,
      assignmentStatus: assignmentStatus ?? this.assignmentStatus,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
