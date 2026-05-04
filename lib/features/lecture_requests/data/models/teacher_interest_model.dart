import '../../domain/entities/teacher_interest_entity.dart';

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
    super.updatedAt,
  });

  factory TeacherInterestModel.fromJson(Map<String, dynamic> json) {
    return TeacherInterestModel(
      id: json['id'] as String,
      lectureRequestId: json['lecture_request_id'] as String,
      teacherUid: json['teacher_uid'] as String,
      studentId: json['student_id'] as String,
      subject: json['subject'] as String,
      preferredTimeSlots: json['preferred_time_slots'] as Map<String, dynamic>? ?? {},
      studentGrade: json['student_grade'] as String,
      interestStatus: json['interest_status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'lecture_request_id': lectureRequestId,
      'teacher_uid': teacherUid,
      'student_id': studentId,
      'subject': subject,
      'preferred_time_slots': preferredTimeSlots,
      'student_grade': studentGrade,
      'interest_status': interestStatus,
      'created_at': createdAt.toIso8601String(),
    };

    if (updatedAt != null) {
      map['updated_at'] = updatedAt!.toIso8601String();
    }

    return map;
  }

  TeacherInterestEntity toEntity() {
    return TeacherInterestEntity(
      id: id,
      lectureRequestId: lectureRequestId,
      teacherUid: teacherUid,
      studentId: studentId,
      subject: subject,
      preferredTimeSlots: preferredTimeSlots,
      studentGrade: studentGrade,
      interestStatus: interestStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
