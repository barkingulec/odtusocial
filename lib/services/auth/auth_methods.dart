import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social/models/user.dart' as model;
import 'package:social/services/auth/storage_methods.dart';

import '../../utils/colors.dart';

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  // Signing Up User

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty) {
        // registering user in auth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        cred.user?.updateDisplayName(username);

        // String photoUrl =
        //     await StorageMethods().uploadImageToStorage('profilePics', file, false);

        String firstName = "";
        String lastName = "";
        var name = email.split('@');

        if (name[0].contains(".")){
          var fl = name[0].split('.');
          firstName = fl[0];
          lastName = fl[1];
        }

        model.User _user = model.User(
          comments: [],
          username: username,
          uid: cred.user!.uid,
          photoUrl: logo,
          email: email,
          bio: "",
          department: "",
          enrolledCom : [],
          bookmarkedCom: [],
          notifications: [],
          notifications_new: [],
          firstName: firstName,
          lastName: lastName,
          isAdmin: false,
          enrolledComData: [],
          pastComData: [],
          admins: [],
          roles: [],
          type: "User",
          participation: [],
        );
        
        await _firestore
            .collection("profiles")
            .doc(cred.user!.uid)
            .set(_user.toJson());

        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}