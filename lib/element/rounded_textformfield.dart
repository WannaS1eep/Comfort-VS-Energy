import 'package:flutter/material.dart';
import './rounded_container.dart';




class RoundedInputFormField extends StatelessWidget {
  final InputDecoration decoration;
  final String? Function(String?)? validator;
  final bool obscureText;
  const RoundedInputFormField({
    Key? key,
    required this.decoration,
    required this.validator,
    this.obscureText = false,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return RoundedContainer(
      child: TextFormField(
        decoration: decoration,

        cursorColor: Colors.blue,
        validator: validator,
      ),
    );
  }
}