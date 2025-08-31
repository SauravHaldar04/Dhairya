// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:fpdart/src/either.dart';

import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/core/network/check_internet_connection.dart';
import 'package:aparna_education/core/success/success.dart';
import 'package:aparna_education/features/profile/data/datasources/parent_remote_datasource.dart';
import 'package:aparna_education/features/profile/domain/entities/parent_entity.dart';
import 'package:aparna_education/features/profile/domain/repositories/parent_repository.dart';

class ParentRepositoryImpl implements ParentRepository {
  CheckInternetConnection checkInternetConnection;
  ParentRemoteDatasource parentRemoteDatasource;
  ParentRepositoryImpl(
    this.checkInternetConnection,
    this.parentRemoteDatasource,
  );
  @override
  Future<Either<Failure, Success>> addParent(
      {required String firstName,
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
      required String occupation}) async {
    try {
      bool isConnected = await checkInternetConnection.isConnected;
      if (!isConnected) {
        return Left(Failure('No internet connection'));
      }
      await parentRemoteDatasource.addParent(
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
      );
      return Right(Success("Parent Profile Added Successfully"));
    } on ServerException catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Parent>> getParent(String uid) async {
    try {
      bool isConnected = await checkInternetConnection.isConnected;
      if (!isConnected) {
        return Left(Failure('No internet connection'));
      }
      final parent = await parentRemoteDatasource.getParent(uid);
      return Right(parent);
    } on ServerException catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Parent>>> getParents() async {
    try {
      bool isConnected = await checkInternetConnection.isConnected;
      if (!isConnected) {
        return Left(Failure('No internet connection'));
      }
      final parents = await parentRemoteDatasource.getParents();
      return Right(parents);
    } on ServerException catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      bool isConnected = await checkInternetConnection.isConnected;
      if (!isConnected) {
        return Left(Failure('No internet connection'));
      }
      await parentRemoteDatasource.updateParent(
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
      );
      return Right(Success("Parent Profile Updated Successfully"));
    } on ServerException catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
