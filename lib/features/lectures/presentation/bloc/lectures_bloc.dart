import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/lecture_request_entity.dart';
import '../../domain/entities/lecture_entity.dart';
import '../../domain/entities/teacher_availability_entity.dart';
import '../../domain/entities/teacher_student_assignment_entity.dart';
import '../../domain/entities/recurring_lecture_template_entity.dart';
import '../../domain/entities/lecture_notification_entity.dart';
import '../../domain/entities/time_slot_entity.dart';
import '../../domain/repositories/lectures_repository.dart';
import '../../domain/usecases/get_templates.dart';
import '../../domain/usecases/update_template.dart';
import '../../domain/usecases/delete_template.dart';
import '../../domain/usecases/materialize_lecture.dart';
import '../../domain/usecases/schedule_lecture_notification.dart';
import '../../domain/usecases/get_lecture_notifications.dart';

part 'lectures_event.dart';
part 'lectures_state.dart';

class LecturesBloc extends Bloc<LecturesEvent, LecturesState> {
  final LecturesRepository _repository;
  final GetTemplates _getTemplates;
  final UpdateTemplate _updateTemplate;
  final DeleteTemplate _deleteTemplate;
  final MaterializeLecture _materializeLecture;
  final ScheduleLectureNotification _scheduleNotification;
  final GetLectureNotifications _getNotifications;

  LecturesBloc(
    this._repository,
    this._getTemplates,
    this._updateTemplate,
    this._deleteTemplate,
    this._materializeLecture,
    this._scheduleNotification,
    this._getNotifications,
  ) : super(LecturesInitial()) {
    // Lecture Requests
    on<GetLectureRequestsEvent>(_onGetLectureRequests);
    on<CreateLectureRequestEvent>(_onCreateLectureRequest);
    on<CancelLectureRequestEvent>(_onCancelLectureRequest);

    // Teacher-Student Assignments
    on<GetTeacherAssignmentsEvent>(_onGetTeacherAssignments);
    on<GetStudentAssignmentsEvent>(_onGetStudentAssignments);

    // Lectures
    on<GetLecturesEvent>(_onGetLectures);
    on<CreateOneTimeLectureEvent>(_onCreateOneTimeLecture);
    on<CreateRecurringLectureTemplateEvent>(_onCreateRecurringLectureTemplate);
    on<RescheduleLectureEvent>(_onRescheduleLecture);
    on<CancelLectureEvent>(_onCancelLecture);
    on<UpdateLectureStatusEvent>(_onUpdateLectureStatus);
    on<MarkAttendanceEvent>(_onMarkAttendance);
    on<GetUpcomingLecturesEvent>(_onGetUpcomingLectures);
    on<GetLectureSeriesEvent>(_onGetLectureSeries);

    // Recurring Lecture Templates (Alarm-Clock Pattern)
    on<GetTemplatesEvent>(_onGetTemplates);
    on<UpdateTemplateEvent>(_onUpdateTemplate);
    on<DeleteTemplateEvent>(_onDeleteTemplate);
    on<MaterializeLectureEvent>(_onMaterializeLecture);

    // Lecture Notifications
    on<ScheduleLectureNotificationEvent>(_onScheduleNotification);
    on<GetLectureNotificationsEvent>(_onGetNotifications);

    // Teacher Availability
    on<GetTeacherAvailabilityEvent>(_onGetTeacherAvailability);
    on<UpdateTeacherAvailabilityEvent>(_onUpdateTeacherAvailability);
  }

  // ============================================================
  // LECTURE REQUESTS HANDLERS
  // ============================================================

  Future<void> _onGetLectureRequests(
    GetLectureRequestsEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _repository.getLectureRequests(
      parentUid: event.parentUid,
      status: event.status,
    );
    result.fold(
      (error) => emit(LecturesError(error.message)),
      (requests) => emit(LectureRequestsLoaded(requests)),
    );
  }

  Future<void> _onCreateLectureRequest(
    CreateLectureRequestEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _repository.createLectureRequest(
      parentUid: event.parentUid,
      studentUid: event.studentUid,
      subjects: event.subjects,
      preferredTimeSlots: event.preferredTimeSlots,
      additionalNotes: event.additionalNotes,
      requestedStartDate: event.requestedStartDate,
      frequency: event.frequency,
      priorityLevel: event.priorityLevel,
    );
    result.fold(
      (error) => emit(LecturesError(error.message)),
      (requestId) => emit(LectureRequestCreated(requestId)),
    );
  }

  Future<void> _onCancelLectureRequest(
    CancelLectureRequestEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _repository.cancelLectureRequest(event.requestId);
    result.fold(
      (error) => emit(LecturesError(error.message)),
      (_) => emit(LectureRequestCancelled()),
    );
  }

  // ============================================================
  // TEACHER-STUDENT ASSIGNMENTS HANDLERS
  // ============================================================

  Future<void> _onGetTeacherAssignments(
    GetTeacherAssignmentsEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _repository.getTeacherAssignments(
      teacherUid: event.teacherUid,
      assignmentStatus: event.assignmentStatus,
    );
    result.fold(
      (error) => emit(LecturesError(error.message)),
      (assignments) => emit(TeacherAssignmentsLoaded(assignments)),
    );
  }

  Future<void> _onGetStudentAssignments(
    GetStudentAssignmentsEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _repository.getStudentAssignments(
      studentUid: event.studentUid,
    );
    result.fold(
      (error) => emit(LecturesError(error.message)),
      (assignments) => emit(StudentAssignmentsLoaded(assignments)),
    );
  }

  // ============================================================
  // LECTURES HANDLERS
  // ============================================================

  Future<void> _onGetLectures(
    GetLecturesEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _repository.getLectures(
      teacherUid: event.teacherUid,
      studentUid: event.studentUid,
      status: event.status,
      fromDate: event.fromDate,
      toDate: event.toDate,
    );
    result.fold(
      (error) => emit(LecturesError(error.message)),
      (lectures) => emit(LecturesLoaded(lectures)),
    );
  }

  Future<void> _onCreateOneTimeLecture(
    CreateOneTimeLectureEvent event,
    Emitter<LecturesState> emit,
  ) async {
    print('Creating one-time lecture...');
    emit(LecturesLoading());
    final result = await _repository.createOneTimeLecture(
      assignmentId: event.assignmentId,
      teacherUid: event.teacherUid,
      studentUid: event.studentUid,
      subject: event.subject,
      scheduledDate: event.scheduledDate,
      scheduledTime: event.scheduledTime,
      notes: event.notes,
      meetingLink: event.meetingLink,
    );
    result.fold(
      (error) {
        print('Error creating lecture: ${error.message}');
        emit(LecturesError(error.message));
      },
      (lectureId) {
        print('Lecture created successfully: $lectureId');
        emit(LectureCreated(lectureId));
      },
    );
  }

  Future<void> _onCreateRecurringLectureTemplate(
    CreateRecurringLectureTemplateEvent event,
    Emitter<LecturesState> emit,
  ) async {
    print('Creating recurring lecture template...');
    emit(LecturesLoading());
    final result = await _repository.createRecurringLectureTemplate(
      assignmentId: event.assignmentId,
      teacherUid: event.teacherUid,
      studentUid: event.studentUid,
      subject: event.subject,
      startDate: event.startDate,
      endDate: event.endDate,
      timeSlot: event.timeSlot,
      recurrencePattern: event.recurrencePattern,
      recurrenceDays: event.recurrenceDays,
      notes: event.notes,
      meetingLink: event.meetingLink,
    );
    result.fold(
      (error) {
        print('Error creating recurring lecture template: ${error.message}');
        emit(LecturesError(error.message));
      },
      (templateId) {
        print('Recurring lecture template created successfully: $templateId');
        emit(RecurringLectureTemplateCreated(templateId));
      },
    );
  }

  Future<void> _onRescheduleLecture(
    RescheduleLectureEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _repository.rescheduleLecture(
      lectureId: event.lectureId,
      newDate: event.newDate,
      newTime: event.newTime,
      reason: event.reason,
    );
    result.fold(
      (error) => emit(LecturesError(error.message)),
      (_) => emit(LectureRescheduled()),
    );
  }

  Future<void> _onCancelLecture(
    CancelLectureEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _repository.cancelLecture(
      lectureId: event.lectureId,
      reason: event.reason,
    );
    result.fold(
      (error) => emit(LecturesError(error.message)),
      (_) => emit(LectureCancelled()),
    );
  }

  Future<void> _onUpdateLectureStatus(
    UpdateLectureStatusEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _repository.updateLectureStatus(
      event.lectureId,
      event.status,
      notes: event.notes,
    );
    result.fold(
      (error) => emit(LecturesError(error.message)),
      (_) => emit(LectureStatusUpdated()),
    );
  }

  Future<void> _onMarkAttendance(
    MarkAttendanceEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _repository.markAttendance(
      lectureId: event.lectureId,
      attended: event.attended,
      notes: event.notes,
    );
    result.fold(
      (error) => emit(LecturesError(error.message)),
      (_) => emit(AttendanceMarked()),
    );
  }

  Future<void> _onGetUpcomingLectures(
    GetUpcomingLecturesEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _repository.getUpcomingLectures(
      teacherUid: event.teacherUid,
      studentUid: event.studentUid,
      daysAhead: event.daysAhead,
    );
    result.fold(
      (error) => emit(LecturesError(error.message)),
      (lectures) => emit(UpcomingLecturesLoaded(lectures)),
    );
  }

  Future<void> _onGetLectureSeries(
    GetLectureSeriesEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _repository.getLectureSeries(event.seriesId);
    result.fold(
      (error) => emit(LecturesError(error.message)),
      (lectures) => emit(LectureSeriesLoaded(lectures)),
    );
  }

  // ============================================================
  // RECURRING LECTURE TEMPLATE HANDLERS (Alarm-Clock Pattern)
  // ============================================================

  Future<void> _onGetTemplates(
    GetTemplatesEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _getTemplates(GetTemplatesParams(
      teacherUid: event.teacherUid,
      studentUid: event.studentUid,
      isActive: event.isActive,
    ));
    result.fold(
      (failure) => emit(LecturesError(failure.message)),
      (templates) => emit(TemplatesLoaded(templates)),
    );
  }

  Future<void> _onUpdateTemplate(
    UpdateTemplateEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _updateTemplate(UpdateTemplateParams(
      templateId: event.templateId,
      startDate: event.startDate,
      endDate: event.endDate,
      scheduledTime: event.scheduledTime,
      recurrenceDays: event.recurrenceDays,
      isActive: event.isActive,
      notificationEnabled: event.notificationEnabled,
      notificationMinutesBefore: event.notificationMinutesBefore,
      notes: event.notes,
      meetingLink: event.meetingLink,
    ));
    result.fold(
      (failure) => emit(LecturesError(failure.message)),
      (_) => emit(TemplateUpdated()),
    );
  }

  Future<void> _onDeleteTemplate(
    DeleteTemplateEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _deleteTemplate(DeleteTemplateParams(
      templateId: event.templateId,
    ));
    result.fold(
      (failure) => emit(LecturesError(failure.message)),
      (_) => emit(TemplateDeleted()),
    );
  }

  Future<void> _onMaterializeLecture(
    MaterializeLectureEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _materializeLecture(MaterializeLectureParams(
      virtualLectureId: event.virtualLectureId,
      templateId: event.templateId,
      scheduledDate: event.scheduledDate,
      scheduledTime: event.scheduledTime,
      reason: event.reason,
    ));
    result.fold(
      (failure) => emit(LecturesError(failure.message)),
      (lectureId) => emit(LectureMaterialized(lectureId)),
    );
  }

  // ============================================================
  // LECTURE NOTIFICATION HANDLERS
  // ============================================================

  Future<void> _onScheduleNotification(
    ScheduleLectureNotificationEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _scheduleNotification(ScheduleLectureNotificationParams(
      lectureId: event.lectureId,
      templateId: event.templateId,
      scheduledFor: event.scheduledFor,
      notificationType: event.notificationType,
    ));
    result.fold(
      (failure) => emit(LecturesError(failure.message)),
      (notificationId) => emit(NotificationScheduled(notificationId)),
    );
  }

  Future<void> _onGetNotifications(
    GetLectureNotificationsEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _getNotifications(GetLectureNotificationsParams(
      lectureId: event.lectureId,
      templateId: event.templateId,
      isSent: event.isSent,
      fromDate: event.fromDate,
      toDate: event.toDate,
    ));
    result.fold(
      (failure) => emit(LecturesError(failure.message)),
      (notifications) => emit(NotificationsLoaded(notifications)),
    );
  }

  // ============================================================
  // TEACHER AVAILABILITY HANDLERS
  // ============================================================

  Future<void> _onGetTeacherAvailability(
    GetTeacherAvailabilityEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _repository.getTeacherAvailability(event.teacherUid);
    result.fold(
      (error) => emit(LecturesError(error.message)),
      (availability) => emit(TeacherAvailabilityLoaded(availability)),
    );
  }

  Future<void> _onUpdateTeacherAvailability(
    UpdateTeacherAvailabilityEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(LecturesLoading());
    final result = await _repository.updateTeacherAvailability(
      teacherUid: event.teacherUid,
      availableDays: event.availableDays,
      timeSlots: event.timeSlots,
      subjectsOffered: event.subjectsOffered,
    );
    result.fold(
      (error) => emit(LecturesError(error.message)),
      (_) => emit(TeacherAvailabilityUpdated()),
    );
  }
}
