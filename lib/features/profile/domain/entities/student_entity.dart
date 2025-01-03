import 'package:aparna_education/core/entities/user_entity.dart';
import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/features/profile/domain/entities/parent_entity.dart';

class Student extends User{
  final Parent parent;
  final String standard;
  final List<String> subjects;
  final String board;
  final String medium;
  Usertype usertype = Usertype.student;
  
  Student(
      {required this.parent,
      required this.standard,
      required this.subjects,
      required this.board,
      required this.medium,
      required super.uid,
      required super.email,
      required super.firstName,
      required super.middleName,
      required super.lastName,
      required super.emailVerified, 
    super.userType = Usertype.student,
    
      }
      
      );
      
}
