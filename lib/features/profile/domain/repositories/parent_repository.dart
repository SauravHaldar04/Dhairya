import 'dart:io';

import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/success/success.dart';
import 'package:aparna_education/features/profile/domain/entities/parent_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ParentRepository {
  Future<Either<Failure, Success>> addParent({
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
    required String occupation,
  });
  Future<Either<Failure, Success>> updateParent({
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
    File? profilePic,
    required String occupation,
  });
  Future<Either<Failure, Parent>> getParent(String uid);
  Future<Either<Failure, List<Parent>>> getParents();
}
