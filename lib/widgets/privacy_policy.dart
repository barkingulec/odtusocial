import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../utils/colors.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      iconTheme: const IconThemeData(color: black),
      backgroundColor: whiteGray,
      title: const Text(
        "Terms & Conditions",
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    ),
      body: Container(
        
      )
    );
  }
}