import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/time_slot_entity.dart';
import '../repositories/lectures_repository.dart';

/// Use Case: Update recurring lecture template
/// Modifies template settings like schedule, days, notification preferences
class UpdateTemplate implements Usecase<void, UpdateTemplateParams> {
  final LecturesRepository repository;

  UpdateTemplate(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateTemplateParams params) async {
    final result = await repository.updateTemplate(
      templateId: params.templateId,
      startDate: params.startDate,
      endDate: params.endDate,
      scheduledTime: params.scheduledTime,
      recurrenceDays: params.recurrenceDays,
      isActive: params.isActive,
      notificationEnabled: params.notificationEnabled,
      notificationMinutesBefore: params.notificationMinutesBefore,
      notes: params.notes,
      meetingLink: params.meetingLink,
    );
    
    return result.fold(
      (serverException) => Left(Failure(serverException.message)),
      (success) => const Right(null),
    );
  }
}

class UpdateTemplateParams {
  final String templateId;
  final DateTime? startDate;
  final DateTime? endDate;
  final TimeSlot? scheduledTime;
  final List<String>? recurrenceDays;
  final bool? isActive;
  final bool? notificationEnabled;
  final int? notificationMinutesBefore;
  final String? notes;
  final String? meetingLink;

  UpdateTemplateParams({
    required this.templateId,
    this.startDate,
    this.endDate,
    this.scheduledTime,
    this.recurrenceDays,
    this.isActive,
    this.notificationEnabled,
    this.notificationMinutesBefore,
    this.notes,
    this.meetingLink,
  });
}
