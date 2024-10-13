// ignore_for_file: public_member_api_docs, sort_constructors_first
class User {
  final String uid;
  final String email;
  final String firstName;
  final String middleName;
  final String lastName;
  final bool emailVerified;

  User({
    required this.emailVerified,
    required this.uid,
    required this.middleName,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  User.empty()

      : 
      emailVerified = false,
      uid = '',
        email = '',
        firstName = '',
        middleName = '',
        lastName = '';
}
