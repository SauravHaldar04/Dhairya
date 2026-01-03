class Student{
  final String uid;
  final String email;
  final String firstName;
  final String middleName;
  final String lastName;
  final bool emailVerified;
  final String parent;
  final String standard;
  final List<String> subjects;
  final String board;
  final String medium;
  final String? profilePic;

  
  Student(
      {required this.parent,
      required this.standard,
      required this.subjects,
      required this.board,
      required this.medium,
      required this.uid,
      required this.email,
      required this.firstName,
      required this.middleName,
      required this.lastName,
      required this.emailVerified,
      this.profilePic,
      }
      
      );
      
}
