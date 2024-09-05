import 'dart:io';

import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/success/success.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/profile/domain/repositories/teacher_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddTeacher implements Usecase<Success, AddTeacherParams> {
  final TeacherRepository repository;
  AddTeacher(this.repository);
  @override
  Future<Either<Failure, Success>> call(AddTeacherParams params) async {
    return await repository.addTeacher(
      firstName: params.firstName,
      middleName: params.middleName,
      lastName: params.lastName,
      email: params.email,
      phoneNumber: params.phoneNumber,
      address: params.address,
      city: params.city,
      state: params.state,
      country: params.country,
      pincode: params.pincode,
      gender: params.gender,
      dob: params.dob,
      profilePic: params.profilePic,
      board: params.board,
      workExp: params.workExp,
      subjects: params.subjects,
      resume: params.resume,
    );
  }
}

class AddTeacherParams {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String middleName;
  final List<String> subjects;
  final String profilePic;
  final List<String> board;
  final String gender;
  final DateTime dob;
  final String workExp;
  final String phoneNumber;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final File resume;
  AddTeacherParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.middleName,
    required this.subjects,
    required this.profilePic,
    required this.board,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.dob,
    required this.gender,
    required this.phoneNumber,
    required this.workExp,
    required this.resume,
  });
}
