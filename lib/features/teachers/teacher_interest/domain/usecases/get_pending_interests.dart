import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/teachers/teacher_interest/domain/entities/teacher_interest_entity.dart';
import 'package:aparna_education/features/teachers/teacher_interest/domain/repositories/teacher_interest_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetPendingInterests implements Usecase<List<TeacherInterestEntity>, String> {
  final TeacherInterestRepository repository;

  GetPendingInterests(this.repository);

  @override
  Future<Either<Failure, List<TeacherInterestEntity>>> call(String teacherUid) async {
    return await repository.getPendingInterests(teacherUid);
  }
}
