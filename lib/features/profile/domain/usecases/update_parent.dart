import 'dart:io';

import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/success/success.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/profile/domain/repositories/parent_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateParent implements Usecase<Success, UpdateParentParams> {
  ParentRepository repository;
  UpdateParent(this.repository);

  @override
  Future<Either<Failure, Success>> call(UpdateParentParams params) async {
    return await repository.updateParent(
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
      occupation: params.occupation,
    );
  }
}

class UpdateParentParams {
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
  final String occupation;
  final File? profilePic;

  UpdateParentParams({
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
    required this.occupation,
    this.profilePic,
  });
}
