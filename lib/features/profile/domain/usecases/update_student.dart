import 'dart:io';

import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/success/success.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/profile/domain/repositories/student_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateStudent implements Usecase<Success, UpdateStudentParams> {
  final StudentRepository repository;

  UpdateStudent(this.repository);

  @override
  Future<Either<Failure, Success>> call(UpdateStudentParams params) async {
    return await repository.updateStudent(
      studentId: params.studentId,
      firstName: params.firstName,
      middleName: params.middleName,
      lastName: params.lastName,
      standard: params.standard,
      subjects: params.subjects,
      board: params.board,
      medium: params.medium,
      profilePic: params.profilePic,
    );
  }
}

class UpdateStudentParams {
  final String studentId;
  final String firstName;
  final String middleName;
  final String lastName;
  final String standard;
  final List<String> subjects;
  final String board;
  final String medium;
  final File? profilePic;

  UpdateStudentParams({
    required this.studentId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.standard,
    required this.subjects,
    required this.board,
    required this.medium,
    this.profilePic,
  });
}
