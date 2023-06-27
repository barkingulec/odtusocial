import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:social/utils/utils.dart';
import 'package:social/views/home_view.dart';

import '../utils/colors.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  bool isEmailVerified = false;
  bool canResendEmail= false;
  Timer? timer;
  String? email;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    email = FirebaseAuth.instance.currentUser!.email;
    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) { timer?.cancel(); }
  }

  Future sendVerificationEmail() async{
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      
      setState(() {
        canResendEmail = false;
      });
      await Future.delayed(const Duration(seconds: 5));
      setState(() {
        canResendEmail = true;
      });

    } catch(e) {
      showSnackBar(context, e.toString());
    }

  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified ? const HomeView() : 
      Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: black),
      leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: black.withOpacity(.7)),
            onPressed: () => Navigator.of(context).pop(),
          ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: whiteGray.withOpacity(0),
          title: const Text('Verify Email')
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'A verification email is sent to ${email}.',
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                    onPressed: canResendEmail ? sendVerificationEmail : null, 
                    icon: const Icon(Icons.email, size: 32), 
                    label: const Text(
                      'Resent Email',
                      style: TextStyle(fontSize: 24),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                  ),),
                  const SizedBox(height: 8,),
                  TextButton(
                    onPressed: () => FirebaseAuth.instance.signOut(), 
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text(
                      'Return to Register Page',
                      style: TextStyle(fontSize: 24),
                    ),)
            ],
          )
        )
      );
  }
}