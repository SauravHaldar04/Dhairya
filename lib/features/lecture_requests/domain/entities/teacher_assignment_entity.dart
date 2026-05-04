class TeacherAssignmentEntity {
  final String id;
  final String lectureRequestId;
  final String teacherUid;
  final String studentId;
  final List<String> subjects;
  final String assignedBy; // Admin user ID
  final String assignmentStatus; // 'active', 'paused', 'completed', 'cancelled'
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TeacherAssignmentEntity({
    required this.id,
    required this.lectureRequestId,
    required this.teacherUid,
    required this.studentId,
    required this.subjects,
    required this.assignedBy,
    required this.assignmentStatus,
    required this.startDate,
    this.endDate,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });
}
