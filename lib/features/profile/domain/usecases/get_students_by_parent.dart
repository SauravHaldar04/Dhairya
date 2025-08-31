import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/profile/domain/entities/student_entity.dart';
import 'package:aparna_education/features/profile/domain/repositories/student_repository.dart';

import 'package:fpdart/fpdart.dart';

class GetStudentsByParent
    implements Usecase<List<Student>, GetStudentsByParentParams> {
  final StudentRepository repository;

  GetStudentsByParent(this.repository);

  @override
  Future<Either<Failure, List<Student>>> call(
      GetStudentsByParentParams params) {
    return repository.getStudentsByParent(params.parentId);
  }
}

class GetStudentsByParentParams {
  final String parentId;

  const GetStudentsByParentParams({required this.parentId});
}
