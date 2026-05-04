class TeacherInterestEntity {
  final String id;
  final String lectureRequestId;
  final String teacherUid;
  final String studentId;
  final String subject;
  final List<dynamic> preferredTimeSlots;
  final String studentGrade;
  final String interestStatus;
  final DateTime createdAt;

  // Additional data fetched from joins
  final String? studentFirstName;
  final String? studentLastName;
  final String? parentFirstName;
  final String? parentLastName;

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
    this.studentFirstName,
    this.studentLastName,
    this.parentFirstName,
    this.parentLastName,
  });

  TeacherInterestEntity copyWith({
    String? id,
    String? lectureRequestId,
    String? teacherUid,
    String? studentId,
    String? subject,
    List<dynamic>? preferredTimeSlots,
    String? studentGrade,
    String? interestStatus,
    DateTime? createdAt,
    String? studentFirstName,
    String? studentLastName,
    String? parentFirstName,
    String? parentLastName,
  }) {
    return TeacherInterestEntity(
      id: id ?? this.id,
      lectureRequestId: lectureRequestId ?? this.lectureRequestId,
      teacherUid: teacherUid ?? this.teacherUid,
      studentId: studentId ?? this.studentId,
      subject: subject ?? this.subject,
      preferredTimeSlots: preferredTimeSlots ?? this.preferredTimeSlots,
      studentGrade: studentGrade ?? this.studentGrade,
      interestStatus: interestStatus ?? this.interestStatus,
      createdAt: createdAt ?? this.createdAt,
      studentFirstName: studentFirstName ?? this.studentFirstName,
      studentLastName: studentLastName ?? this.studentLastName,
      parentFirstName: parentFirstName ?? this.parentFirstName,
      parentLastName: parentLastName ?? this.parentLastName,
    );
  }
}
