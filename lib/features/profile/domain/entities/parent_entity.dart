
import 'package:aparna_education/core/entities/user_entity.dart';
import 'package:aparna_education/core/enums/usertype_enum.dart';

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
  // List of student IDs (student_id from students table) associated with this parent
  final List<String> studentIds;
  Usertype usertype = Usertype.parent;

  Parent({
    this.studentIds = const [],
    required this.occupation,
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
    required this.usertype,

  }) : super(
         emailVerified: true,
          uid: uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          middleName: middleName,
          userType:usertype ,
        );

  Parent.empty()
      : studentIds = const [],
      profilePic = '',
        gender = '',
        dob = DateTime.now(),
        occupation = '',
        phoneNumber = '',
        address = '',
        city = '',
        state = '',
        country = '',
        pincode = '',
        super.empty();
}
