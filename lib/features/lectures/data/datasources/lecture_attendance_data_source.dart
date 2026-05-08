import 'package:aparna_education/core/error/server_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class LectureAttendanceDataSource {
  /// Log a participant join event
  Future<void> logAttendanceEvent({
    required String lectureId,
    required String participantId,
    required String participantName,
    required String eventType, // 'joined' or 'left'
    String? deviceInfo,
    String? ipAddress,
  });

  /// Get attendance summary for a lecture
  Future<Map<String, dynamic>> getAttendanceSummary(String lectureId);

  /// Get all attendance events for a lecture
  Future<List<Map<String, dynamic>>> getLectureAttendanceEvents(String lectureId);

  /// Get participant attendance duration
  Future<Map<String, dynamic>> getParticipantDuration(
    String lectureId,
    String participantId,
  );
}

class LectureAttendanceDataSourceImpl implements LectureAttendanceDataSource {
  final SupabaseClient supabaseClient;

  LectureAttendanceDataSourceImpl(this.supabaseClient);

  @override
  Future<void> logAttendanceEvent({
    required String lectureId,
    required String participantId,
    required String participantName,
    required String eventType,
    String? deviceInfo,
    String? ipAddress,
  }) async {
    try {
      await supabaseClient.from('lecture_attendance_events').insert({
        'lecture_id': lectureId,
        'participant_id': participantId,
        'participant_name': participantName,
        'event_type': eventType,
        'device_info': deviceInfo,
        'ip_address': ipAddress,
        'event_time': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to log attendance: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error logging attendance: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getAttendanceSummary(String lectureId) async {
    try {
      final response = await supabaseClient
          .from('lecture_attendance_events')
          .select('participant_id, participant_name, event_type')
          .eq('lecture_id', lectureId);

      final List<dynamic> events = response as List<dynamic>;

      // Calculate unique participants and their status
      final Map<String, Map<String, dynamic>> participants = {};
      for (final event in events) {
        final participantId = event['participant_id'] as String;
        final eventType = event['event_type'] as String;
        final name = event['participant_name'] as String;

        if (!participants.containsKey(participantId)) {
          participants[participantId] = {
            'id': participantId,
            'name': name,
            'joined': false,
            'left': false,
          };
        }

        if (eventType == 'joined') {
          participants[participantId]!['joined'] = true;
        } else if (eventType == 'left') {
          participants[participantId]!['left'] = true;
        }
      }

      return {
        'totalParticipants': participants.length,
        'presentCount': participants.values.where((p) => p['joined'] as bool).length,
        'participantsPresent': participants.values.toList(),
      };
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to fetch attendance: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error fetching attendance: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLectureAttendanceEvents(
    String lectureId,
  ) async {
    try {
      final response = await supabaseClient
          .from('lecture_attendance_events')
          .select()
          .eq('lecture_id', lectureId)
          .order('event_time', ascending: true);

      return List<Map<String, dynamic>>.from(response as List);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to fetch events: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error fetching events: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getParticipantDuration(
    String lectureId,
    String participantId,
  ) async {
    try {
      final response = await supabaseClient
          .from('lecture_attendance_events')
          .select()
          .eq('lecture_id', lectureId)
          .eq('participant_id', participantId)
          .order('event_time', ascending: true);

      final List<dynamic> events = response as List<dynamic>;
      if (events.isEmpty) {
        return {'durationMinutes': 0, 'present': false};
      }

      DateTime? joinTime;
      DateTime? leaveTime;

      for (final event in events) {
        final eventType = event['event_type'] as String;
        final eventTime = DateTime.parse(event['event_time'] as String);

        if (eventType == 'joined' && joinTime == null) {
          joinTime = eventTime;
        } else if (eventType == 'left') {
          leaveTime = eventTime;
        }
      }

      int durationMinutes = 0;
      if (joinTime != null) {
        leaveTime ??= DateTime.now();
        durationMinutes = leaveTime.difference(joinTime).inMinutes;
      }

      return {
        'durationMinutes': durationMinutes,
        'joinTime': joinTime?.toIso8601String(),
        'leaveTime': leaveTime?.toIso8601String(),
        'present': joinTime != null,
      };
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to fetch duration: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error fetching duration: $e');
    }
  }
}
