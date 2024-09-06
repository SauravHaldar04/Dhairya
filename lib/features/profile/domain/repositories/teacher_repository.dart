import 'dart:io';

import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/success/success.dart';
import 'package:aparna_education/features/profile/domain/entities/teacher_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class TeacherRepository {
  Future<Either<Failure,Teacher>> getTeacher(String uid);
  Future<Either<Failure,List<Teacher>>> getTeachers();
  Future<Either<Failure,Success>> addTeacher({
    required String firstName,
    required String middleName,
    required String lastName,
    required String phoneNumber,
    required String address,
    required String city,
    required String state,
    required String country,
    required String pincode,
    required String gender,
    required DateTime dob,
    required File profilePic,
    required List<String> board,
    required String workExp,
    required List<String> subjects,
    required File resume,
  });
}