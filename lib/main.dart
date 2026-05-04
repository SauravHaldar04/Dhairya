// main.dart

import 'package:aparna_education/app.dart';
import 'package:aparna_education/app_providers.dart';

/// The main entry point of the Aparna Education application.
void main() async {
  await AppProviders.run(const MyApp());
}
