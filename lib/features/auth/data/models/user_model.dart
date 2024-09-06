// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:aparna_education/core/entities/user_entity.dart';

class UserModel extends User {
  UserModel({
    required String uid,
    required String email,
    required String firstName,
    required String middleName,
    required String lastName,
  }) : super(
          uid: uid,
          email: email,
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
        );
  
  

  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? middleName,
    String? lastName,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      firstName: map['firstName'] as String,
      middleName: map['middleName'] as String,
      lastName: map['lastName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, firstName: $firstName, middleName: $middleName, lastName: $lastName)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.uid == uid &&
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
