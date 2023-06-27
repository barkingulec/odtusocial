import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../services/auth/firestore_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/enroll_button.dart';

class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? uid = "";
  String? displayName= "";
  String? email = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final User? curUser = auth.currentUser;
    uid = curUser!.uid;
    displayName = curUser.displayName;
    email = curUser.email;
  }

  void contact() async {
    try {
      String res = await FireStoreMethods().sendContact(
        message: messageController.text,
        email: email,
        userid: uid,
        username: displayName,
      );

      if (res != 'success') {
        showSnackBar(context, res);
      }
      else {
        showSnackBar(context, "You have successfully sent message.");
        Navigator.pop(context);
      }
      setState(() {
        messageController.text = "";
      });
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: black),
      leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: black.withOpacity(.7)),
            onPressed: () => Navigator.of(context).pop(),
          ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: whiteGray.withOpacity(0),
        title: const Text(
          "Contact Us",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              "This app is still under development which means you may encounter some errors. If you found one or have an idea to improve app, please let us know!",
              style: TextStyle(fontSize: 16),
              ),
          ),
        const Padding(
            padding: EdgeInsets.fromLTRB(40, 12, 32, 6),
            child: Text(
              "Message",
              style: TextStyle(color: Colors.grey),
            )),
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 4, 32, 32),
          child: TextFormField(
            maxLines: 8,
            controller: messageController,
            decoration: InputDecoration(
              hintText: "Enter your message",
              border: OutlineInputBorder(),
              // errorText: _nameValid ? null : "Username is too short",
            ),
          ),
        ),
        const SizedBox(height: 20),
                        // ElevatedButton(
                        //   onPressed: contact,
                        //   child: Text(
                        //     "Send",
                        //     style: TextStyle(
                        //       color: white,
                        //       fontSize: 18.0,
                        //     ),
                        //   ),
                        //   style: ButtonStyle(
                        //     backgroundColor: MaterialStateProperty.all(pink),
                        //   ),
                        // ),
                      EnrollButton(
                          text: 'Send',
                          backgroundColor: Colors.white,
                          textColor: pink,
                          borderColor: pink,
                          function: contact,
                          height: 30,
                          width: 120,
                    ),
        ],
        ),
      )
      );
  }
}