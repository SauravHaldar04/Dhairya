import 'dart:io';

import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/success/success.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/profile/domain/repositories/teacher_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateTeacher implements Usecase<Success, UpdateTeacherParams> {
  TeacherRepository repository;
  UpdateTeacher(this.repository);

  @override
  Future<Either<Failure, Success>> call(UpdateTeacherParams params) async {
    return await repository.updateTeacher(
      firstName: params.firstName,
      middleName: params.middleName,
      lastName: params.lastName,
      phoneNumber: params.phoneNumber,
      address: params.address,
      city: params.city,
      state: params.state,
      country: params.country,
      pincode: params.pincode,
      gender: params.gender,
      dob: params.dob,
      profilePic: params.profilePic,
      workExp: params.workExp,
      subjects: params.subjects,
      board: params.board,
      resume: params.resume,
    );
  }
}

class UpdateTeacherParams {
  final String firstName;
  final String middleName;
  final String lastName;
  final String phoneNumber;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String gender;
  final DateTime dob;
  final String workExp;
  final List<String> subjects;
  final List<String> board;
  final File? profilePic;
  final File? resume;

  UpdateTeacherParams({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.gender,
    required this.dob,
    required this.workExp,
    required this.subjects,
    required this.board,
    this.profilePic,
    this.resume,
  });
}
