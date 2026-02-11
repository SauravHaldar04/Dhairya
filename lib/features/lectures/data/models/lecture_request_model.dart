import '../../domain/entities/time_slot_entity.dart';
import '../../domain/entities/lecture_request_entity.dart';

class LectureRequestModel extends LectureRequest {
  const LectureRequestModel({
    required super.id,
    required super.parentUid,
    required super.studentUid,
    required super.subjects,
    required super.preferredTimeSlots,
    required super.status,
    required super.priorityLevel,
    super.additionalNotes,
    super.requestedStartDate,
    required super.frequency,
    super.rejectionReason,
    required super.createdAt,
    required super.updatedAt,
  });

  factory LectureRequestModel.fromMap(Map<String, dynamic> map) {
    return LectureRequestModel(
      id: map['id'] ?? '',
      parentUid: map['parent_uid'] ?? '',
      studentUid: map['student_uid'] ?? '',
      subjects: List<String>.from(map['subjects'] ?? []),
      preferredTimeSlots: (map['preferred_time_slots'] as List<dynamic>?)
          ?.map((slot) => TimeSlot.fromMap(slot as Map<String, dynamic>))
          .toList() ?? [],
      status: map['status'] ?? 'pending',
      priorityLevel: map['priority_level'] ?? 1,
      additionalNotes: map['additional_notes'],
      requestedStartDate: map['requested_start_date'] != null 
          ? DateTime.parse(map['requested_start_date']) 
          : null,
      frequency: map['frequency'] ?? 'weekly',
      rejectionReason: map['rejection_reason'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_uid': parentUid,
      'student_uid': studentUid,
      'subjects': subjects,
      'preferred_time_slots': preferredTimeSlots.map((slot) => slot.toMap()).toList(),
      'status': status,
      'priority_level': priorityLevel,
      'additional_notes': additionalNotes,
      'requested_start_date': requestedStartDate?.toIso8601String().split('T')[0],
      'frequency': frequency,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory LectureRequestModel.fromEntity(LectureRequest entity) {
    return LectureRequestModel(
      id: entity.id,
      parentUid: entity.parentUid,
      studentUid: entity.studentUid,
      subjects: entity.subjects,
      preferredTimeSlots: entity.preferredTimeSlots,
      status: entity.status,
      priorityLevel: entity.priorityLevel,
      additionalNotes: entity.additionalNotes,
      requestedStartDate: entity.requestedStartDate,
      frequency: entity.frequency,
      rejectionReason: entity.rejectionReason,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  LectureRequest toEntity() => this;
}