import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/features/profile/domain/entities/parent_entity.dart';

class Student extends Parent {
  final Parent parent;
  final String standard;
  final List<String> subjects;
  final String board;
  final String medium;
  final bool isLanguageLearner;
  final List<String> languagesKnown;
  final List<String> languagesToLearn;
  @override
  Usertype usertype = Usertype.student;
  
  Student(
      {required this.parent,
      required this.standard,
      required this.subjects,
      required this.board,
      required this.medium,
      this.isLanguageLearner = false,
      this.languagesKnown = const [],
      this.languagesToLearn = const [],
      required super.occupation,
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
      required super.middleName,
      required super.lastName,
      required super.usertype
      }
      
      );
      
}
