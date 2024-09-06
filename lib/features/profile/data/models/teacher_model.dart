import 'dart:convert';
import 'dart:io';

import 'package:aparna_education/features/profile/domain/entities/teacher_entity.dart';

class TeacherModel extends Teacher {
  TeacherModel({
    required String uid,
    required String email,
    required String firstName,
    required String middleName,
    required String lastName,
    required List<String> subjects,
    required String profilePic, // Adjusted type to String
    required String address,
    required String city,
    required String state,
    required String country,
    required String pincode,
    required String phoneNumber,
    required String gender,
    required DateTime dob,
    required String workExp,
    required String resume,
    required List<String> board,
  }) : super(
          uid: uid,
          email: email,
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
          subjects: subjects,
          profilePic: profilePic,
          address: address,
          city: city,
          state: state,
          country: country,
          pincode: pincode,
          phoneNumber: phoneNumber,
          gender: gender,
          dob: dob,
          workExp: workExp,
          resume: resume,
          board: board,
        );

  TeacherModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? middleName,
    String? lastName,
    List<String>? subjects,
    String? profilePic, // Adjusted type to String
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    String? phoneNumber,
    String? gender,
    DateTime? dob,
    String? workExp,
    String? resume,
    List<String>? board,
  }) {
    return TeacherModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      subjects: subjects ?? this.subjects,
      profilePic: profilePic ?? this.profilePic,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      workExp: workExp ?? this.workExp,
      resume: resume ?? this.resume,
      board: board ?? this.board,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'subjects': subjects,
      'profilePic': profilePic, // Adjusted type to String
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'dob': dob,
      'workExp': workExp,
      'resume': resume,
      'board': board,
    };
  }

  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      middleName: map['middleName'],
      lastName: map['lastName'],
      subjects: List<String>.from(map['subjects']),
      profilePic: map['profilePic'], // Adjusted type to String
      address: map['address'],
      city: map['city'],
      state: map['state'],
      country: map['country'],
      pincode: map['pincode'],
      phoneNumber: map['phoneNumber'],
      gender: map['gender'],
      dob: map['dob'],
      workExp: map['workExp'],
      resume: map['resume'],
      board: map['board'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TeacherModel.fromJson(String source) => TeacherModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TeacherModel(uid: $uid, email: $email, firstName: $firstName, middleName: $middleName, lastName: $lastName)';
  }

  @override
  bool operator ==(covariant TeacherModel other) {
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