import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/teacher_interest_entity.dart';
import '../repository/lecture_request_repository.dart';

class RespondToOpportunity
    implements Usecase<TeacherInterestEntity, RespondToOpportunityParams> {
  final LectureRequestRepository repository;

  RespondToOpportunity(this.repository);

  @override
  Future<Either<Failure, TeacherInterestEntity>> call(
      RespondToOpportunityParams params) async {
    return await repository.respondToOpportunity(
      lectureRequestId: params.lectureRequestId,
      teacherUid: params.teacherUid,
      studentId: params.studentId,
      subject: params.subject,
      preferredTimeSlots: params.preferredTimeSlots,
      studentGrade: params.studentGrade,
      interestStatus: params.interestStatus,
    );
  }
}

class RespondToOpportunityParams {
  final String lectureRequestId;
  final String teacherUid;
  final String studentId;
  final String subject;
  final Map<String, dynamic> preferredTimeSlots;
  final String studentGrade;
  final String interestStatus;

  RespondToOpportunityParams({
    required this.lectureRequestId,
    required this.teacherUid,
    required this.studentId,
    required this.subject,
    required this.preferredTimeSlots,
    required this.studentGrade,
    required this.interestStatus,
  });
}
