import 'dart:io';

import 'package:aparna_education/core/entities/user_entity.dart';

class Teacher extends User {
  final List<String> subjects;
  final String profilePic;
  final String gender;
  final DateTime dob;
  final String workExp;
  final File resume;
  final String phoneNumber;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;

  Teacher({
    required this.subjects,
    required this.profilePic,
    required this.gender,
    required this.dob,
    required this.workExp,
    required this.resume,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
  }) : super(
          uid: uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
        );
}
