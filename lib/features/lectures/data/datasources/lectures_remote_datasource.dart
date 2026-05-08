import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/server_exception.dart';
import '../../../../core/utils/jitsi_meeting_utils.dart';
import '../models/lecture_request_model.dart';
import '../models/lecture_model.dart';
import '../models/teacher_availability_model.dart';
import '../models/teacher_student_assignment_model.dart';
import '../models/recurring_lecture_template_model.dart';
import '../models/lecture_notification_model.dart';
import '../../domain/entities/time_slot_entity.dart';
import '../../domain/entities/recurring_lecture_template_entity.dart';
import '../../domain/services/lecture_occurrence_calculator.dart';

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
  
  // Recurring Lecture Templates
  Future<String> createRecurringLectureTemplate({
    required String assignmentId,
    required String teacherUid,
    required String studentUid,
    required String subject,
    required DateTime startDate,
    required DateTime endDate,
    required TimeSlot timeSlot,
    required String recurrencePattern,
    required List<String> recurrenceDays,
    String? notes,
    String? meetingLink,
  });
  
  Future<List<RecurringLectureTemplateModel>> getTemplates({
    String? teacherUid,
    String? studentUid,
    bool? isActive,
  });
  
  Future<void> updateTemplate({
    required String templateId,
    DateTime? startDate,
    DateTime? endDate,
    TimeSlot? scheduledTime,
    List<String>? recurrenceDays,
    bool? isActive,
    bool? notificationEnabled,
    int? notificationMinutesBefore,
    String? notes,
    String? meetingLink,
  });
  
  Future<void> deleteTemplate(String templateId);
  
  Future<String> materializeLecture({
    required String virtualLectureId,
    required String templateId,
    required DateTime scheduledDate,
    required TimeSlot scheduledTime,
    String? reason,
  });
  
  // Lecture Notifications
  Future<String> scheduleNotification({
    String? lectureId,
    String? templateId,
    required DateTime scheduledFor,
    required String notificationType,
  });
  
  Future<List<LectureNotificationModel>> getNotifications({
    String? lectureId,
    String? templateId,
    bool? isSent,
    DateTime? fromDate,
    DateTime? toDate,
  });
  
  Future<List<String>> generateLectureInstancesFromTemplate({
    required String templateId,
    required DateTime fromDate,
    required DateTime toDate,
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
  final LectureOccurrenceCalculator occurrenceCalculator;

  LecturesRemoteDataSourceImpl(
    this.supabaseClient, {
    LectureOccurrenceCalculator? occurrenceCalculator,
  }) : occurrenceCalculator = occurrenceCalculator ?? LectureOccurrenceCalculator();

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
      // Join with students table to get student details
      var query = supabaseClient
          .from('teacher_student_assignments')
          .select('''
            *,
            students!teacher_student_assignments_student_id_fkey(
              student_id,
              first_name,
              middle_name,
              last_name,
              subjects,
              standard,
              board
            )
          ''')
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
      // ALARM-CLOCK PATTERN: Generate virtual instances on-demand
      
      // STEP 1: Fetch materialized lectures (actual rows in DB)
      var lectureQuery = supabaseClient
          .from('lectures')
          .select();
      
      if (teacherUid != null) {
        lectureQuery = lectureQuery.eq('teacher_uid', teacherUid);
      }
      if (studentUid != null) {
        lectureQuery = lectureQuery.eq('student_id', studentUid);
      }
      if (status != null) {
        lectureQuery = lectureQuery.eq('status', status);
      }
      if (fromDate != null) {
        lectureQuery = lectureQuery.gte('scheduled_date', fromDate.toIso8601String().split('T')[0]);
      }
      if (toDate != null) {
        lectureQuery = lectureQuery.lte('scheduled_date', toDate.toIso8601String().split('T')[0]);
      }
      
      final lectureResponse = await lectureQuery.order('scheduled_date', ascending: true);
      final lectureRows = (lectureResponse as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      final studentIds = lectureRows
          .map((row) => row['student_id'])
          .whereType<String>()
          .toSet()
          .toList();

      final Map<String, Map<String, dynamic>> studentsById = {};
      if (studentIds.isNotEmpty) {
        final studentsResponse = await supabaseClient
            .from('students')
            .select('student_id, first_name, middle_name, last_name, subjects, standard')
            .inFilter('student_id', studentIds);

        for (final item in (studentsResponse as List)) {
          final student = Map<String, dynamic>.from(item as Map);
          final studentId = student['student_id'] as String?;
          if (studentId != null) {
            studentsById[studentId] = student;
          }
        }
      }

      final materializedLectures = lectureRows.map((row) {
        final studentId = row['student_id'] as String?;
        if (studentId != null && studentsById.containsKey(studentId)) {
          row['students'] = studentsById[studentId];
        }
        return LectureModel.fromMap(row);
      }).toList();
      
      // STEP 2: Fetch active templates
      var templateQuery = supabaseClient
          .from('recurring_lecture_templates')
          .select()
          .eq('is_active', true);
      
      if (teacherUid != null) {
        templateQuery = templateQuery.eq('teacher_uid', teacherUid);
      }
      if (studentUid != null) {
        templateQuery = templateQuery.eq('student_id', studentUid);
      }
      
      final templateResponse = await templateQuery;
      final templates = (templateResponse as List)
          .map((item) => RecurringLectureTemplateModel.fromMap(item))
          .toList();
      
      // STEP 3: Generate virtual instances from templates
      final virtualLectures = <LectureModel>[];
      
      if (fromDate != null && toDate != null && templates.isNotEmpty) {
        for (final template in templates) {
          final occurrences = occurrenceCalculator.getOccurrencesInRange(
            template,
            startDate: fromDate,
            endDate: toDate,
          );
          
          // Filter out dates where a materialized lecture already exists
          final materializedDates = materializedLectures
              .where((l) => l.templateId == template.id)
              .map((l) => '${l.scheduledDate.year}-${l.scheduledDate.month}-${l.scheduledDate.day}')
              .toSet();
          
          for (final occurrence in occurrences) {
            final dateKey = '${occurrence.scheduledDate.year}-${occurrence.scheduledDate.month}-${occurrence.scheduledDate.day}';
            if (!materializedDates.contains(dateKey)) {
              virtualLectures.add(LectureModel.fromEntity(occurrence));
            }
          }
        }
      }
      
      // STEP 4: Merge materialized + virtual lectures
      final allLectures = [...materializedLectures, ...virtualLectures];
      
      // Sort by date
      allLectures.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
      
      return allLectures;
    } catch (e) {
      throw ServerException(message: 'Failed to get lectures: ${e.toString()}');
    }
  }

  Future<void> _ensureInstancesExist({
    String? teacherUid,
    String? studentUid,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      // Find active templates matching the criteria
      var query = supabaseClient
          .from('recurring_lecture_templates')
          .select()
          .eq('is_active', true)
          .lte('start_date', toDate.toIso8601String().split('T')[0]);
      
      // Only filter by end_date if it's not null
      query = query.or('end_date.is.null,end_date.gte.${fromDate.toIso8601String().split('T')[0]}');
      
      if (teacherUid != null) query = query.eq('teacher_uid', teacherUid);
      if (studentUid != null) query = query.eq('student_id', studentUid);
      
      final templates = await query;
      
      if (templates.isEmpty) return;
      
      print('Found ${(templates as List).length} active templates, generating instances...');
      
      // Generate instances for each template
      for (final templateData in templates) {
        final templateId = templateData['id'] as String;
        try {
          await generateLectureInstancesFromTemplate(
            templateId: templateId,
            fromDate: fromDate,
            toDate: toDate,
          );
        } catch (e) {
          print('Warning: Failed to generate instances for template $templateId: $e');
          // Continue with other templates even if one fails
        }
      }
    } catch (e) {
      print('Warning: Failed to ensure instances exist: $e');
      // Don't throw - let the query proceed even if instance generation fails
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
      print('Creating lecture with data: assignmentId=$assignmentId, teacherUid=$teacherUid, studentUid=$studentUid');
      
      final timeSlotMap = scheduledTime.toMap();
      print('TimeSlot map: $timeSlotMap');
      
      // Generate Jitsi meeting room name and URL
      // For one-time lectures, we generate a new room per lecture
      final jitsiRoomName = JitsiMeetingUtils.generateRoomName(
        '${assignmentId}_onetime'
      );
      final jitsiMeetingUrl = JitsiMeetingUtils.generateMeetingUrl(
        roomName: jitsiRoomName,
        displayName: 'Lecture',
        // Additional parameters will be added by the joining user
      );
      
      print('Generated Jitsi room: $jitsiRoomName');
      print('Generated meeting URL: $jitsiMeetingUrl');
      
      final data = {
        'assignment_id': assignmentId,
        'teacher_uid': teacherUid,
        'student_id': studentUid,
        'subject': subject,
        'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
        'scheduled_time': timeSlotMap,
        'is_recurring': false,
        'status': 'scheduled',
        'jitsi_room_name': jitsiRoomName,
        'jitsi_meeting_url': jitsiMeetingUrl,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (meetingLink != null && meetingLink.isNotEmpty) 'meeting_link': meetingLink,
        'attendance_marked': false,
      };
      
      print('Inserting lecture data: $data');
      
      final response = await supabaseClient
          .from('lectures')
          .insert(data)
          .select('id')
          .single()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Lecture creation timed out. Please check your connection.');
            },
          );
      
      print('Lecture created successfully with id: ${response['id']}');
      
      // Log to history (non-blocking)
      _logLectureHistory(
        lectureId: response['id'],
        action: 'created',
        changedBy: teacherUid,
      ).catchError((e) {
        print('Warning: Failed to log lecture history: $e');
      });
      
      return response['id'] as String;
    } catch (e) {
      print('Error creating lecture: $e');
      throw ServerException(message: 'Failed to create lecture: ${e.toString()}');
    }
  }

  @override
  Future<String> createRecurringLectureTemplate({
    required String assignmentId,
    required String teacherUid,
    required String studentUid,
    required String subject,
    required DateTime startDate,
    required DateTime endDate,
    required TimeSlot timeSlot,
    required String recurrencePattern,
    required List<String> recurrenceDays,
    String? notes,
    String? meetingLink,
  }) async {
    try {
      print('Creating recurring lecture template from $startDate to $endDate, pattern: $recurrencePattern, days: $recurrenceDays');
      final seriesId = '${teacherUid}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Generate Jitsi meeting room for the entire series
      // This ensures all instances of a recurring lecture use the same meeting room
      final jitsiRoomName = JitsiMeetingUtils.generateRoomName(seriesId);
      final jitsiMeetingUrl = JitsiMeetingUtils.generateMeetingUrl(
        roomName: jitsiRoomName,
        displayName: subject,
        // Additional parameters will be added by the joining user
      );
      
      print('Generated Jitsi room for series: $jitsiRoomName');
      print('Generated meeting URL: $jitsiMeetingUrl');
      
      // Create ONE template row
      final templateData = {
        'assignment_id': assignmentId,
        'teacher_uid': teacherUid,
        'student_id': studentUid,
        'subject': subject,
        'recurrence_pattern': recurrencePattern,
        'recurrence_days': recurrenceDays,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        'scheduled_time': timeSlot.toMap(),
        'is_active': true,
        'series_id': seriesId,
        'jitsi_room_name': jitsiRoomName,
        'jitsi_meeting_url': jitsiMeetingUrl,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (meetingLink != null && meetingLink.isNotEmpty) 'meeting_link': meetingLink,
      };
      
      print('Inserting template: $templateData');
      
      final response = await supabaseClient
          .from('recurring_lecture_templates')
          .insert(templateData)
          .select('id, series_id')
          .single()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Template creation timed out');
            },
          );
      
      print('Template created successfully: ${response['id']}');
      return response['id'] as String;
    } catch (e) {
      print('Error creating recurring lecture template: $e');
      throw ServerException(message: 'Failed to create recurring lecture: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> generateLectureInstancesFromTemplate({
    required String templateId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      print('Generating instances for template $templateId from $fromDate to $toDate');
      
      // Fetch template
      final templateData = await supabaseClient
          .from('recurring_lecture_templates')
          .select()
          .eq('id', templateId)
          .single();
      
      final template = RecurringLectureTemplateModel.fromMap(templateData);
      
      if (!template.isActive) {
        print('Template is inactive, skipping');
        return [];
      }
      
      // Generate dates within the requested range
      final dates = _generateDatesForTemplate(
        template: template,
        fromDate: fromDate,
        toDate: toDate,
      );
      
      if (dates.isEmpty) {
        print('No dates to generate');
        return [];
      }
      
      print('Generated ${dates.length} potential dates');
      
      // Check which dates don't already have instances
      final existingDates = await _getExistingInstanceDates(
        seriesId: template.seriesId,
        dates: dates,
      );
      
      final datesToCreate = dates.where((d) => !existingDates.contains(d)).toList();
      
      if (datesToCreate.isEmpty) {
        print('All instances already exist');
        return [];
      }
      
      print('Creating ${datesToCreate.length} new instances');
      
      // Create lecture instances - inherit Jitsi room from template
      final lecturesData = datesToCreate.map((date) => {
        'assignment_id': template.assignmentId,
        'teacher_uid': template.teacherUid,
        'student_id': template.studentId,
        'subject': template.subject,
        'scheduled_date': date.toIso8601String().split('T')[0],
        'scheduled_time': template.scheduledTime.toMap(),
        'is_recurring': true,
        'series_id': template.seriesId,
        'template_id': template.id,
        'recurrence_pattern': template.recurrencePattern,
        'recurrence_days': template.recurrenceDays,
        'recurrence_end_date': template.endDate?.toIso8601String().split('T')[0],
        'status': 'scheduled',
        'jitsi_room_name': template.jitsiRoomName,
        'jitsi_meeting_url': template.jitsiMeetingUrl,
        if (template.notes != null && template.notes!.isNotEmpty) 'notes': template.notes,
        if (template.meetingLink != null && template.meetingLink!.isNotEmpty) 'meeting_link': template.meetingLink,
        'attendance_marked': false,
      }).toList();
      
      final response = await supabaseClient
          .from('lectures')
          .insert(lecturesData)
          .select('id');
      
      final ids = (response as List).map((r) => r['id'] as String).toList();
      print('Generated ${ids.length} lecture instances');
      
      return ids;
    } catch (e) {
      print('Error generating instances: $e');
      throw ServerException(message: 'Failed to generate lecture instances: ${e.toString()}');
    }
  }

  List<DateTime> _generateDatesForTemplate({
    required RecurringLectureTemplate template,
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    final dates = <DateTime>[];
    var currentDate = fromDate.isAfter(template.startDate) 
        ? fromDate 
        : template.startDate;
    final effectiveEndDate = template.endDate != null && toDate.isAfter(template.endDate!)
        ? template.endDate!
        : toDate;
    
    const maxDays = 365; // Safety limit - 1 year
    var dayCount = 0;
    
    while ((currentDate.isBefore(effectiveEndDate) || currentDate.isAtSameMomentAs(effectiveEndDate)) && dayCount < maxDays) {
      if (template.shouldOccurOn(currentDate)) {
        dates.add(currentDate);
      }
      currentDate = currentDate.add(const Duration(days: 1));
      dayCount++;
    }
    
    return dates;
  }

  Future<Set<DateTime>> _getExistingInstanceDates({
    required String seriesId,
    required List<DateTime> dates,
  }) async {
    if (dates.isEmpty) return {};
    
    final dateStrings = dates.map((d) => d.toIso8601String().split('T')[0]).toList();
    
    final response = await supabaseClient
        .from('lectures')
        .select('scheduled_date')
        .eq('series_id', seriesId)
        .inFilter('scheduled_date', dateStrings);
    
    return (response as List)
        .map((r) => DateTime.parse(r['scheduled_date'] as String))
        .toSet();
  }

  @override
  Future<List<RecurringLectureTemplateModel>> getTemplates({
    String? teacherUid,
    String? studentUid,
    bool? isActive,
  }) async {
    try {
      var query = supabaseClient.from('recurring_lecture_templates').select();
      
      if (teacherUid != null) {
        query = query.eq('teacher_uid', teacherUid);
      }
      if (studentUid != null) {
        query = query.eq('student_id', studentUid);
      }
      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }
      
      final response = await query.order('start_date', ascending: false);
      
      return (response as List)
          .map((item) => RecurringLectureTemplateModel.fromMap(item))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get templates: ${e.toString()}');
    }
  }

  @override
  Future<void> updateTemplate({
    required String templateId,
    DateTime? startDate,
    DateTime? endDate,
    TimeSlot? scheduledTime,
    List<String>? recurrenceDays,
    bool? isActive,
    bool? notificationEnabled,
    int? notificationMinutesBefore,
    String? notes,
    String? meetingLink,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (startDate != null) {
        updateData['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        updateData['end_date'] = endDate.toIso8601String().split('T')[0];
      }
      if (scheduledTime != null) {
        updateData['scheduled_time'] = scheduledTime.toMap();
      }
      if (recurrenceDays != null) {
        updateData['recurrence_days'] = recurrenceDays;
      }
      if (isActive != null) {
        updateData['is_active'] = isActive;
      }
      if (notificationEnabled != null) {
        updateData['notification_enabled'] = notificationEnabled;
      }
      if (notificationMinutesBefore != null) {
        updateData['notification_minutes_before'] = notificationMinutesBefore;
      }
      if (notes != null) {
        updateData['notes'] = notes;
      }
      if (meetingLink != null) {
        updateData['meeting_link'] = meetingLink;
      }
      
      await supabaseClient
          .from('recurring_lecture_templates')
          .update(updateData)
          .eq('id', templateId);
    } catch (e) {
      throw ServerException(message: 'Failed to update template: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTemplate(String templateId) async {
    try {
      // Soft delete - just mark as inactive
      await supabaseClient
          .from('recurring_lecture_templates')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', templateId);
    } catch (e) {
      throw ServerException(message: 'Failed to delete template: ${e.toString()}');
    }
  }

  @override
  Future<String> materializeLecture({
    required String virtualLectureId,
    required String templateId,
    required DateTime scheduledDate,
    required TimeSlot scheduledTime,
    String? reason,
  }) async {
    try {
      // Fetch template to get default values
      final templateData = await supabaseClient
          .from('recurring_lecture_templates')
          .select()
          .eq('id', templateId)
          .single();
      
      final template = RecurringLectureTemplateModel.fromMap(templateData);
      
      // Insert materialized lecture
      final lectureData = {
        'assignment_id': template.assignmentId,
        'teacher_uid': template.teacherUid,
        'student_id': template.studentId,
        'subject': template.subject,
        'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
        'scheduled_time': scheduledTime.toMap(),
        'template_id': templateId,
        'is_materialized': true,
        'is_recurring': true,
        'series_id': template.seriesId,
        'recurrence_pattern': template.recurrencePattern,
        'recurrence_days': template.recurrenceDays,
        'recurrence_end_date': template.endDate?.toIso8601String().split('T')[0],
        'status': 'scheduled',
        'notes': template.notes,
        'meeting_link': template.meetingLink,
        'attendance_marked': false,
        if (reason != null) 'rescheduled_reason': reason,
      };
      
      final response = await supabaseClient
          .from('lectures')
          .insert(lectureData)
          .select('id')
          .single();
      
      return response['id'] as String;
    } catch (e) {
      throw ServerException(message: 'Failed to materialize lecture: ${e.toString()}');
    }
  }

  @override
  Future<String> scheduleNotification({
    String? lectureId,
    String? templateId,
    required DateTime scheduledFor,
    required String notificationType,
  }) async {
    try {
      final notificationData = {
        'lecture_id': lectureId,
        'template_id': templateId,
        'scheduled_for': scheduledFor.toIso8601String(),
        'notification_type': notificationType,
        'is_sent': false,
      };
      
      final response = await supabaseClient
          .from('lecture_notifications')
          .insert(notificationData)
          .select('id')
          .single();
      
      return response['id'] as String;
    } catch (e) {
      throw ServerException(message: 'Failed to schedule notification: ${e.toString()}');
    }
  }

  @override
  Future<List<LectureNotificationModel>> getNotifications({
    String? lectureId,
    String? templateId,
    bool? isSent,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = supabaseClient.from('lecture_notifications').select();
      
      if (lectureId != null) {
        query = query.eq('lecture_id', lectureId);
      }
      if (templateId != null) {
        query = query.eq('template_id', templateId);
      }
      if (isSent != null) {
        query = query.eq('is_sent', isSent);
      }
      if (fromDate != null) {
        query = query.gte('scheduled_for', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('scheduled_for', toDate.toIso8601String());
      }
      
      final response = await query.order('scheduled_for', ascending: true);
      
      return (response as List)
          .map((item) => LectureNotificationModel.fromMap(item))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get notifications: ${e.toString()}');
    }
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
      
      // Auto-generate instances for active templates
      await _ensureInstancesExist(
        teacherUid: teacherUid,
        studentUid: studentUid,
        fromDate: today,
        toDate: futureDate,
      );
      
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
