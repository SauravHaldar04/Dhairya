import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/features/teachers/teacher_interest/data/models/teacher_interest_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class TeacherInterestRemoteDataSource {
  Future<List<TeacherInterestModel>> getPendingInterests(String teacherUid);
  Future<void> updateInterestStatus(String interestId, String status);
}

class TeacherInterestRemoteDataSourceImpl implements TeacherInterestRemoteDataSource {
  final SupabaseClient supabaseClient;

  TeacherInterestRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<TeacherInterestModel>> getPendingInterests(String teacherUid) async {
    try {
      final response = await supabaseClient
          .from('teacher_interest_requests')
          .select('''
            *,
            students (
              first_name,
              last_name,
              parents (
                first_name,
                last_name
              )
            )
          ''')
          .eq('teacher_uid', teacherUid)
          .eq('interest_status', 'pending')
          .order('created_at', ascending: false);

      return (response as List).map((json) => TeacherInterestModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch pending interests');
    }
  }

  @override
  Future<void> updateInterestStatus(String interestId, String status) async {
    try {
      await supabaseClient
          .from('teacher_interest_requests')
          .update({
            'interest_status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', interestId);
    } catch (e) {
      throw ServerException(message: 'Failed to update interest status');
    }
  }
}
