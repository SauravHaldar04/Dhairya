import 'dart:io';

import 'package:aparna_education/core/entities/user_entity.dart';
import 'package:aparna_education/core/enums/usertype_enum.dart';

class Teacher extends User {
  final List<String> subjects;
  final String profilePic;
  final String gender;
  final DateTime dob;
  final String workExp;
  final String resume;
  final List<String> board;
  final String phoneNumber;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  Usertype usertype = Usertype.teacher;


  Teacher({

    required this.board,
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
    required String middleName,
    required this.usertype,
  }) : super(
    emailVerified: true,
          uid: uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          middleName: middleName,
          userType: Usertype.teacher,
        );
}
