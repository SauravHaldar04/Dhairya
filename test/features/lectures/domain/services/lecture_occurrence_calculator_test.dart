// ============================================================
// LEVEL 3: SERVICE / LOGIC TESTS (Pure logic, no mocks)
// ============================================================
// Your LectureOccurrenceCalculator is PURE LOGIC — it takes a
// template and gives back lecture instances. No Supabase, no
// network. This is the PERFECT class to unit test.
//
// 🧠 KEY CONCEPT: Pure logic classes that have no external
// dependencies are the easiest and most valuable things to test.
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:aparna_education/features/lectures/domain/entities/recurring_lecture_template_entity.dart';
import 'package:aparna_education/features/lectures/domain/entities/time_slot_entity.dart';
import 'package:aparna_education/features/lectures/domain/services/lecture_occurrence_calculator.dart';

void main() {
  // The calculator is the "system under test".
  // We create it once before all tests in this group.
  late LectureOccurrenceCalculator calculator;

  setUp(() {
    // setUp() runs BEFORE EACH test. Fresh instance every time.
    calculator = LectureOccurrenceCalculator();
  });

  // Helper: build a template without repeating 15 fields
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
      startDate: startDate ?? DateTime(2026, 1, 5), // Monday
      endDate: endDate,
      scheduledTime: const TimeSlot(day: '', startTime: '10:00', endTime: '11:00'),
      isActive: isActive,
      seriesId: 'series-1',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  getOccurrencesInRange
  // ════════════════════════════════════════════════════════════
  group('getOccurrencesInRange', () {
    test('generates correct number of occurrences for one week', () {
      // Mon/Wed/Fri template, query one full week (Mon Jan 5 – Sun Jan 11)
      final template = makeTemplate(
        startDate: DateTime(2026, 1, 5),
      );

      final occurrences = calculator.getOccurrencesInRange(
        template,
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 11),
      );

      // Mon + Wed + Fri = 3 occurrences
      expect(occurrences.length, 3);
    });

    test('occurrences have correct dates', () {
      final template = makeTemplate(startDate: DateTime(2026, 1, 5));

      final occurrences = calculator.getOccurrencesInRange(
        template,
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 11),
      );

      // Check the actual dates
      expect(occurrences[0].scheduledDate, DateTime(2026, 1, 5)); // Monday
      expect(occurrences[1].scheduledDate, DateTime(2026, 1, 7)); // Wednesday
      expect(occurrences[2].scheduledDate, DateTime(2026, 1, 9)); // Friday
    });

    test('occurrences are virtual (not materialized)', () {
      final template = makeTemplate(startDate: DateTime(2026, 1, 5));

      final occurrences = calculator.getOccurrencesInRange(
        template,
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 5),
      );

      expect(occurrences.first.isMaterialized, isFalse);
      expect(occurrences.first.isRecurring, isTrue);
    });

    test('respects template end date', () {
      final template = makeTemplate(
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 8), // Ends Thursday, Jan 8
      );

      final occurrences = calculator.getOccurrencesInRange(
        template,
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 11), // Query goes beyond template end
      );

      // Only Mon and Wed fit (Friday Jan 9 is after end date Jan 8)
      expect(occurrences.length, 2);
    });

    test('returns empty for query range before template starts', () {
      final template = makeTemplate(startDate: DateTime(2026, 2, 1));

      final occurrences = calculator.getOccurrencesInRange(
        template,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
      );

      expect(occurrences, isEmpty);
    });

    test('daily pattern generates every day', () {
      final template = makeTemplate(
        recurrencePattern: 'daily',
        startDate: DateTime(2026, 1, 5),
      );

      final occurrences = calculator.getOccurrencesInRange(
        template,
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 11),
      );

      // 7 days = 7 occurrences
      expect(occurrences.length, 7);
    });

    test('inactive template generates no occurrences', () {
      final template = makeTemplate(isActive: false);

      final occurrences = calculator.getOccurrencesInRange(
        template,
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 11),
      );

      expect(occurrences, isEmpty);
    });

    test('generates correct IDs (deterministic virtual IDs)', () {
      final template = makeTemplate(startDate: DateTime(2026, 1, 5));

      final occurrences = calculator.getOccurrencesInRange(
        template,
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 5),
      );

      // Virtual ID format: templateId_YYYY-MM-DD
      expect(occurrences.first.id, 'template-1_2026-01-05');
    });

    test('two-week query generates 6 occurrences for MWF', () {
      final template = makeTemplate(startDate: DateTime(2026, 1, 5));

      final occurrences = calculator.getOccurrencesInRange(
        template,
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 16), // ~2 weeks
      );

      // Week 1: Mon, Wed, Fri = 3
      // Week 2: Mon, Wed, Fri = 3
      expect(occurrences.length, 6);
    });
  });

  // ════════════════════════════════════════════════════════════
  //  calculateNextOccurrences
  // ════════════════════════════════════════════════════════════
  group('calculateNextOccurrences', () {
    test('returns requested count of occurrences', () {
      final template = makeTemplate(startDate: DateTime(2026, 1, 5));

      final occurrences = calculator.calculateNextOccurrences(
        template,
        count: 5,
        startFrom: DateTime(2026, 1, 5),
      );

      expect(occurrences.length, 5);
    });

    test('stops at end date even if count not reached', () {
      final template = makeTemplate(
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 9), // Only Mon, Wed, Fri fit
      );

      final occurrences = calculator.calculateNextOccurrences(
        template,
        count: 100, // Ask for 100 but only 3 are possible
        startFrom: DateTime(2026, 1, 5),
      );

      expect(occurrences.length, 3);
    });
  });

  // ════════════════════════════════════════════════════════════
  //  getNextOccurrence
  // ════════════════════════════════════════════════════════════
  group('getNextOccurrence', () {
    test('returns the very next occurrence', () {
      final template = makeTemplate(startDate: DateTime(2026, 1, 5));

      // Start looking from Tuesday Jan 6
      final next = calculator.getNextOccurrence(template, after: DateTime(2026, 1, 6));

      // Next MWF day after Tuesday is Wednesday Jan 7
      expect(next, isNotNull);
      expect(next!.scheduledDate, DateTime(2026, 1, 7));
    });

    test('returns null for inactive template', () {
      final template = makeTemplate(isActive: false);

      final next = calculator.getNextOccurrence(template);

      expect(next, isNull);
    });
  });

  // ════════════════════════════════════════════════════════════
  //  hasFutureOccurrences
  // ════════════════════════════════════════════════════════════
  group('hasFutureOccurrences', () {
    test('returns false for inactive template', () {
      final template = makeTemplate(isActive: false);
      expect(calculator.hasFutureOccurrences(template), isFalse);
    });

    test('returns false for template with past end date', () {
      final template = makeTemplate(
        startDate: DateTime(2020, 1, 1),
        endDate: DateTime(2020, 12, 31), // Ended years ago
      );
      expect(calculator.hasFutureOccurrences(template), isFalse);
    });
  });
}
