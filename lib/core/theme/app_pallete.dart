import 'package:flutter/material.dart';
import 'package:aparna_education/core/theme/app_colors.dart';

@Deprecated('Use AppColors + Theme.of(context).colorScheme instead.')
class Pallete {
  // static const cardColor = Color.fromRGBO(30, 30, 30, 1);
  // static const greenColor = Colors.green;
  // static const subtitleText = Color(0xffa7a7a7);
  // static const inactiveBottomBarItemColor = Color(0xffababab);

  // Brand
  static const Color primaryColor = AppColors.primary;
  static const Color secondaryColor = AppColors.secondary;

  // Surfaces
  static const Color backgroundColor = AppColors.lightBackground;
  static const Color darkBackgroundColor = AppColors.darkBackground;
  static const Color surfaceColor = AppColors.lightSurface;
  static const Color darkSurfaceColor = AppColors.darkSurface;
  // static const Color gradient1 = Color.fromRGBO(187, 63, 221, 1);
  // static const Color gradient2 = Color.fromRGBO(251, 109, 169, 1);
  // static const Color gradient3 = Color.fromRGBO(255, 159, 124, 1);
  // static const Color borderColor = Color.fromRGBO(52, 51, 67, 1);
  static const Color inactiveColor = Color.fromRGBO(217, 216, 216, 1);
  static const Color whiteColor = Colors.white;
  static const Color greyColor = Colors.grey;
  static const Color errorColor = AppColors.error;
  static const Color transparentColor = Colors.transparent;

  static const Color inactiveSeekColor = Colors.white38;
}
