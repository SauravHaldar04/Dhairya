import 'dart:io';

import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/core/network/download.dart';
import 'package:aparna_education/features/profile/data/models/language_learner_model.dart';
import 'package:aparna_education/features/profile/domain/entities/language_learner_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract interface class LanguageLearnerRemoteDatasource {
  FirebaseFirestore get firestore;
  FirebaseAuth get firebaseAuth;

  Future<List<LanguageLearner>> getLanguageLearners();
  Future<LanguageLearner> getLanguageLearner(String uid);
  Future<void> addLanguageLearner({
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
}

class LanguageLearnerRemoteDatasourceImpl
    implements LanguageLearnerRemoteDatasource {
  @override
  final FirebaseFirestore firestore;
  @override
  final FirebaseAuth firebaseAuth;

  LanguageLearnerRemoteDatasourceImpl(this.firestore, this.firebaseAuth);

  @override
  Future<void> addLanguageLearner({
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
      final imageUrl = await uploadAndGetDownloadUrl('profilePics', profilePic);
      final uid = firebaseAuth.currentUser!.uid;
      final languageLearner = LanguageLearnerModel(
        uid: uid,
        email: firebaseAuth.currentUser!.email!,
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        address: address,
        city: city,
        state: state,
        country: country,
        pincode: pincode,
        occupation: occupation,
        profilePic: imageUrl,
        gender: gender,
        dob: dob,
        languagesKnown: languagesKnown,
        languagesToLearn: languagesToLearn,
        emailVerified: firebaseAuth.currentUser!.emailVerified,
      );
      await firestore
          .collection('languageLearners')
          .doc(uid)
          .set(languageLearner.toMap());
      await firestore.collection('users').doc(uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'middleName': middleName,
        'userType': 'Usertype.languageLearner',
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<LanguageLearner> getLanguageLearner(String uid) async {
    try {
      final docSnapshot =
          await firestore.collection('languageLearners').doc(uid).get();
      if (docSnapshot.exists) {
        return LanguageLearnerModel.fromMap(docSnapshot.data()!);
      } else {
        throw ServerException(message: 'Language Learner not found');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<LanguageLearner>> getLanguageLearners() async {
    try {
      final querySnapshot =
          await firestore.collection('languageLearners').get();
      return querySnapshot.docs
          .map((doc) => LanguageLearnerModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
