import 'dart:io';

import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/core/network/download.dart';
import 'package:aparna_education/features/profile/data/models/parent_model.dart';
import 'package:aparna_education/features/profile/domain/entities/parent_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract interface class ParentRemoteDatasource {
  FirebaseFirestore get firestore;
  FirebaseAuth get firebaseAuth;
  Future<List<Parent>> getParents();
  Future<Parent> getParent(String uid);
  Future<void> addParent({
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
}

class ParentRemoteDatasourceImpl implements ParentRemoteDatasource {
  @override
  final FirebaseFirestore firestore;
  @override
  final FirebaseAuth firebaseAuth;
  ParentRemoteDatasourceImpl(this.firestore, this.firebaseAuth);

  @override
  Future<void> addParent(
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
      final imageUrl = await uploadAndGetDownloadUrl('profilePics', profilePic);
      final uid = firebaseAuth.currentUser!.uid;
      final parent = ParentModel(
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
        usertype: Usertype.parent,
      );
      await firestore.collection('parents').doc(uid).set(parent.toMap());
      await firestore.collection('users').doc(uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'middleName': middleName,
        'userType': 'UserType.parent',
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Parent> getParent(String uid) {
    // TODO: implement getParent
    throw UnimplementedError();
  }

  @override
  Future<List<Parent>> getParents() {
    // TODO: implement getParents
    throw UnimplementedError();
  }
}
