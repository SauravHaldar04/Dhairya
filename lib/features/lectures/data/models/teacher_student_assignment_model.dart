import '../../domain/entities/teacher_student_assignment_entity.dart';

class TeacherStudentAssignmentModel extends TeacherStudentAssignment {
  const TeacherStudentAssignmentModel({
    required super.id,
    required super.lectureRequestId,
    required super.teacherUid,
    required super.studentUid,
    required super.subjects,
    required super.assignedBy,
    required super.assignmentStatus,
    required super.startDate,
    super.endDate,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
    super.studentFirstName,
    super.studentMiddleName,
    super.studentLastName,
    super.studentStandard,
    super.studentBoard,
    super.studentProfilePic,
  });

  factory TeacherStudentAssignmentModel.fromMap(Map<String, dynamic> map) {
    // Parse student data if present (from join)
    final studentData = map['students'] as Map<String, dynamic>?;
    
    return TeacherStudentAssignmentModel(
      id: map['id'] as String,
      lectureRequestId: map['lecture_request_id'] as String,
      teacherUid: map['teacher_uid'] as String,
      studentUid: map['student_id'] as String,
      subjects: List<String>.from(map['subjects'] as List),
      assignedBy: map['assigned_by'] as String,
      assignmentStatus: map['assignment_status'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String) : null,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      studentFirstName: studentData?['first_name'] as String?,
      studentMiddleName: studentData?['middle_name'] as String?,
      studentLastName: studentData?['last_name'] as String?,
      studentStandard: studentData?['standard'] as String?,
      studentBoard: studentData?['board'] as String?,
      studentProfilePic: studentData?['profile_pic'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lecture_request_id': lectureRequestId,
      'teacher_uid': teacherUid,
      'student_uid': studentUid,
      'subjects': subjects,
      'assigned_by': assignedBy,
      'assignment_status': assignmentStatus,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TeacherStudentAssignmentModel.fromEntity(TeacherStudentAssignment entity) {
    return TeacherStudentAssignmentModel(
      id: entity.id,
      lectureRequestId: entity.lectureRequestId,
      teacherUid: entity.teacherUid,
      studentUid: entity.studentUid,
      subjects: entity.subjects,
      assignedBy: entity.assignedBy,
      assignmentStatus: entity.assignmentStatus,
      startDate: entity.startDate,
      endDate: entity.endDate,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      studentProfilePic: entity.studentProfilePic,
    );
  }

  TeacherStudentAssignment toEntity() => this;
}
