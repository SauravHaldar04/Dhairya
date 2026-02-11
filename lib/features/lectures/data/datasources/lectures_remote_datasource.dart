import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/server_exception.dart';
import '../models/lecture_request_model.dart';
import '../models/lecture_model.dart';
import '../models/teacher_availability_model.dart';
import '../models/teacher_student_assignment_model.dart';
import '../../domain/entities/time_slot_entity.dart';

abstract interface class LecturesRemoteDataSource {
  // Lecture Requests
  Future<List<LectureRequestModel>> getLectureRequests({
    String? parentUid,
    String? status,
  });
  
  Future<String> createLectureRequest({
    required String parentUid,
    required String studentUid,
    required List<String> subjects,
    required List<TimeSlot> preferredTimeSlots,
    String? additionalNotes,
    DateTime? requestedStartDate,
    String frequency,
    int priorityLevel,
  });
  
  Future<void> cancelLectureRequest(String requestId);
  
  // Teacher-Student Assignments
  Future<List<TeacherStudentAssignmentModel>> getTeacherAssignments({
    required String teacherUid,
    String? assignmentStatus,
  });
  
  Future<List<TeacherStudentAssignmentModel>> getStudentAssignments({
    required String studentUid,
  });
  
  // Lectures
  Future<List<LectureModel>> getLectures({
    String? teacherUid,
    String? studentUid,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  });
  
  Future<String> createOneTimeLecture({
    required String assignmentId,
    required String teacherUid,
    required String studentUid,
    required String subject,
    required DateTime scheduledDate,
    required TimeSlot scheduledTime,
    String? notes,
    String? meetingLink,
  });
  
  Future<List<String>> createRecurringLectures({
    required String assignmentId,
    required String teacherUid,
    required String studentUid,
    required String subject,
    required DateTime startDate,
    required DateTime endDate,
    required TimeSlot timeSlot,
    required String recurrencePattern,
    List<String>? recurrenceDays,
    String? notes,
    String? meetingLink,
  });
  
  Future<void> rescheduleLecture({
    required String lectureId,
    required DateTime newDate,
    required TimeSlot newTime,
    String? reason,
  });
  
  Future<void> cancelLecture({
    required String lectureId,
    String? reason,
  });
  
  Future<void> updateLectureStatus(
    String lectureId,
    String status, {
    String? notes,
  });
  
  Future<void> markAttendance({
    required String lectureId,
    required bool attended,
    String? notes,
  });
  
  Future<List<LectureModel>> getUpcomingLectures({
    String? teacherUid,
    String? studentUid,
    int daysAhead,
  });
  
  Future<List<LectureModel>> getLectureSeries(String seriesId);
  
  // Teacher Availability
  Future<TeacherAvailabilityModel?> getTeacherAvailability(String teacherUid);
  
  Future<void> updateTeacherAvailability({
    required String teacherUid,
    required List<String> availableDays,
    required List<TimeSlot> timeSlots,
    required List<String> subjectsOffered,
  });
}

class LecturesRemoteDataSourceImpl implements LecturesRemoteDataSource {
  final SupabaseClient supabaseClient;

  LecturesRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<LectureRequestModel>> getLectureRequests({
    String? parentUid,
    String? status,
  }) async {
    try {
      var query = supabaseClient.from('lecture_requests').select();
      
      if (parentUid != null) {
        query = query.eq('parent_uid', parentUid);
      }
      if (status != null) {
        query = query.eq('status', status);
      }
      
      final response = await query.order('created_at', ascending: false);
      
      return (response as List)
          .map((item) => LectureRequestModel.fromMap(item))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get lecture requests: ${e.toString()}');
    }
  }

  @override
  Future<String> createLectureRequest({
    required String parentUid,
    required String studentUid,
    required List<String> subjects,
    required List<TimeSlot> preferredTimeSlots,
    String? additionalNotes,
    DateTime? requestedStartDate,
    String frequency = 'weekly',
    int priorityLevel = 1,
  }) async {
    try {
      final data = {
        'parent_uid': parentUid,
        'student_id': studentUid,
        'subjects': subjects,
        'preferred_time_slots': preferredTimeSlots.map((slot) => slot.toMap()).toList(),
        'status': 'pending',
        'priority_level': priorityLevel,
        'additional_notes': additionalNotes,
        'requested_start_date': requestedStartDate?.toIso8601String().split('T')[0],
        'frequency': frequency,
      };
      
      final response = await supabaseClient
          .from('lecture_requests')
          .insert(data)
          .select('id')
          .single();
      
      return response['id'] as String;
    } catch (e) {
      throw ServerException(message: 'Failed to create lecture request: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelLectureRequest(String requestId) async {
    try {
      await supabaseClient
          .from('lecture_requests')
          .delete()
          .eq('id', requestId)
          .eq('status', 'pending');
    } catch (e) {
      throw ServerException(message: 'Failed to cancel lecture request: ${e.toString()}');
    }
  }

  @override
  Future<List<TeacherStudentAssignmentModel>> getTeacherAssignments({
    required String teacherUid,
    String? assignmentStatus,
  }) async {
    try {
      var query = supabaseClient
          .from('teacher_student_assignments')
          .select()
          .eq('teacher_uid', teacherUid);
      
      if (assignmentStatus != null) {
        query = query.eq('assignment_status', assignmentStatus);
      }
      
      final response = await query.order('created_at', ascending: false);
      
      return (response as List)
          .map((item) => TeacherStudentAssignmentModel.fromMap(item))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get teacher assignments: ${e.toString()}');
    }
  }

  @override
  Future<List<TeacherStudentAssignmentModel>> getStudentAssignments({
    required String studentUid,
  }) async {
    try {
      final response = await supabaseClient
          .from('teacher_student_assignments')
          .select()
          .eq('student_id', studentUid)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((item) => TeacherStudentAssignmentModel.fromMap(item))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get student assignments: ${e.toString()}');
    }
  }

  @override
  Future<List<LectureModel>> getLectures({
    String? teacherUid,
    String? studentUid,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = supabaseClient.from('lectures').select();
      
      if (teacherUid != null) {
        query = query.eq('teacher_uid', teacherUid);
      }
      if (studentUid != null) {
        query = query.eq('student_id', studentUid);
      }
      if (status != null) {
        query = query.eq('status', status);
      }
      if (fromDate != null) {
        query = query.gte('scheduled_date', fromDate.toIso8601String().split('T')[0]);
      }
      if (toDate != null) {
        query = query.lte('scheduled_date', toDate.toIso8601String().split('T')[0]);
      }
      
      final response = await query.order('scheduled_date', ascending: true);
      
      return (response as List)
          .map((item) => LectureModel.fromMap(item))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get lectures: ${e.toString()}');
    }
  }

  @override
  Future<String> createOneTimeLecture({
    required String assignmentId,
    required String teacherUid,
    required String studentUid,
    required String subject,
    required DateTime scheduledDate,
    required TimeSlot scheduledTime,
    String? notes,
    String? meetingLink,
  }) async {
    try {
      final data = {
        'assignment_id': assignmentId,
        'teacher_uid': teacherUid,
        'student_id': studentUid,
        'subject': subject,
        'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
        'scheduled_time': scheduledTime.toMap(),
        'is_recurring': false,
        'recurrence_pattern': 'one-time',
        'status': 'scheduled',
        'notes': notes,
        'meeting_link': meetingLink,
        'attendance_marked': false,
      };
      
      final response = await supabaseClient
          .from('lectures')
          .insert(data)
          .select('id')
          .single();
      
      // Log to history
      await _logLectureHistory(
        lectureId: response['id'],
        action: 'created',
        changedBy: teacherUid,
      );
      
      return response['id'] as String;
    } catch (e) {
      throw ServerException(message: 'Failed to create lecture: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> createRecurringLectures({
    required String assignmentId,
    required String teacherUid,
    required String studentUid,
    required String subject,
    required DateTime startDate,
    required DateTime endDate,
    required TimeSlot timeSlot,
    required String recurrencePattern,
    List<String>? recurrenceDays,
    String? notes,
    String? meetingLink,
  }) async {
    try {
      final seriesId = '${teacherUid}_${DateTime.now().millisecondsSinceEpoch}';
      final lectureIds = <String>[];
      
      // Generate lecture dates based on recurrence pattern
      final dates = _generateRecurringDates(
        startDate: startDate,
        endDate: endDate,
        pattern: recurrencePattern,
        days: recurrenceDays,
      );
      
      // Create all lectures in the series
      for (final date in dates) {
        final data = {
          'assignment_id': assignmentId,
          'teacher_uid': teacherUid,
          'student_id': studentUid,
          'subject': subject,
          'scheduled_date': date.toIso8601String().split('T')[0],
          'scheduled_time': timeSlot.toMap(),
          'is_recurring': true,
          'series_id': seriesId,
          'recurrence_pattern': recurrencePattern,
          'recurrence_days': recurrenceDays,
          'recurrence_end_date': endDate.toIso8601String().split('T')[0],
          'status': 'scheduled',
          'notes': notes,
          'meeting_link': meetingLink,
          'attendance_marked': false,
        };
        
        final response = await supabaseClient
            .from('lectures')
            .insert(data)
            .select('id')
            .single();
        
        lectureIds.add(response['id'] as String);
        
        // Log to history
        await _logLectureHistory(
          lectureId: response['id'],
          action: 'created',
          changedBy: teacherUid,
        );
      }
      
      return lectureIds;
    } catch (e) {
      throw ServerException(message: 'Failed to create recurring lectures: ${e.toString()}');
    }
  }

  List<DateTime> _generateRecurringDates({
    required DateTime startDate,
    required DateTime endDate,
    required String pattern,
    List<String>? days,
  }) {
    final dates = <DateTime>[];
    var currentDate = startDate;
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      if (pattern == 'daily') {
        dates.add(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      } else if (pattern == 'weekly' && days != null) {
        final dayName = _getDayName(currentDate.weekday);
        if (days.contains(dayName.toLowerCase())) {
          dates.add(currentDate);
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }
    
    return dates;
  }

  String _getDayName(int weekday) {
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[weekday - 1];
  }

  @override
  Future<void> rescheduleLecture({
    required String lectureId,
    required DateTime newDate,
    required TimeSlot newTime,
    String? reason,
  }) async {
    try {
      // Get current lecture data
      final currentLecture = await supabaseClient
          .from('lectures')
          .select()
          .eq('id', lectureId)
          .single();
      
      // Update lecture with new date/time and mark as rescheduled
      await supabaseClient.from('lectures').update({
        'scheduled_date': newDate.toIso8601String().split('T')[0],
        'scheduled_time': newTime.toMap(),
        'original_date': currentLecture['scheduled_date'],
        'original_time': currentLecture['scheduled_time'],
        'rescheduled_reason': reason,
        'status': 'rescheduled',
      }).eq('id', lectureId);
      
      // Log to history
      await _logLectureHistory(
        lectureId: lectureId,
        action: 'rescheduled',
        oldDate: DateTime.parse(currentLecture['scheduled_date']),
        newDate: newDate,
        oldTime: currentLecture['scheduled_time'],
        newTime: newTime.toMap(),
        reason: reason,
        changedBy: currentLecture['teacher_uid'],
      );
    } catch (e) {
      throw ServerException(message: 'Failed to reschedule lecture: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelLecture({
    required String lectureId,
    String? reason,
  }) async {
    try {
      final lecture = await supabaseClient
          .from('lectures')
          .select('teacher_uid')
          .eq('id', lectureId)
          .single();
      
      await supabaseClient.from('lectures').update({
        'status': 'cancelled',
        'rescheduled_reason': reason,
      }).eq('id', lectureId);
      
      // Log to history
      await _logLectureHistory(
        lectureId: lectureId,
        action: 'cancelled',
        reason: reason,
        changedBy: lecture['teacher_uid'],
      );
    } catch (e) {
      throw ServerException(message: 'Failed to cancel lecture: ${e.toString()}');
    }
  }

  @override
  Future<void> updateLectureStatus(
    String lectureId,
    String status, {
    String? notes,
  }) async {
    try {
      final lecture = await supabaseClient
          .from('lectures')
          .select('teacher_uid')
          .eq('id', lectureId)
          .single();
      
      await supabaseClient.from('lectures').update({
        'status': status,
        if (notes != null) 'notes': notes,
      }).eq('id', lectureId);
      
      // Log to history
      await _logLectureHistory(
        lectureId: lectureId,
        action: 'status_changed',
        reason: 'Status updated to $status${notes != null ? ': $notes' : ''}',
        changedBy: lecture['teacher_uid'],
      );
    } catch (e) {
      throw ServerException(message: 'Failed to update lecture status: ${e.toString()}');
    }
  }

  @override
  Future<void> markAttendance({
    required String lectureId,
    required bool attended,
    String? notes,
  }) async {
    try {
      await supabaseClient.from('lectures').update({
        'attendance_marked': true,
        'status': attended ? 'completed' : 'completed',
        if (notes != null) 'notes': notes,
      }).eq('id', lectureId);
    } catch (e) {
      throw ServerException(message: 'Failed to mark attendance: ${e.toString()}');
    }
  }

  @override
  Future<List<LectureModel>> getUpcomingLectures({
    String? teacherUid,
    String? studentUid,
    int daysAhead = 7,
  }) async {
    try {
      final today = DateTime.now();
      final futureDate = today.add(Duration(days: daysAhead));
      
      var query = supabaseClient
          .from('lectures')
          .select()
          .gte('scheduled_date', today.toIso8601String().split('T')[0])
          .lte('scheduled_date', futureDate.toIso8601String().split('T')[0])
          .inFilter('status', ['scheduled', 'rescheduled']);
      
      if (teacherUid != null) {
        query = query.eq('teacher_uid', teacherUid);
      }
      if (studentUid != null) {
        query = query.eq('student_id', studentUid);
      }
      
      final response = await query.order('scheduled_date', ascending: true);
      
      return (response as List)
          .map((item) => LectureModel.fromMap(item))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get upcoming lectures: ${e.toString()}');
    }
  }

  @override
  Future<List<LectureModel>> getLectureSeries(String seriesId) async {
    try {
      final response = await supabaseClient
          .from('lectures')
          .select()
          .eq('series_id', seriesId)
          .order('scheduled_date', ascending: true);
      
      return (response as List)
          .map((item) => LectureModel.fromMap(item))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get lecture series: ${e.toString()}');
    }
  }

  @override
  Future<TeacherAvailabilityModel?> getTeacherAvailability(String teacherUid) async {
    try {
      final response = await supabaseClient
          .from('teacher_availability')
          .select()
          .eq('teacher_uid', teacherUid)
          .maybeSingle();
      
      if (response == null) return null;
      
      return TeacherAvailabilityModel.fromMap(response);
    } catch (e) {
      throw ServerException(message: 'Failed to get teacher availability: ${e.toString()}');
    }
  }

  @override
  Future<void> updateTeacherAvailability({
    required String teacherUid,
    required List<String> availableDays,
    required List<TimeSlot> timeSlots,
    required List<String> subjectsOffered,
  }) async {
    try {
      final data = {
        'teacher_uid': teacherUid,
        'available_days': availableDays,
        'time_slots': timeSlots.map((slot) => slot.toMap()).toList(),
        'subjects_offered': subjectsOffered,
        'is_active': true,
      };
      
      await supabaseClient
          .from('teacher_availability')
          .upsert(data, onConflict: 'teacher_uid');
    } catch (e) {
      throw ServerException(message: 'Failed to update teacher availability: ${e.toString()}');
    }
  }

  Future<void> _logLectureHistory({
    required String lectureId,
    required String action,
    DateTime? oldDate,
    DateTime? newDate,
    Map<String, dynamic>? oldTime,
    Map<String, dynamic>? newTime,
    String? reason,
    required String changedBy,
  }) async {
    try {
      await supabaseClient.from('lecture_history').insert({
        'lecture_id': lectureId,
        'action': action,
        if (oldDate != null) 'old_date': oldDate.toIso8601String().split('T')[0],
        if (newDate != null) 'new_date': newDate.toIso8601String().split('T')[0],
        if (oldTime != null) 'old_time': oldTime,
        if (newTime != null) 'new_time': newTime,
        'reason': reason,
        'changed_by': changedBy,
      });
    } catch (e) {
      // Don't throw on history logging failure
      print('Warning: Failed to log lecture history: ${e.toString()}');
    }
  }
}
