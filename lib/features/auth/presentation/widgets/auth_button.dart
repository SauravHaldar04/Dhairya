import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isInverted;
  const AuthButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.isLoading = false,
      this.isInverted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
          color: isInverted ? Pallete.whiteColor : Pallete.primaryColor,
          border: Border.all(color: Pallete.primaryColor, width: 3),
          borderRadius: BorderRadius.circular(10)),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor:
                isInverted ? Pallete.whiteColor : Pallete.primaryColor,
            foregroundColor:
                isInverted ? Pallete.primaryColor : Pallete.whiteColor,
            minimumSize: Size(200, 38),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
          )),
    );
  }
}
