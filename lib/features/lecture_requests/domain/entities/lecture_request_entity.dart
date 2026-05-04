class LectureRequestEntity {
  final String id;
  final String parentUid;
  final String studentId;
  final List<String> subjects; // Changed from single subject to array
  final Map<String, dynamic> preferredTimeSlots; // Changed to jsonb/map
  final String status; // 'pending', 'approved', 'rejected', 'assigned'
  final int? priorityLevel; // 1-5
  final String? additionalNotes;
  final DateTime? requestedStartDate;
  final String? frequency; // 'daily', 'weekly', 'biweekly', 'monthly'
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LectureRequestEntity({
    required this.id,
    required this.parentUid,
    required this.studentId,
    required this.subjects,
    required this.preferredTimeSlots,
    required this.status,
    this.priorityLevel,
    this.additionalNotes,
    this.requestedStartDate,
    this.frequency,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
  });
}
