// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:aparna_education/core/enums/usertype_enum.dart';

class User {
  final String uid;
  final String email;
  final String firstName;
  final String middleName;
  final String lastName;
  final bool emailVerified;
  Usertype userType;


  User({
    required this.emailVerified,
    required this.uid,
    required this.middleName,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userType,
  });

  User.empty()

      : 
      emailVerified = false,
      uid = '',
        email = '',
        firstName = '',
        middleName = '',
        lastName = '',
       userType = Usertype.none;
}
