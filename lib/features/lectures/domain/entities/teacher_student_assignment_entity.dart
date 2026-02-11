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
  });

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
