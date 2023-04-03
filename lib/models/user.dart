import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String bio;
  final String department;
  final List enrolledCom;
  final List bookmarkedCom;
  final List notifications;
  final List notifications_new;

  const User(
      {required this.username,
      required this.uid,
      required this.photoUrl,
      required this.email,
      required this.bio,
      required this.department,
      required this.enrolledCom, 
      required this.bookmarkedCom,
      required this.notifications,
      required this.notifications_new,});

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot["username"],
      uid: snapshot["uid"],
      email: snapshot["email"],
      photoUrl: snapshot["photoUrl"],
      bio: snapshot["bio"],
      department: snapshot["department"],
      enrolledCom: snapshot["enrolledCom"],
      bookmarkedCom: snapshot["bookmarkedCom"],
      notifications: snapshot["notifications"],
      notifications_new: snapshot["notifications_new"],
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "bio": bio,
        "department": department,
        "enrolledCom": enrolledCom,
        "bookmarkedCom": bookmarkedCom,
        "notifications": notifications,
        "notifications_new": notifications_new,
      };
}