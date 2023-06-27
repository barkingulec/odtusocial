import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../utils/colors.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      iconTheme: const IconThemeData(color: black),
      backgroundColor: whiteGray,
      title: const Text(
        "Privacy Policy",
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            ""
          ),
        ),
      )
    );
  }
}