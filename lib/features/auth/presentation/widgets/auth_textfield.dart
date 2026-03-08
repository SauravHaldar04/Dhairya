import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// A theme-aware text field for auth forms.
///
/// Automatically picks up [InputDecorationTheme] from the current [ThemeData]
/// so it works in both light and dark modes.
class AuthTextfield extends StatefulWidget {
  final String text;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final IconData? prefixIcon;

  const AuthTextfield({
    super.key,
    required this.text,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    required this.controller,
    this.prefixIcon,
  });

  @override
  State<AuthTextfield> createState() => _AuthTextfieldState();
}

class _AuthTextfieldState extends State<AuthTextfield> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword ? _obscure : false,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
      decoration: InputDecoration(
        hintText: widget.text,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: 20)
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? PhosphorIconsRegular.eye
                      : PhosphorIconsRegular.eyeSlash,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            : null,
      ),
    );
  }
}
