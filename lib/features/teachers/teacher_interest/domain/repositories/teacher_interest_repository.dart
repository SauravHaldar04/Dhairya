import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/features/teachers/teacher_interest/domain/entities/teacher_interest_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class TeacherInterestRepository {
  Future<Either<Failure, List<TeacherInterestEntity>>> getPendingInterests(String teacherUid);
  Future<Either<Failure, void>> updateInterestStatus(String interestId, String status);
}
