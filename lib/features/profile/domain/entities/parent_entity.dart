import 'dart:io';

import 'package:aparna_education/core/entities/user_entity.dart';

class Parent extends User {
  final String profilePic;
  final String gender;
  final DateTime dob;
  final String occupation;
  final String phoneNumber;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;

  Parent(
    {required  this.occupation,
    required this.profilePic,
    required this.gender,
    required this.dob,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required String uid,
    required String email,
    required String firstName,
    required String middleName,
    required String lastName,
  }) : super(
          uid: uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          middleName: middleName,
        );
}
