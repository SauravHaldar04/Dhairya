import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/lectures/domain/repositories/lectures_repository.dart';
import 'package:fpdart/fpdart.dart';

class LogAttendanceEventUsecase implements Usecase<void, LogAttendanceParams> {
  final LecturesRepository repository;

  LogAttendanceEventUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(LogAttendanceParams params) async {
    final result = await repository.logAttendanceEvent(
      lectureId: params.lectureId,
      participantId: params.participantId,
      participantName: params.participantName,
      eventType: params.eventType,
      deviceInfo: params.deviceInfo,
      ipAddress: params.ipAddress,
    );
    return result.mapLeft((exception) => Failure(exception.message));
  }
}

class LogAttendanceParams {
  final String lectureId;
  final String participantId;
  final String participantName;
  final String eventType; // 'joined' or 'left'
  final String? deviceInfo;
  final String? ipAddress;

  LogAttendanceParams({
    required this.lectureId,
    required this.participantId,
    required this.participantName,
    required this.eventType,
    this.deviceInfo,
    this.ipAddress,
  });
}

class GetAttendanceSummaryUsecase implements Usecase<Map<String, dynamic>, String> {
  final LecturesRepository repository;

  GetAttendanceSummaryUsecase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String lectureId) async {
    final result = await repository.getAttendanceSummary(lectureId);
    return result.mapLeft((exception) => Failure(exception.message));
  }
}
