enum Usertype { teacher, student, parent, admin, languageLearner, none }

extension UsertypeExtension on Usertype {
  String toStringValue() {
    switch (this) {
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
}

Usertype getEnumFromString(String value) {
  switch (value) {
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
