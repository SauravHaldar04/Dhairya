import 'dart:io';

import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/success/success.dart';
import 'package:aparna_education/features/profile/domain/entities/language_learner_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class LanguageLearnerRepository {
  /// Adds a new language learner to the database.
  Future<Either<Failure, Success>> addLanguageLearner({
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
    required List<String> languagesKnown,
    required List<String> languagesToLearn,
  });

  /// Fetches a single language learner by UID.
  Future<Either<Failure, LanguageLearner>> getLanguageLearner(String uid);

  /// Fetches all language learners from the database.
  Future<Either<Failure, List<LanguageLearner>>> getLanguageLearners();
}
