import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/success/success.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/profile/domain/repositories/student_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddStudent implements Usecase<Success, AddStudentParams> {
  final StudentRepository repository;
  
  AddStudent(this.repository);
  
  @override
  Future<Either<Failure, Success>> call(AddStudentParams params) async {
    return await repository.addStudent(
      firstName: params.firstName,
      middleName: params.middleName,
      lastName: params.lastName,
      standard: params.standard,
      subjects: params.subjects,
      board: params.board,
      medium: params.medium,
    );
  }
}

class AddStudentParams {
  final String firstName;
  final String middleName;
  final String lastName;
  final String standard;
  final List<String> subjects;
  final String board;
  final String medium;
  
  AddStudentParams({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.standard,
    required this.subjects,
    required this.board,
    required this.medium,
  });
}
