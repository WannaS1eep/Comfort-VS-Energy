import 'package:flutter/material.dart';


class PMVButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color, textColor;
  final Color gradientColor1, gradientColor2;
  const PMVButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xff42a5f5),
    this.textColor = Colors.white,
    this.gradientColor1 = const Color(0xFFE3F2FD),
    this.gradientColor2 = const Color(0x80E3F2FD),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      // margin: const EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: newElevatedButton(),
      ),
    );
  }

  //Used:ElevatedButton as FlatButton is deprecated.
  //Here we have to apply customizations to Button by inheriting the styleFrom

  Widget newElevatedButton() {
    return ElevatedButton(
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          primary: color,
          // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          textStyle: TextStyle(
              color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }
}