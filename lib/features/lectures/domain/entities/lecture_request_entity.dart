import 'time_slot_entity.dart';

class LectureRequest {
  final String id;
  final String parentUid;
  final String studentUid;
  final List<String> subjects;
  final List<TimeSlot> preferredTimeSlots;
  final String status; // pending, approved, rejected, assigned
  final int priorityLevel;
  final String? additionalNotes;
  final DateTime? requestedStartDate;
  final String frequency; // daily, weekly, biweekly, monthly
  final String? rejectionReason; // If admin rejects the request
  final DateTime createdAt;
  final DateTime updatedAt;

  const LectureRequest({
    required this.id,
    required this.parentUid,
    required this.studentUid,
    required this.subjects,
    required this.preferredTimeSlots,
    required this.status,
    required this.priorityLevel,
    this.additionalNotes,
    this.requestedStartDate,
    required this.frequency,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  LectureRequest copyWith({
    String? id,
    String? parentUid,
    String? studentUid,
    List<String>? subjects,
    List<TimeSlot>? preferredTimeSlots,
    String? status,
    int? priorityLevel,
    String? additionalNotes,
    DateTime? requestedStartDate,
    String? frequency,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LectureRequest(
      id: id ?? this.id,
      parentUid: parentUid ?? this.parentUid,
      studentUid: studentUid ?? this.studentUid,
      subjects: subjects ?? this.subjects,
      preferredTimeSlots: preferredTimeSlots ?? this.preferredTimeSlots,
      status: status ?? this.status,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      requestedStartDate: requestedStartDate ?? this.requestedStartDate,
      frequency: frequency ?? this.frequency,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LectureRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}