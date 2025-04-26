import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class ProjectButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isInverted;
  final Color? buttonColor;
  final Color? textColor;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  
  const ProjectButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isInverted = false,
    this.buttonColor,
    this.textColor,
    this.fontSize,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveButtonColor = buttonColor ?? 
        (isInverted ? Pallete.whiteColor : Pallete.primaryColor);
    
    final Color effectiveTextColor = textColor ??
        (isInverted ? Pallete.primaryColor : Pallete.whiteColor);
    
    final double effectiveBorderRadius = borderRadius ?? 10;
    final double effectiveFontSize = fontSize ?? 20;
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.all(0);

    return Container(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
          color: effectiveButtonColor,
          border: Border.all(color: Pallete.primaryColor, width: 3),
          borderRadius: BorderRadius.circular(effectiveBorderRadius)),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: effectiveButtonColor,
            foregroundColor: effectiveTextColor,
            minimumSize: const Size(200, 38),
            padding: effectivePadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              fontSize: effectiveFontSize, 
              fontWeight: FontWeight.normal,
              color: effectiveTextColor,
            ),
          )),
    );
  }
}
