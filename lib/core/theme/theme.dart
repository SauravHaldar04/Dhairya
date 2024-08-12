import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final appTheme = ThemeData(
    scaffoldBackgroundColor: Pallete.backgroundColor,
    fontFamily: 'Poppins',
  );
  static final inputDecoration = InputDecoration(
    contentPadding: const EdgeInsets.all(15),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Pallete.primaryColor, width: 3),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Pallete.primaryColor, width: 3),
      borderRadius: BorderRadius.circular(10),
    ),
  );
}
