import 'dart:convert';

import 'package:aparna_education/features/profile/data/models/parent_model.dart';
import 'package:aparna_education/features/profile/domain/entities/parent_entity.dart';
import 'package:aparna_education/features/profile/domain/entities/student_entity.dart';

class StudentModel extends Student {
  StudentModel({
    required super.parent,
    required super.standard,
    required super.subjects,
    required super.board,
    required super.medium,
    required super.isLanguageLearner,
    required super.languagesKnown,
    required super.languagesToLearn,
    required super.occupation,
    required super.profilePic,
    required super.address,
    required super.city,
    required super.state,
    required super.country,
    required super.pincode,
    required super.uid,
    required super.email,
    required super.firstName,
    required super.middleName,
    required super.lastName,
    required super.dob,
    required super.phoneNumber,
    required super.gender,
    required super.usertype,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      parent: ParentModel.fromMap(map['parent']),
      standard: map['standard'],
      subjects: List<String>.from(map['subjects']),
      board: map['board'],
      medium: map['medium'],
      isLanguageLearner: map['isLanguageLearner'],
      languagesKnown: List<String>.from(map['languagesKnown']),
      languagesToLearn: List<String>.from(map['languagesToLearn']),
      occupation: map['occupation'],
      profilePic: map['profilePic'],
      address: map['address'],
      city: map['city'],
      state: map['state'],
      country: map['country'],
      pincode: map['pincode'],
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      middleName: map['middleName'],
      lastName: map['lastName'],
      dob: DateTime.parse(map['dob']),
      phoneNumber: map['phoneNumber'],
      gender: map['gender'], usertype: map['usertype'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parent': parent,
      'standard': standard,
      'subjects': subjects,
      'board': board,
      'medium': medium,
      'isLanguageLearner': isLanguageLearner,
      'languagesKnown': languagesKnown,
      'languagesToLearn': languagesToLearn,
      'occupation': occupation,
      'profilePic': profilePic,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'dob': dob.toIso8601String(),
      'phoneNumber': phoneNumber,
      'gender': gender,
      'usertype': usertype,
    };
  }

  String toJson() => json.encode(toMap());

  factory StudentModel.fromJson(String source) =>
      StudentModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'StudentModel(uid: $uid, email: $email, firstName: $firstName, middleName: $middleName, lastName: $lastName)';
  }

  @override
  bool operator ==(covariant StudentModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.email == email &&
        other.firstName == firstName &&
        other.middleName == middleName &&
        other.lastName == lastName;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        firstName.hashCode ^
        middleName.hashCode ^
        lastName.hashCode;
  }
}
