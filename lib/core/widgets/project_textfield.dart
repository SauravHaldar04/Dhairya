import 'package:aparna_education/core/theme/theme.dart';
import 'package:flutter/material.dart';

class ProjectTextfield extends StatefulWidget {
  final String text;
  final bool isPassword;
  final bool enabled;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final bool readOnly;
  final Color? borderColor;
  final ValueChanged? onSubmitted;
  final FormFieldValidator<String>? validator;
  final TextStyle? textStyle;
  final InputDecoration? decoration;
  
  const ProjectTextfield({
    super.key,
    required this.text,
    this.onSubmitted,
    this.borderColor,
    this.readOnly = false,
    this.enabled = true,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    required this.controller,
    this.validator,
    this.textStyle,
    this.decoration,
  });

  @override
  State<ProjectTextfield> createState() => _ProjectTextfieldState();
}

class _ProjectTextfieldState extends State<ProjectTextfield> {
  bool isObscure = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: widget.textStyle ?? const TextStyle(
        color: Colors.black,
      ),
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword ? isObscure : false,
      decoration: (widget.decoration ?? AppTheme.inputDecoration).copyWith(
        disabledBorder: widget.borderColor != null
            ? OutlineInputBorder(
                borderSide: BorderSide(color: widget.borderColor!, width: 2),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        hintText: widget.text,
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isObscure = !isObscure;
                  });
                },
                icon: Icon(
                  isObscure ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
              )
            : null,
      ),
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
    );
  }
}
