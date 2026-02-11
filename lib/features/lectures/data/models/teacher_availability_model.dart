import '../../domain/entities/time_slot_entity.dart';
import '../../domain/entities/teacher_availability_entity.dart';

class TeacherAvailabilityModel extends TeacherAvailability {
  const TeacherAvailabilityModel({
    required super.id,
    required super.teacherUid,
    required super.availableDays,
    required super.timeSlots,
    required super.subjectsOffered,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TeacherAvailabilityModel.fromMap(Map<String, dynamic> map) {
    return TeacherAvailabilityModel(
      id: map['id'] ?? '',
      teacherUid: map['teacher_uid'] ?? '',
      availableDays: List<String>.from(map['available_days'] ?? []),
      timeSlots: (map['time_slots'] as List<dynamic>?)
          ?.map((slot) => TimeSlot.fromMap(slot as Map<String, dynamic>))
          .toList() ?? [],
      subjectsOffered: List<String>.from(map['subjects_offered'] ?? []),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacher_uid': teacherUid,
      'available_days': availableDays,
      'time_slots': timeSlots.map((slot) => slot.toMap()).toList(),
      'subjects_offered': subjectsOffered,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TeacherAvailabilityModel.fromEntity(TeacherAvailability entity) {
    return TeacherAvailabilityModel(
      id: entity.id,
      teacherUid: entity.teacherUid,
      availableDays: entity.availableDays,
      timeSlots: entity.timeSlots,
      subjectsOffered: entity.subjectsOffered,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  TeacherAvailability toEntity() => this;
}