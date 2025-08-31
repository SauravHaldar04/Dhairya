import 'dart:convert';

import 'package:aparna_education/features/profile/domain/entities/student_entity.dart';

class StudentModel extends Student {
  StudentModel({
    required super.parent,
    required super.standard,
    required super.subjects,
    required super.board,
    required super.medium,
    required super.uid,
    required super.email,
    required super.firstName,
    required super.middleName,
    required super.lastName,
    required super.emailVerified,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      parent: map['parent_uid'], // Match database schema
      standard: map['standard'],
      subjects: List<String>.from(map['subjects']),
      board: map['board'],
      medium: map['medium'],
      uid: map['uid'],
      email: map['email'],
      firstName: map['first_name'], // Match database schema
      middleName: map['middle_name'], // Match database schema
      lastName: map['last_name'], // Match database schema
      emailVerified: map['email_verified'], // Match database schema
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parent_uid': parent, // Match database schema
      'standard': standard,
      'subjects': subjects,
      'board': board,
      'medium': medium,
      'uid': uid,
      'email': email,
      'first_name': firstName, // Match database schema
      'middle_name': middleName, // Match database schema
      'last_name': lastName, // Match database schema
      'email_verified': emailVerified, // Match database schema
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
