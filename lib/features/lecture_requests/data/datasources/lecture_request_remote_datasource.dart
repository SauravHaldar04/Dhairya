import 'package:aparna_education/core/error/server_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lecture_request_model.dart';
import '../models/teacher_interest_model.dart';
import '../models/user_notification_model.dart';

abstract interface class LectureRequestRemoteDataSource {
  Future<LectureRequestModel> createLectureRequest(LectureRequestModel request);
  Future<List<LectureRequestModel>> getParentLectureRequests(String parentUid);
  Future<LectureRequestModel> getLectureRequestById(String requestId);
  Future<List<LectureRequestModel>> getTeacherOpportunities(String teacherUid);
  Future<TeacherInterestModel> respondToOpportunity({
    required String lectureRequestId,
    required String teacherUid,
    required String studentId,
    required String subject,
    required Map<String, dynamic> preferredTimeSlots,
    required String studentGrade,
    required String interestStatus,
  });
  Future<List<UserNotificationModel>> getUserNotifications(String userId);
  Future<void> markNotificationAsRead(String notificationId);
  Future<void> triggerRequestReceivedNotification(String requestId);
}

class LectureRequestRemoteDataSourceImpl
    implements LectureRequestRemoteDataSource {
  final SupabaseClient supabaseClient;

  LectureRequestRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<LectureRequestModel> createLectureRequest(
      LectureRequestModel request) async {
    try {
      final response = await supabaseClient
          .from('lecture_requests')
          .insert(request.toJson())
          .select()
          .single();

      final createdRequest = LectureRequestModel.fromJson(response);

      // Trigger notification to admin (this will be handled by database trigger)
      // But we can also explicitly call the Edge Function if needed
      await triggerRequestReceivedNotification(createdRequest.id);

      return createdRequest;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<LectureRequestModel>> getParentLectureRequests(
      String parentUid) async {
    try {
      final response = await supabaseClient
          .from('lecture_requests')
          .select()
          .eq('parent_uid', parentUid)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => LectureRequestModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<LectureRequestModel> getLectureRequestById(String requestId) async {
    try {
      final response = await supabaseClient
          .from('lecture_requests')
          .select()
          .eq('id', requestId)
          .single();

      return LectureRequestModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<LectureRequestModel>> getTeacherOpportunities(
      String teacherUid) async {
    try {
      // Get all approved lecture requests where teacher hasn't responded yet
      final response = await supabaseClient
          .from('lecture_requests')
          .select('''
            *,
            teacher_interest_requests!left(
              id,
              teacher_uid,
              interest_status
            )
          ''')
          .eq('status', 'approved')
          .order('created_at', ascending: false);

      // Filter for requests where this teacher hasn't responded
      // or where they already responded (to show history)
      return (response as List)
          .map((json) => LectureRequestModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TeacherInterestModel> respondToOpportunity({
    required String lectureRequestId,
    required String teacherUid,
    required String studentId,
    required String subject,
    required Map<String, dynamic> preferredTimeSlots,
    required String studentGrade,
    required String interestStatus,
  }) async {
    try {
      final response = await supabaseClient
          .from('teacher_interest_requests')
          .insert({
            'lecture_request_id': lectureRequestId,
            'teacher_uid': teacherUid,
            'student_id': studentId,
            'subject': subject,
            'preferred_time_slots': preferredTimeSlots,
            'student_grade': studentGrade,
            'interest_status': interestStatus,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return TeacherInterestModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<UserNotificationModel>> getUserNotifications(
      String userId) async {
    try {
      final response = await supabaseClient
          .from('user_notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((json) => UserNotificationModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await supabaseClient
          .from('user_notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> triggerRequestReceivedNotification(String requestId) async {
    try {
      // This would typically be handled by a database trigger
      // But we can also manually call the Edge Function if needed
      // For now, we'll assume the database trigger handles it
      // If you need to manually trigger:
      /*
      await supabaseClient.functions.invoke(
        'send-request-received-notification',
        body: {
          'requestId': requestId,
          'adminUserId': 'ADMIN_USER_ID', // You'd get this from somewhere
        },
      );
      */
    } catch (e) {
      // Don't throw error if notification fails - request was still created
      print('Failed to trigger notification: $e');
    }
  }
}
