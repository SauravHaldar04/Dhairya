import 'dart:convert';

import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/features/profile/domain/entities/language_learner_entity.dart';
import 'package:flutter/foundation.dart';

class LanguageLearnerModel extends LanguageLearner {
  LanguageLearnerModel(
      {required super.emailVerified,
      required super.uid,
      required super.middleName,
      required super.email,
      required super.firstName,
      required super.lastName,
      required super.profilePic,
      required super.gender,
      required super.dob,
      required super.occupation,
      required super.phoneNumber,
      required super.address,
      required super.city,
      required super.state,
      required super.country,
      required super.pincode,
      required super.languagesKnown,
      required super.languagesToLearn});
  LanguageLearner copyWith({
    String? profilePic,
    String? gender,
    DateTime? dob,
    String? occupation,
    String? phoneNumber,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    List<String>? languagesKnown,
    List<String>? languagesToLearn,
    Usertype? usertype,
    bool? emailVerified,
    String? uid,
    String? firstName,
    String? middleName,
    String? lastName,
    String? email,
  }) {
    return LanguageLearner(
      profilePic: profilePic ?? this.profilePic,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      occupation: occupation ?? this.occupation,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      languagesKnown: languagesKnown ?? this.languagesKnown,
      languagesToLearn: languagesToLearn ?? this.languagesToLearn,
      emailVerified: emailVerified ?? super.emailVerified,
      uid: uid ?? super.uid,
      firstName: firstName ?? super.firstName,
      middleName: middleName ?? super.middleName,
      lastName: lastName ?? super.lastName,
      email: email ?? super.email,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profile_pic': profilePic, // Match database schema
      'gender': gender,
      'dob': dob.toIso8601String(), // Convert DateTime to ISO string for Supabase
      'occupation': occupation,
      'phone_number': phoneNumber, // Match database schema
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'languages_known': languagesKnown, // Match database schema
      'languages_to_learn': languagesToLearn, // Match database schema
      'usertype': toStringValue(usertype),
    };
  }

  factory LanguageLearnerModel.fromMap(Map<String, dynamic> map) {
    return LanguageLearnerModel(
        profilePic: map['profile_pic'] ?? '', // Match database schema
        gender: map['gender'] ?? '',
        dob: DateTime.parse(map['dob']), // Parse ISO string back to DateTime for Supabase
        occupation: map['occupation'] ?? '',
        phoneNumber: map['phone_number'] ?? '', // Match database schema
        address: map['address'] ?? '',
        city: map['city'] ?? '',
        state: map['state'] ?? '',
        country: map['country'] ?? '',
        pincode: map['pincode'] ?? '',
        languagesKnown: List<String>.from(map['languages_known']), // Match database schema
        languagesToLearn: List<String>.from(map['languages_to_learn']), // Match database schema
        emailVerified: map['email_verified'], // Match database schema
        uid: map['uid'],
        middleName: map['middle_name'], // Match database schema
        firstName: map['first_name'], // Match database schema
        lastName: map['last_name'], // Match database schema
        email: map['email'],
        );
  }

  String toJson() => json.encode(toMap());

  factory LanguageLearnerModel.fromJson(String source) =>
      LanguageLearnerModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'LanguageLearner(profilePic: $profilePic, gender: $gender, dob: $dob, occupation: $occupation, phoneNumber: $phoneNumber, address: $address, city: $city, state: $state, country: $country, pincode: $pincode, languagesKnown: $languagesKnown, languagesToLearn: $languagesToLearn, usertype: $usertype)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LanguageLearner &&
        other.profilePic == profilePic &&
        other.gender == gender &&
        other.dob == dob &&
        other.occupation == occupation &&
        other.phoneNumber == phoneNumber &&
        other.address == address &&
        other.city == city &&
        other.state == state &&
        other.country == country &&
        other.pincode == pincode &&
        listEquals(other.languagesKnown, languagesKnown) &&
        listEquals(other.languagesToLearn, languagesToLearn) &&
        other.usertype == usertype;
  }

  @override
  int get hashCode {
    return profilePic.hashCode ^
        gender.hashCode ^
        dob.hashCode ^
        occupation.hashCode ^
        phoneNumber.hashCode ^
        address.hashCode ^
        city.hashCode ^
        state.hashCode ^
        country.hashCode ^
        pincode.hashCode ^
        languagesKnown.hashCode ^
        languagesToLearn.hashCode ^
        usertype.hashCode;
  }
}
