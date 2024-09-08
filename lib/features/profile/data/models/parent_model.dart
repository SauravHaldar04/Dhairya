import 'dart:convert';

import 'package:aparna_education/features/profile/domain/entities/parent_entity.dart';

class ParentModel extends Parent {
  ParentModel(
      {required super.occupation,
        required super.middleName,
      required super.profilePic,
      required super.gender,
      required super.dob,
      required super.phoneNumber,
      required super.address,
      required super.city,
      required super.state,
      required super.country,
      required super.pincode,
      required super.uid,
      required super.email,
      required super.firstName,
      required super.lastName});
      ParentModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? middleName,
    String? lastName,
    String? occupation,
    String? profilePic, // Adjusted type to String
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    String? phoneNumber,
    String? gender,
    DateTime? dob,

  }) {
    return ParentModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      occupation: occupation ?? this.occupation,
      profilePic: profilePic ?? this.profilePic,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'occupation': occupation,
      'profilePic': profilePic, // Adjusted type to String
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'dob': dob,

    };
  }

  factory ParentModel.fromMap(Map<String, dynamic> map) {
    return ParentModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      middleName: map['middleName'],
      lastName: map['lastName'],
      occupation: map['occupation'],
      profilePic: map['profilePic'], // Adjusted type to String
      address: map['address'],
      city: map['city'],
      state: map['state'],
      country: map['country'],
      pincode: map['pincode'],
      phoneNumber: map['phoneNumber'],
      gender: map['gender'],
      dob: map['dob'],

    );
  }

  String toJson() => json.encode(toMap());

  factory ParentModel.fromJson(String source) => ParentModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TeacherModel(uid: $uid, email: $email, firstName: $firstName, middleName: $middleName, lastName: $lastName)';
  }

  @override
  bool operator ==(covariant ParentModel other) {
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
