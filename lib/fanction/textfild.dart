import 'package:flutter/material.dart';

class castumtextfil extends StatelessWidget {
  final TextEditingController mytextcontroller;

  final String hint;
  final dynamic suffixIcon;
  final dynamic prefixIcon;
  final bool Bool;
  final String? Function(String?)? validator;
  const castumtextfil({
    super.key,
    required this.hint,
    required this.mytextcontroller,
    this.validator,
    required this.Bool,
    required this.prefixIcon,
    this.suffixIcon,
    required bool obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: Bool,
      validator: validator,
      controller: mytextcontroller,
      decoration: InputDecoration(
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          hintText: hint,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black, width: 1))),
    );
  }
}
