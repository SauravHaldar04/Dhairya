// ============================================================
// LEVEL 1: PURE UNIT TESTS (No dependencies, no mocks)
// ============================================================
// Start here! These test plain Dart functions — no Flutter, no mocking.
// Think of them as: "Does this function return what I expect?"
//
// 🧠 KEY CONCEPT: A unit test has 3 steps:
//   1. ARRANGE — Set up your inputs
//   2. ACT     — Call the function
//   3. ASSERT  — Check the result
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:aparna_education/core/enums/usertype_enum.dart';

void main() {
  // group() bundles related tests together.
  // It's like a folder for tests.
  group('Usertype Enum', () {
    // ── toStringValue ──────────────────────────────────────────

    // test() is a single test case. Give it a clear name that
    // describes WHAT you expect to happen.
    test('toStringValue converts Usertype.teacher to string', () {
      // ARRANGE: nothing to set up — input is just an enum value
      // ACT: call the function
      final result = toStringValue(Usertype.teacher);
      // ASSERT: check it matches
      expect(result, 'Usertype.teacher');
    });

    test('toStringValue converts Usertype.parent to string', () {
      expect(toStringValue(Usertype.parent), 'Usertype.parent');
    });

    test('toStringValue converts Usertype.languageLearner to string', () {
      expect(toStringValue(Usertype.languageLearner), 'Usertype.languageLearner');
    });

    test('toStringValue converts Usertype.none to string', () {
      expect(toStringValue(Usertype.none), 'Usertype.none');
    });

    // ── getEnumFromString ──────────────────────────────────────

    test('getEnumFromString parses "Usertype.teacher"', () {
      final result = getEnumFromString('Usertype.teacher');
      expect(result, Usertype.teacher);
    });

    test('getEnumFromString parses "Usertype.parent"', () {
      expect(getEnumFromString('Usertype.parent'), Usertype.parent);
    });

    // This tests that the normalization works (UserType → Usertype)
    test('getEnumFromString handles case variation "UserType.teacher"', () {
      expect(getEnumFromString('UserType.teacher'), Usertype.teacher);
    });

    // Testing error cases is important too!
    test('getEnumFromString throws on invalid string', () {
      // expect(() => ..., throwsA(...)) is how you test that
      // a function throws an exception.
      expect(
        () => getEnumFromString('invalid_value'),
        throwsA(isA<Exception>()),
      );
    });

    // ── Round-trip test ────────────────────────────────────────
    // Converting to string and back should give the same value.
    test('round-trip: toStringValue → getEnumFromString preserves value', () {
      for (final type in Usertype.values) {
        final asString = toStringValue(type);
        final backToEnum = getEnumFromString(asString);
        expect(backToEnum, type, reason: 'Failed for $type');
      }
    });
  });
}
