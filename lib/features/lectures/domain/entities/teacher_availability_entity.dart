import 'time_slot_entity.dart';

class TeacherAvailability {
  final String id;
  final String teacherUid;
  final List<String> availableDays;
  final List<TimeSlot> timeSlots;
  final List<String> subjectsOffered;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TeacherAvailability({
    required this.id,
    required this.teacherUid,
    required this.availableDays,
    required this.timeSlots,
    required this.subjectsOffered,
    required this.createdAt,
    required this.updatedAt,
  });

  TeacherAvailability copyWith({
    String? id,
    String? teacherUid,
    List<String>? availableDays,
    List<TimeSlot>? timeSlots,
    List<String>? subjectsOffered,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeacherAvailability(
      id: id ?? this.id,
      teacherUid: teacherUid ?? this.teacherUid,
      availableDays: availableDays ?? this.availableDays,
      timeSlots: timeSlots ?? this.timeSlots,
      subjectsOffered: subjectsOffered ?? this.subjectsOffered,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeacherAvailability && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}