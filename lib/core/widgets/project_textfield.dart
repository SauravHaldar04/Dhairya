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
  const ProjectTextfield(
      {super.key,
      required this.text,
      this.borderColor,
      this.readOnly = false,
      this.enabled = true,
      this.isPassword = false,
      this.keyboardType = TextInputType.text,
      required this.controller});

  @override
  State<ProjectTextfield> createState() => _ProjectTextfieldState();
}

class _ProjectTextfieldState extends State<ProjectTextfield> {
  bool isObscure = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(

      style: const TextStyle(
        color: Colors.black,
      ),
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword ? isObscure : false,
      decoration: AppTheme.inputDecoration.copyWith(
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
    );
  }
}
