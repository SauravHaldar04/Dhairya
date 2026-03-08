import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/recurring_lecture_template_entity.dart';
import '../repositories/lectures_repository.dart';

/// Use Case: Get recurring lecture templates
/// Returns list of templates filtered by teacher/student/active status
class GetTemplates implements Usecase<List<RecurringLectureTemplate>, GetTemplatesParams> {
  final LecturesRepository repository;

  GetTemplates(this.repository);

  @override
  Future<Either<Failure, List<RecurringLectureTemplate>>> call(GetTemplatesParams params) async {
    final result = await repository.getTemplates(
      teacherUid: params.teacherUid,
      studentUid: params.studentUid,
      isActive: params.isActive,
    );
    
    return result.fold(
      (serverException) => Left(Failure(serverException.message)),
      (templates) => Right(templates),
    );
  }
}

class GetTemplatesParams {
  final String? teacherUid;
  final String? studentUid;
  final bool? isActive;

  GetTemplatesParams({
    this.teacherUid,
    this.studentUid,
    this.isActive,
  });
}
