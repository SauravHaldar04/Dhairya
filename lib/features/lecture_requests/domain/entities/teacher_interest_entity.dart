class TeacherInterestEntity {
  final String id;
  final String lectureRequestId;
  final String teacherUid;
  final String studentId;
  final String subject;
  final Map<String, dynamic> preferredTimeSlots;
  final String studentGrade;
  final String interestStatus; // 'pending', 'interested', 'rejected'
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TeacherInterestEntity({
    required this.id,
    required this.lectureRequestId,
    required this.teacherUid,
    required this.studentId,
    required this.subject,
    required this.preferredTimeSlots,
    required this.studentGrade,
    required this.interestStatus,
    required this.createdAt,
    this.updatedAt,
  });
}
