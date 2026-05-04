import 'package:aparna_education/features/teachers/teacher_interest/domain/entities/teacher_interest_entity.dart';

class TeacherInterestModel extends TeacherInterestEntity {
  const TeacherInterestModel({
    required super.id,
    required super.lectureRequestId,
    required super.teacherUid,
    required super.studentId,
    required super.subject,
    required super.preferredTimeSlots,
    required super.studentGrade,
    required super.interestStatus,
    required super.createdAt,
    super.studentFirstName,
    super.studentLastName,
    super.parentFirstName,
    super.parentLastName,
  });

  factory TeacherInterestModel.fromJson(Map<String, dynamic> json) {
    // When joining with students and parents in Supabase, they come nested
    final studentData = json['students'] as Map<String, dynamic>?;
    final parentData = studentData?['parents'] as Map<String, dynamic>?;

    return TeacherInterestModel(
      id: json['id'] as String,
      lectureRequestId: json['lecture_request_id'] as String,
      teacherUid: json['teacher_uid'] as String,
      studentId: json['student_id'] as String,
      subject: json['subject'] as String,
      preferredTimeSlots: json['preferred_time_slots'] as List<dynamic>? ?? [],
      studentGrade: json['student_grade'] as String,
      interestStatus: json['interest_status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      studentFirstName: studentData?['first_name'] as String?,
      studentLastName: studentData?['last_name'] as String?,
      parentFirstName: parentData?['first_name'] as String?,
      parentLastName: parentData?['last_name'] as String?,
    );
  }
}
