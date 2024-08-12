import 'package:aparna_education/core/theme/theme.dart';
import 'package:flutter/material.dart';

class AuthTextfield extends StatefulWidget {
  final String text;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController controller;
  const AuthTextfield(
      {super.key,
      required this.text,
      this.isPassword = false,
      this.keyboardType = TextInputType.text, required this.controller});

  @override
  State<AuthTextfield> createState() => _AuthTextfieldState();
}

class _AuthTextfieldState extends State<AuthTextfield> {
  bool isObscure = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword ? isObscure : false,
      decoration: AppTheme.inputDecoration.copyWith(
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
