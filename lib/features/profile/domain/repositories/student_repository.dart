import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/success/success.dart';
import 'package:aparna_education/features/profile/domain/entities/student_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class StudentRepository {
  Future<Either<Failure, Success>> addStudent({
    required String firstName,
    required String middleName,
    required String lastName,
    required String standard,
    required List<String> subjects,
    required String board,
    required String medium,
  });
  
  Future<Either<Failure, List<Student>>> getStudentsByParent(String parentId);
}
