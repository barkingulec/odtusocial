import 'package:flutter/material.dart';

import '../utils/colors.dart';

class EnrollButton extends StatelessWidget {
  final Function()? function;
  final Color backgroundColor;
  final Color borderColor;
  final String text;
  final Color textColor;
  final double width;
  final double height;
  final double radius;
  final double fontSize;
  const EnrollButton({
    Key? key,
    required this.backgroundColor,
    required this.borderColor,
    required this.text,
    required this.textColor,
    this.function,
    this.width = 250,
    this.height = 27,
    this.radius = 20,
    this.fontSize = 14,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 2),
      child: TextButton(
        onPressed: function,
        child: Container(
          // decoration: BoxDecoration(
          //    boxShadow: [
          //       BoxShadow(
          //         color: pink.withOpacity(0.1),
          //         spreadRadius: 2,
          //         blurRadius: 2,
          //         offset: Offset(3, 3), // changes position of shadow
          //       ),
          //     ],
          //   color: backgroundColor,
          //   border: Border.all(
          //     color: borderColor,
          //   ),
          //   borderRadius: BorderRadius.circular(5),
          // ),
          decoration: BoxDecoration(
                        color: backgroundColor,
            border: Border.all(
              color: borderColor.withOpacity(.8),
            ),
            borderRadius: BorderRadius.circular(radius),
                                boxShadow: [
                                  BoxShadow(
                                    color: pink.withOpacity(.1),
                                    spreadRadius: 1,
                                    blurRadius: 15,
                                    offset: const Offset(5, 5),
                                  ),
                                  // const BoxShadow(
                                  //   color: Colors.white,
                                  //   offset: Offset(-5,-5),
                                  //   blurRadius: 15,
                                  //   spreadRadius: 1
                                  // ) ,
                                ],
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    pink.withOpacity(.01),
                                    pink.withOpacity(.02),
                                    pink.withOpacity(.04),
                                    pink.withOpacity(.07),
                                    pink.withOpacity(.12),
                                    pink.withOpacity(.16),
                                  ],
                                ),
                              ),
          alignment: Alignment.center,
          width: width,
          height: height,
          child: Text(
            text,
            style: TextStyle(
              color: textColor.withOpacity(1),
              //fontWeight: FontWeight.w500,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}