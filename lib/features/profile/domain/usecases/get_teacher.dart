import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/profile/domain/entities/teacher_entity.dart';
import 'package:aparna_education/features/profile/domain/repositories/teacher_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetTeacher implements Usecase<Teacher, GetTeacherParams> {
  final TeacherRepository repository;

  GetTeacher(this.repository);

  @override
  Future<Either<Failure, Teacher>> call(GetTeacherParams params) {
    return repository.getTeacher(params.uid);
  }
}

class GetTeacherParams {
  final String uid;

  GetTeacherParams({required this.uid});
}
