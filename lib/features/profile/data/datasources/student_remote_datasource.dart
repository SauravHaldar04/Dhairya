import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/core/utils/student_uid_utils.dart';
import 'package:aparna_education/features/profile/data/models/parent_model.dart';
import 'package:aparna_education/features/profile/data/models/student_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

abstract interface class StudentRemoteDatasource {
  SupabaseClient get supabaseClient;

  Future<void> addStudent({
    required String firstName,
    required String middleName,
    required String lastName,
    required String standard,
    required List<String> subjects,
    required String board,
    required String medium,
  });

  Future<List<StudentModel>> getStudentsByParent(String parentId);
}

class StudentRemoteDatasourceImpl implements StudentRemoteDatasource {
  @override
  final SupabaseClient supabaseClient;
  final Logger _logger = Logger();

  StudentRemoteDatasourceImpl(this.supabaseClient);

  @override
  Future<void> addStudent({
    required String firstName,
    required String middleName,
    required String lastName,
    required String standard,
    required List<String> subjects,
    required String board,
    required String medium,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw ServerException(message: 'User not authenticated');
      
      final parentId = user.id;

      // Get parent data to associate with student
      final parentData = await supabaseClient
          .from('parents')
          .select()
          .eq('uid', parentId)
          .single();
      
      // Verify parent data exists
      ParentModel.fromMap(parentData);

      // Generate unique student UID using utility function
      String studentUid;
      bool uidExists = true;
      int attempts = 0;
      const maxAttempts = 5;

      do {
        attempts++;
        if (attempts > maxAttempts) {
          _logger.e('Failed to generate unique student ID after $maxAttempts attempts');
          throw ServerException(message: 'Failed to generate unique student ID after $maxAttempts attempts');
        }

        try {
          studentUid = StudentUidUtils.generateStudentUid(parentId);
        } catch (e) {
          _logger.e('Error generating student UID: $e');
          throw ServerException(message: 'Error generating student UID: $e');
        }

        // Validate UID using utility function
        if (!StudentUidUtils.validateStudentUid(studentUid, parentId)) {
          _logger.e('Generated student UID failed validation');
          throw ServerException(message: 'Generated student UID failed validation');
        }

        // Check if UID already exists in students collection
        final existingStudents = await supabaseClient
            .from('students')
            .select()
            .eq('uid', studentUid);
        uidExists = existingStudents.isNotEmpty;

        // Also check in parents collection to ensure no collision
        if (!uidExists) {
          final existingParents = await supabaseClient
              .from('parents')
              .select()
              .eq('uid', studentUid);
          uidExists = existingParents.isNotEmpty;
        }

        if (uidExists) {
          _logger.w('Student UID collision detected, generating new UID. Attempt: $attempts');
        }
      } while (uidExists);

      // Final validation before saving
      if (!StudentUidUtils.validateStudentUid(studentUid, parentId)) {
        _logger.e('Final validation failed for student UID');
        throw ServerException(message: 'Final validation failed for student UID');
      }

      // Create student model
      final student = StudentModel(
        uid: studentUid,
        email: user.email!,
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        emailVerified: true,
        parent: parentId,
        standard: standard,
        subjects: subjects,
        board: board,
        medium: medium,
      );

      // Save student to database
      await supabaseClient.from('students').insert(student.toMap());

      _logger.i('Student added successfully with UID: $studentUid for parent: $parentId');
    } catch (e) {
      _logger.e('Error adding student: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<StudentModel>> getStudentsByParent(String parentId) async {
    try {
      final response = await supabaseClient
          .from('students')
          .select()
          .eq('parent_uid', parentId); // Match database schema

      return response
          .map<StudentModel>((json) => StudentModel.fromMap(json))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
