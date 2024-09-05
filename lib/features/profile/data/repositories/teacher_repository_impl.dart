import 'dart:io';

import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/features/auth/data/datasources/auth_remote_datasources.dart';
import 'package:aparna_education/features/profile/data/datasources/teacher_remote_datasorce.dart';
import 'package:aparna_education/features/profile/domain/entities/teacher_entity.dart';
import 'package:aparna_education/features/profile/domain/repositories/teacher_repository.dart';
import 'package:fpdart/src/either.dart';
class TeacherRepositoryImpl implements TeacherRepository{
final TeacherRemoteDatasource teacherRemoteDatasource;

  TeacherRepositoryImpl({required this.teacherRemoteDatasource});
  @override
  Future<Either<Failure, void>> addTeacher({
    required String firstName,
    required String middleName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String address,
    required String city,
    required String state,
    required String country,
    required String pincode,
    required String gender,
    required DateTime dob,
    required String profilePic,
    required List<String> board,
    required String workExp,
    required List<String> subjects,
    required File resume,
  }) async{
    try{
        await teacherRemoteDatasource.addTeacher(
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
          email: email,
          phoneNumber: phoneNumber,
          address: address,
          city: city,
          state: state,
          country: country,
          pincode: pincode,
          gender: gender,
          dob: dob,
          profilePic: profilePic,
          board: board,
          workExp: workExp,
          subjects: subjects,
          resume: resume

          );
          return Right(null);
    }
   on ServerException catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Teacher>> getTeacher(String uid) async{
    // TODO: implement getTeacher
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Teacher>>> getTeachers() async{
    // TODO: implement getTeachers
    throw UnimplementedError();
  }
}