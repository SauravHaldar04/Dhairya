import 'package:intl/intl.dart';

String formatDatedMMYYYY(DateTime date) {
  return DateFormat('d MM, yyyy').format(date);
}
