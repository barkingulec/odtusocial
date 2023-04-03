import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/custom_image.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var profileData = {};
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  bool _nameValid = true;
  bool _bioValid = true;
  String? uid = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  var profileRef;

  @override
  void initState() {
    super.initState();
    final User? curUser = auth.currentUser;
    uid = curUser!.uid;
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {

      var profileSnap = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(uid)
          .get();

      profileData = profileSnap.data()!;

      profileRef = FirebaseFirestore.instance
          .collection('profiles')
          .doc(uid);

      setState(() {
        nameController = TextEditingController(text: profileData['username']);
        bioController = TextEditingController(text: profileData['bio']);
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

    Column buildEventNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Username",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: "Update Username",
            errorText: _nameValid ? null : "Username is too short",
          ),
        )
      ],
    );
  }

  Column buildDescField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Biography",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Update Biography",
            errorText: _bioValid ? null : "Biography is too long",
          ),
        )
      ],
    );
  }

  updateProfile() {
    setState(() {
      nameController.text.trim().length < 3 ||
              nameController.text.isEmpty
          ? _nameValid = false
          : _nameValid = true;
      bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_nameValid && _bioValid) {
      profileRef.update({
        "name": nameController.text,
        "bio": bioController.text,
      });
      showSnackBar(context, "Profile updated!");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: black),
        backgroundColor: whiteGray,
        title: Text(
          "Update Profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: 
          isLoading ? const Center(child: CircularProgressIndicator()) : 
          ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          top: 20.0,
                          bottom: 10.0,
                        ),
                        child: CustomImage(
                            profileData['photoUrl'],
                            radius: 20,
                            width: 100,
                            height: 100,
                          ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            buildEventNameField(),
                            buildDescField(),
                          ],
                        ),
                      ),
                 const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: updateProfile,
                        child: Text(
                          "Update Profile",
                          style: TextStyle(
                            color: white,
                            fontSize: 18.0,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(pink),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}