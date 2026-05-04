// ============================================================
// LEVEL 2: ENTITY / MODEL TESTS
// ============================================================
// Still no mocking! We're testing your domain entities —
// constructors, helper methods, equality, copyWith.
//
// 🧠 KEY CONCEPT: Entities are the core of your app. If THESE
// are buggy, everything built on top breaks. Test them first.
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:aparna_education/features/lectures/domain/entities/time_slot_entity.dart';
import 'package:aparna_education/features/lectures/domain/entities/recurring_lecture_template_entity.dart';

void main() {
  // ════════════════════════════════════════════════════════════
  //  TimeSlot Tests
  // ════════════════════════════════════════════════════════════
  group('TimeSlot', () {
    test('creates from constructor', () {
      final slot = TimeSlot(
        day: 'monday',
        startTime: '10:00',
        endTime: '11:00',
      );

      expect(slot.day, 'monday');
      expect(slot.startTime, '10:00');
      expect(slot.endTime, '11:00');
    });

    test('toMap produces correct keys', () {
      final slot = TimeSlot(day: 'tuesday', startTime: '14:00', endTime: '15:30');
      final map = slot.toMap();

      // Your Supabase uses 'start' and 'end' keys, not 'startTime'/'endTime'
      expect(map['day'], 'tuesday');
      expect(map['start'], '14:00');
      expect(map['end'], '15:30');
    });

    test('fromMap creates correct TimeSlot', () {
      final map = {'day': 'friday', 'start': '09:00', 'end': '10:00'};
      final slot = TimeSlot.fromMap(map);

      expect(slot.day, 'friday');
      expect(slot.startTime, '09:00');
      expect(slot.endTime, '10:00');
    });

    // Round-trip: object → map → object should be equal
    test('round-trip: toMap → fromMap preserves data', () {
      final original = TimeSlot(day: 'wednesday', startTime: '08:30', endTime: '09:30');
      final roundTripped = TimeSlot.fromMap(original.toMap());

      expect(roundTripped, original); // Uses your == operator
    });

    test('equality works for identical values', () {
      final a = TimeSlot(day: 'monday', startTime: '10:00', endTime: '11:00');
      final b = TimeSlot(day: 'monday', startTime: '10:00', endTime: '11:00');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality for different values', () {
      final a = TimeSlot(day: 'monday', startTime: '10:00', endTime: '11:00');
      final b = TimeSlot(day: 'tuesday', startTime: '10:00', endTime: '11:00');

      expect(a, isNot(equals(b)));
    });

    test('toString is readable', () {
      final slot = TimeSlot(day: 'monday', startTime: '10:00', endTime: '11:00');
      expect(slot.toString(), 'monday 10:00-11:00');
    });
  });

  // ════════════════════════════════════════════════════════════
  //  RecurringLectureTemplate Tests
  // ════════════════════════════════════════════════════════════
  group('RecurringLectureTemplate', () {
    // Helper: creates a standard test template so we don't repeat
    // these 15 fields in every single test.
    RecurringLectureTemplate makeTemplate({
      String recurrencePattern = 'weekly',
      List<String> recurrenceDays = const ['monday', 'wednesday', 'friday'],
      DateTime? startDate,
      DateTime? endDate,
      bool isActive = true,
    }) {
      return RecurringLectureTemplate(
        id: 'template-1',
        assignmentId: 'assignment-1',
        teacherUid: 'teacher-1',
        studentId: 'student-1',
        subject: 'Mathematics',
        recurrencePattern: recurrencePattern,
        recurrenceDays: recurrenceDays,
        startDate: startDate ?? DateTime(2026, 1, 5), // A Monday
        endDate: endDate,
        scheduledTime: const TimeSlot(day: '', startTime: '10:00', endTime: '11:00'),
        isActive: isActive,
        seriesId: 'series-1',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
    }

    // ── shouldOccurOn ────────────────────────────────────────

    test('shouldOccurOn returns true for matching weekday', () {
      final template = makeTemplate();
      // Jan 5, 2026 is a Monday
      expect(template.shouldOccurOn(DateTime(2026, 1, 5)), isTrue);
    });

    test('shouldOccurOn returns false for non-matching weekday', () {
      final template = makeTemplate();
      // Jan 6, 2026 is a Tuesday — not in [mon, wed, fri]
      expect(template.shouldOccurOn(DateTime(2026, 1, 6)), isFalse);
    });

    test('shouldOccurOn returns true for Wednesday', () {
      final template = makeTemplate();
      // Jan 7, 2026 is a Wednesday
      expect(template.shouldOccurOn(DateTime(2026, 1, 7)), isTrue);
    });

    test('shouldOccurOn returns false before start date', () {
      final template = makeTemplate(startDate: DateTime(2026, 3, 1));
      // February is before the March start
      expect(template.shouldOccurOn(DateTime(2026, 2, 15)), isFalse);
    });

    test('shouldOccurOn returns false after end date', () {
      final template = makeTemplate(
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 31),
      );
      // Feb 2, 2026 is a Monday but after end date
      expect(template.shouldOccurOn(DateTime(2026, 2, 2)), isFalse);
    });

    test('shouldOccurOn returns false when inactive', () {
      final template = makeTemplate(isActive: false);
      // Monday within range, but template is inactive
      expect(template.shouldOccurOn(DateTime(2026, 1, 5)), isFalse);
    });

    test('shouldOccurOn returns true for daily pattern on any day', () {
      final template = makeTemplate(recurrencePattern: 'daily');
      // Tuesday — would fail for weekly [mon/wed/fri] but passes for daily
      expect(template.shouldOccurOn(DateTime(2026, 1, 6)), isTrue);
    });

    // ── copyWith ─────────────────────────────────────────────

    test('copyWith creates independent copy with changed field', () {
      final original = makeTemplate();
      final modified = original.copyWith(subject: 'Physics');

      expect(modified.subject, 'Physics');
      expect(original.subject, 'Mathematics'); // Original unchanged
      expect(modified.id, original.id); // Other fields preserved
    });

    // ── equality ─────────────────────────────────────────────

    test('two templates with same id are equal', () {
      final a = makeTemplate();
      final b = makeTemplate(); // Same id: 'template-1'

      expect(a, equals(b));
    });
  });
}
