import 'package:flutter/material.dart';

class RoundedContainer extends StatelessWidget {
  final Widget child;
  final double paddingVertical;
  const RoundedContainer({
    Key? key,
    this.paddingVertical = 0,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: paddingVertical),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0x80E3F2FD)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: child,
    );
  }
}