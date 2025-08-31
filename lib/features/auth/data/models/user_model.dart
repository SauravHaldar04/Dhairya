// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:aparna_education/core/entities/user_entity.dart';
import 'package:aparna_education/core/enums/usertype_enum.dart';

class UserModel extends User {
  UserModel({
    required String uid,
    required String email,
    required String firstName,
    required String middleName,
    required String lastName,
    required bool emailVerified,
    required Usertype userType,
  }) : super(
          emailVerified: emailVerified,
          uid: uid,
          email: email,
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
          userType: userType,
        );

  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? middleName,
    String? lastName,
    bool? emailVerified,
    Usertype? userType,
  }) {
    return UserModel(
      emailVerified: emailVerified ?? false,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      userType: userType ?? this.userType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'email': email,
      'first_name': firstName, // Match database schema
      'middle_name': middleName, // Match database schema
      'last_name': lastName, // Match database schema
      'email_verified': emailVerified, // Match database schema
      'user_type': toStringValue(userType), // Match database schema
    };
  }


  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      emailVerified: map['email_verified'] ?? false, // Match database schema
      uid: map['uid'] as String,
      email: map['email'] as String,
      firstName: map['first_name'] as String, // Match database schema
      middleName: map['middle_name'] as String, // Match database schema
      lastName: map['last_name'] as String, // Match database schema
      userType: getEnumFromString(map['user_type']), // Match database schema
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, firstName: $firstName, middleName: $middleName, lastName: $lastName,emailVerified: $emailVerified,userType: $userType)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.email == email &&
        other.firstName == firstName &&
        other.middleName == middleName &&
        other.lastName == lastName &&
        other.emailVerified == emailVerified &&
        other.userType == userType;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        firstName.hashCode ^
        middleName.hashCode ^
        emailVerified.hashCode ^
        lastName.hashCode ^
        userType.hashCode;
  }
}
