import '../entities/recurring_lecture_template_entity.dart';
import '../entities/lecture_entity.dart';
import '../entities/time_slot_entity.dart';

/// Service responsible for calculating virtual lecture instances from recurring templates
/// Implements the "alarm clock" pattern - calculates occurrences on-demand rather than storing them
class LectureOccurrenceCalculator {
  /// Calculates the next N occurrences from a template
  /// Returns virtual Lecture instances (not materialized in DB)
  List<Lecture> calculateNextOccurrences(
    RecurringLectureTemplate template, {
    required int count,
    DateTime? startFrom,
  }) {
    final occurrences = <Lecture>[];
    final start = startFrom ?? DateTime.now();
    var currentDate = _normalizeDate(start);

    // Ensure we start from template start date if before it
    if (currentDate.isBefore(template.startDate)) {
      currentDate = _normalizeDate(template.startDate);
    }

    // Generate occurrences until we have enough or reach end date
    while (occurrences.length < count) {
      // Check if we've passed the end date (must be OUTSIDE shouldOccurOn
      // since shouldOccurOn also returns false past endDate, making the
      // break inside it unreachable — causing an infinite loop)
      if (template.endDate != null && currentDate.isAfter(template.endDate!)) {
        break;
      }

      if (template.shouldOccurOn(currentDate)) {
        occurrences.add(_createVirtualLecture(template, currentDate));
      }

      // Move to next day
      currentDate = currentDate.add(const Duration(days: 1));

      // Safety check to prevent infinite loops (365-day horizon)
      if (currentDate.difference(start).inDays > 365) {
        break;
      }
    }

    return occurrences;
  }

  /// Gets the next single occurrence from a template
  Lecture? getNextOccurrence(
    RecurringLectureTemplate template, {
    DateTime? after,
  }) {
    final occurrences = calculateNextOccurrences(
      template,
      count: 1,
      startFrom: after,
    );
    return occurrences.isEmpty ? null : occurrences.first;
  }

  /// Gets all occurrences within a specific date range
  List<Lecture> getOccurrencesInRange(
    RecurringLectureTemplate template, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final occurrences = <Lecture>[];
    var currentDate = _normalizeDate(startDate);
    final normalizedEnd = _normalizeDate(endDate);

    // Adjust start date to template start if needed
    if (currentDate.isBefore(template.startDate)) {
      currentDate = _normalizeDate(template.startDate);
    }

    // Adjust end date to template end if needed
    var effectiveEnd = normalizedEnd;
    if (template.endDate != null && template.endDate!.isBefore(effectiveEnd)) {
      effectiveEnd = _normalizeDate(template.endDate!);
    }

    // Generate all occurrences in range
    while (currentDate.isBefore(effectiveEnd) || currentDate.isAtSameMomentAs(effectiveEnd)) {
      if (template.shouldOccurOn(currentDate)) {
        occurrences.add(_createVirtualLecture(template, currentDate));
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return occurrences;
  }

  /// Checks if a template has any future occurrences
  bool hasFutureOccurrences(RecurringLectureTemplate template) {
    if (!template.isActive) return false;
    if (template.endDate != null && template.endDate!.isBefore(DateTime.now())) {
      return false;
    }
    final next = getNextOccurrence(template);
    return next != null;
  }

  /// Creates a virtual lecture instance from a template and date
  Lecture _createVirtualLecture(RecurringLectureTemplate template, DateTime date) {
    // Generate a deterministic ID based on template and date
    final dateStr = date.toIso8601String().split('T')[0]; // YYYY-MM-DD
    final virtualId = '${template.id}_$dateStr';

    return Lecture(
      id: virtualId,
      assignmentId: template.assignmentId,
      teacherUid: template.teacherUid,
      studentUid: template.studentId,
      subject: template.subject,
      scheduledDate: date,
      scheduledTime: template.scheduledTime,
      templateId: template.id,
      isMaterialized: false, // Virtual instance
      isRecurring: true,
      seriesId: template.seriesId,
      recurrencePattern: template.recurrencePattern,
      recurrenceDays: template.recurrenceDays,
      recurrenceEndDate: template.endDate,
      status: 'scheduled',
      notes: template.notes,
      meetingLink: template.meetingLink,
      attendanceMarked: false,
      createdAt: template.createdAt,
      updatedAt: template.updatedAt,
    );
  }

  /// Normalizes a DateTime to midnight (removes time component)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
