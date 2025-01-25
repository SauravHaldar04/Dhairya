// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:fpdart/src/either.dart';

import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/core/network/check_internet_connection.dart';
import 'package:aparna_education/core/success/success.dart';
import 'package:aparna_education/features/profile/data/datasources/language_learner_remote_datasource.dart';
import 'package:aparna_education/features/profile/domain/entities/language_learner_entity.dart';
import 'package:aparna_education/features/profile/domain/repositories/language_learner_repository.dart';

class LanguageLearnerRepositoryImpl implements LanguageLearnerRepository {
  final CheckInternetConnection checkInternetConnection;
  final LanguageLearnerRemoteDatasource languageLearnerRemoteDatasource;

  LanguageLearnerRepositoryImpl(
    this.checkInternetConnection,
    this.languageLearnerRemoteDatasource,
  );

  @override
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
  }) async {
    try {
      final isConnected = await checkInternetConnection.isConnected;
      if (!isConnected) {
        return Left(Failure('No internet connection'));
      }

      await languageLearnerRemoteDatasource.addLanguageLearner(
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        address: address,
        city: city,
        state: state,
        country: country,
        pincode: pincode,
        gender: gender,
        dob: dob,
        profilePic: profilePic,
        occupation: occupation,
        languagesKnown: languagesKnown,
        languagesToLearn: languagesToLearn,
      );

      return Right(Success("Language Learner Profile Added Successfully"));
    } on ServerException catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LanguageLearner>> getLanguageLearner(
      String uid) async {
    try {
      final isConnected = await checkInternetConnection.isConnected;
      if (!isConnected) {
        return Left(Failure('No internet connection'));
      }

      final languageLearner =
          await languageLearnerRemoteDatasource.getLanguageLearner(uid);

      return Right(languageLearner);
    } on ServerException catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LanguageLearner>>> getLanguageLearners() async {
    try {
      final isConnected = await checkInternetConnection.isConnected;
      if (!isConnected) {
        return Left(Failure('No internet connection'));
      }

      final languageLearners =
          await languageLearnerRemoteDatasource.getLanguageLearners();

      return Right(languageLearners);
    } on ServerException catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
