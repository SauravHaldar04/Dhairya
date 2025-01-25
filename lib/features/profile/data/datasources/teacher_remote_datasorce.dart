import 'dart:io';

import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/core/network/download.dart';
import 'package:aparna_education/features/profile/data/models/teacher_model.dart';
import 'package:aparna_education/features/profile/domain/entities/teacher_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract interface class TeacherRemoteDatasource {
  FirebaseFirestore get firestore;
  FirebaseAuth get firebaseAuth;
  Future<List<Teacher>> getTeachers();
  Future<Teacher> getTeacher(String uid);
  Future<void> addTeacher({
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

class TeacherRemoteDatasorceImpl implements TeacherRemoteDatasource {
  @override
  final FirebaseFirestore firestore;
  @override
  final FirebaseAuth firebaseAuth;
  TeacherRemoteDatasorceImpl(this.firestore, this.firebaseAuth);

  @override
  Future<Teacher> getTeacher(String uid) async {
    // TODO: implement getTeacher
    throw UnimplementedError();
  }

  @override
  Future<List<Teacher>> getTeachers() async {
    // TODO: implement getTeachers
    throw UnimplementedError();
  }

  @override
  Future<void> addTeacher(
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
      required List<String> board,
      required String workExp,
      required List<String> subjects,
      required File resume}) async {
    try {
      final imageUrl = await uploadAndGetDownloadUrl('profilePics', profilePic);
      final resumeUrl = await uploadAndGetDownloadUrl('resumes', resume);
      final teacher = TeacherModel(
          uid: firebaseAuth.currentUser!.uid,
          email: firebaseAuth.currentUser!.email!,
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
          subjects: subjects,
          profilePic: imageUrl,
          address: address,
          city: city,
          state: state,
          country: country,
          pincode: pincode,
          phoneNumber: phoneNumber,
          gender: gender,
          dob: dob,
          workExp: workExp,
          resume: resumeUrl,
          board: board,
          usertype: Usertype.teacher);
      await firestore
          .collection('teachers')
          .doc(firebaseAuth.currentUser!.uid)
          .set(teacher.toMap());
      await firestore
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .update({
        'firstName': firstName,
        'lastName': lastName,
        'middleName': middleName,
        'userType': 'Usertype.teacher',
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
