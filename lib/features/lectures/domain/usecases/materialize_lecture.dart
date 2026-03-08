import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/time_slot_entity.dart';
import '../repositories/lectures_repository.dart';

/// Use Case: Materialize a virtual lecture instance
/// Converts a calculated virtual instance to a real DB row
/// Used when rescheduling or modifying a specific occurrence from a template
class MaterializeLecture implements Usecase<String, MaterializeLectureParams> {
  final LecturesRepository repository;

  MaterializeLecture(this.repository);

  @override
  Future<Either<Failure, String>> call(MaterializeLectureParams params) async {
    final result = await repository.materializeLecture(
      virtualLectureId: params.virtualLectureId,
      templateId: params.templateId,
      scheduledDate: params.scheduledDate,
      scheduledTime: params.scheduledTime,
      reason: params.reason,
    );
    
    return result.fold(
      (serverException) => Left(Failure(serverException.message)),
      (lectureId) => Right(lectureId),
    );
  }
}

class MaterializeLectureParams {
  final String virtualLectureId;
  final String templateId;
  final DateTime scheduledDate;
  final TimeSlot scheduledTime;
  final String? reason;

  MaterializeLectureParams({
    required this.virtualLectureId,
    required this.templateId,
    required this.scheduledDate,
    required this.scheduledTime,
    this.reason,
  });
}
