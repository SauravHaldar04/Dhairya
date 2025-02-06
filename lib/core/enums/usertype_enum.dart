enum Usertype { teacher, student, parent, admin, languageLearner, none }

String toStringValue(Usertype usertype) {
  switch (usertype) {
    case Usertype.teacher:
      return 'Usertype.teacher';
    case Usertype.student:
      return 'Usertype.student';
    case Usertype.parent:
      return 'Usertype.parent';
    case Usertype.admin:
      return 'Usertype.admin';
    case Usertype.languageLearner:
      return 'Usertype.languageLearner';
    case Usertype.none:
      return 'Usertype.none';
    default:
      return '';
  }
}

Usertype getEnumFromString(String value) {
  // Normalize the string to handle case differences
  String normalizedValue = value.replaceAll('UserType.', 'Usertype.');

  switch (normalizedValue) {
    case 'Usertype.teacher':
      return Usertype.teacher;
    case 'Usertype.student':
      return Usertype.student;
    case 'Usertype.parent':
      return Usertype.parent;
    case 'Usertype.admin':
      return Usertype.admin;
    case 'Usertype.languageLearner':
      return Usertype.languageLearner;
    case 'Usertype.none':
      return Usertype.none;
    default:
      throw Exception('Invalid Usertype string: $value');
  }
}
