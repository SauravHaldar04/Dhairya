import '../../domain/entities/lecture_request_entity.dart';

class LectureRequestModel extends LectureRequestEntity {
  const LectureRequestModel({
    required super.id,
    required super.parentUid,
    required super.studentId,
    required super.subjects,
    required super.preferredTimeSlots,
    required super.status,
    super.priorityLevel,
    super.additionalNotes,
    super.requestedStartDate,
    super.frequency,
    super.rejectionReason,
    required super.createdAt,
    super.updatedAt,
  });

  factory LectureRequestModel.fromJson(Map<String, dynamic> json) {
    return LectureRequestModel(
      id: json['id'] as String,
      parentUid: json['parent_uid'] as String,
      studentId: json['student_id'] as String,
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      preferredTimeSlots: json['preferred_time_slots'] as Map<String, dynamic>? ?? {},
      status: json['status'] as String,
      priorityLevel: json['priority_level'] as int?,
      additionalNotes: json['additional_notes'] as String?,
      requestedStartDate: json['requested_start_date'] != null
          ? DateTime.parse(json['requested_start_date'] as String)
          : null,
      frequency: json['frequency'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'parent_uid': parentUid,
      'student_id': studentId,
      'subjects': subjects,
      'preferred_time_slots': preferredTimeSlots,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };

    if (priorityLevel != null) {
      map['priority_level'] = priorityLevel;
    }
    if (additionalNotes != null) {
      map['additional_notes'] = additionalNotes;
    }
    if (requestedStartDate != null) {
      map['requested_start_date'] = requestedStartDate!.toIso8601String().split('T')[0];
    }
    if (frequency != null) {
      map['frequency'] = frequency;
    }
    if (rejectionReason != null) {
      map['rejection_reason'] = rejectionReason;
    }
    if (updatedAt != null) {
      map['updated_at'] = updatedAt!.toIso8601String();
    }

    return map;
  }

  LectureRequestEntity toEntity() {
    return LectureRequestEntity(
      id: id,
      parentUid: parentUid,
      studentId: studentId,
      subjects: subjects,
      preferredTimeSlots: preferredTimeSlots,
      status: status,
      priorityLevel: priorityLevel,
      additionalNotes: additionalNotes,
      requestedStartDate: requestedStartDate,
      frequency: frequency,
      rejectionReason: rejectionReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
