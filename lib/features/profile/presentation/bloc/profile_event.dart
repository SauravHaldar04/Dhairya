part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent {}

class CreateProfile extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String middleName;
  final List<String> subjects;
  final File profilePic;
  final List<String> board;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final DateTime dob;
  final String gender;
  final String phoneNumber;
  final String workExp;
  final File? resume;

  CreateProfile({
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.subjects,
    required this.profilePic,
    required this.board,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.dob,
    required this.gender,
    required this.phoneNumber,
    required this.workExp,
    this.resume,
  });
}

class GetCurrentUser extends ProfileEvent {}

class CreateParentProfile extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String middleName;
  final File profilePic;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final DateTime dob;
  final String gender;
  final String phoneNumber;
  final String occupation;

  CreateParentProfile({
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.profilePic,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.dob,
    required this.gender,
    required this.phoneNumber,
    required this.occupation,
  });
}

class UpdateParentProfile extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String middleName;
  final File? profilePic;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final DateTime dob;
  final String gender;
  final String phoneNumber;
  final String occupation;

  UpdateParentProfile({
    required this.firstName,
    required this.lastName,
    required this.middleName,
    this.profilePic,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.dob,
    required this.gender,
    required this.phoneNumber,
    required this.occupation,
  });
}

class CreateLanguageLearnerProfile extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String middleName;
  final File profilePic;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final DateTime dob;
  final String gender;
  final String phoneNumber;
  final String occupation;
  final List<String> languagesKnown;
  final List<String> languagesToLearn;

  CreateLanguageLearnerProfile({
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.profilePic,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.dob,
    required this.gender,
    required this.phoneNumber,
    required this.occupation,
    required this.languagesKnown,
    required this.languagesToLearn,
  });
}

class GetParentData extends ProfileEvent {
  final String uid;

  GetParentData({required this.uid});
}

class AddStudentProfile extends ProfileEvent {
  final String firstName;
  final String middleName;
  final String lastName;
  final String standard;
  final List<String> subjects;
  final String board;
  final String medium;

  AddStudentProfile({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.standard,
    required this.subjects,
    required this.board,
    required this.medium,
  });
}

class GetStudentsbyParent extends ProfileEvent {
  final String uid;

  GetStudentsbyParent({required this.uid});
}
