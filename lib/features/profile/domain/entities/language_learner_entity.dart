
import 'package:flutter/foundation.dart';

import 'package:aparna_education/core/entities/user_entity.dart';
import 'package:aparna_education/core/enums/usertype_enum.dart';

class LanguageLearner extends User {
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
  List<String> languagesKnown;
  List<String> languagesToLearn;
  Usertype usertype = Usertype.languageLearner;
  LanguageLearner({
    required bool emailVerified,
    required String uid,
    required String middleName,
    required String email,
    required String firstName,
    required String lastName,
    required this.profilePic,
    required this.gender,
    required this.dob,
    required this.occupation,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.languagesKnown,
    required this.languagesToLearn,
  }) : super(
          emailVerified: emailVerified,
          uid: uid,
          middleName: middleName,
          email: email,
          firstName: firstName,
          lastName: lastName,
          userType: Usertype.languageLearner,
        );

 
}
