part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class CreateProfile extends ProfileEvent {
  final String firstName;
  final String middleName;
  final String lastName;
  final List<String> subjects;
  final File profilePic;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String phoneNumber;
  final List<String> board;
  final String gender;
  final DateTime dob;
  final String workExp;
  final File resume;
  CreateProfile({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.subjects,
    required this.profilePic,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.phoneNumber,
    required this.board,
    required this.dob,
    required this.gender,
    required this.workExp,
    required this.resume,
  });
}
