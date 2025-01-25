import 'dart:io';

import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/success/success.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/profile/domain/entities/language_learner_entity.dart';
import 'package:aparna_education/features/profile/domain/repositories/language_learner_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddLanguageLearner implements Usecase<Success, AddLanguageLearnerParams> {
  final LanguageLearnerRepository repository;

  AddLanguageLearner(this.repository);

  @override
  Future<Either<Failure, Success>> call(AddLanguageLearnerParams params) async {
    return await repository.addLanguageLearner(
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
      languagesKnown: params.languagesKnown,
      languagesToLearn: params.languagesToLearn,
    );
  }
}

class AddLanguageLearnerParams {
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
  final File profilePic;
  final List<String> languagesKnown;
  final List<String> languagesToLearn;

  AddLanguageLearnerParams({
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
    required this.profilePic,
    required this.languagesKnown,
    required this.languagesToLearn,
  });
}
