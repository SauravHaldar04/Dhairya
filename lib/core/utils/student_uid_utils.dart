import 'package:logger/logger.dart';

class StudentUidUtils {
  static final Logger _logger = Logger();

  /// Validates that a student UID is different from parent UID
  static bool validateStudentUid(String studentUid, String parentUid) {
    if (studentUid.isEmpty || parentUid.isEmpty) {
      _logger.e(
          'StudentUidUtils: Empty UID provided - studentUid: $studentUid, parentUid: $parentUid');
      return false;
    }

    if (studentUid == parentUid) {
      _logger.e(
          'StudentUidUtils: Student UID matches parent UID - CRITICAL ERROR');
      _logger.e('StudentUid: $studentUid');
      _logger.e('ParentUid: $parentUid');
      return false;
    }

    _logger.i('StudentUidUtils: UID validation passed');
    _logger.i('StudentUid: $studentUid');
    _logger.i('ParentUid: $parentUid');
    return true;
  }

  /// Generates a unique student UID with proper formatting
  static String generateStudentUid(String parentUid) {
    if (parentUid.isEmpty) {
      throw ArgumentError('Parent UID cannot be empty');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = (timestamp % 10000).toString().padLeft(4, '0');
    final studentUid = 'student_${parentUid}_${timestamp}_$randomSuffix';

    _logger.i(
        'StudentUidUtils: Generated student UID - $studentUid for parent - $parentUid');

    // Validate the generated UID
    if (!validateStudentUid(studentUid, parentUid)) {
      throw StateError('Failed to generate valid student UID');
    }

    return studentUid;
  }

  /// Checks if a UID follows the student UID pattern
  static bool isStudentUidFormat(String uid) {
    // Student UIDs should follow pattern: student_<parentUid>_<timestamp>_<suffix>
    return uid.startsWith('student_') && uid.split('_').length >= 4;
  }

  /// Extracts parent UID from student UID
  static String? extractParentUidFromStudentUid(String studentUid) {
    if (!isStudentUidFormat(studentUid)) {
      return null;
    }

    final parts = studentUid.split('_');
    if (parts.length < 4) {
      return null;
    }

    // Reconstruct parent UID (everything between 'student_' and the last two parts)
    final parentUidParts = parts.sublist(1, parts.length - 2);
    return parentUidParts.join('_');
  }
}
