import 'package:intl/intl.dart';

String formatDateMMYYYY(DateTime date) {
  return DateFormat('d MMMM, yyyy').format(date);
}
