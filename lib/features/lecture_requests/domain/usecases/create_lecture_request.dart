import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/lecture_request_entity.dart';
import '../repository/lecture_request_repository.dart';

class CreateLectureRequest
    implements Usecase<LectureRequestEntity, CreateLectureRequestParams> {
  final LectureRequestRepository repository;

  CreateLectureRequest(this.repository);

  @override
  Future<Either<Failure, LectureRequestEntity>> call(
      CreateLectureRequestParams params) async {
    return await repository.createLectureRequest(
      parentUid: params.parentUid,
      studentId: params.studentId,
      subjects: params.subjects,
      preferredTimeSlots: params.preferredTimeSlots,
      priorityLevel: params.priorityLevel,
      additionalNotes: params.additionalNotes,
      requestedStartDate: params.requestedStartDate,
      frequency: params.frequency,
    );
  }
}

class CreateLectureRequestParams {
  final String parentUid;
  final String studentId;
  final List<String> subjects;
  final Map<String, dynamic> preferredTimeSlots;
  final int? priorityLevel;
  final String? additionalNotes;
  final DateTime? requestedStartDate;
  final String? frequency;

  CreateLectureRequestParams({
    required this.parentUid,
    required this.studentId,
    required this.subjects,
    required this.preferredTimeSlots,
    this.priorityLevel,
    this.additionalNotes,
    this.requestedStartDate,
    this.frequency,
  });
}
