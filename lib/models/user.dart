import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final List comments;
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
  final String firstName;
  final String lastName;
  final bool isAdmin;
  final List enrolledComData;
  final List pastComData;
  final List admins;
  final List roles;
  final String type;
  final List participation;

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
      required this.notifications_new,
      required this.firstName,
      required this.lastName,
      required this.isAdmin,
      required this.comments,
      required this.enrolledComData,
      required this.pastComData,
      required this.admins,
      required this.roles,
      required this.type,
      required this.participation});

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
      firstName: snapshot["firstName"],
      lastName: snapshot["lastName"],
      isAdmin: snapshot['isAdmin'],
      comments: snapshot['comments'],
      enrolledComData: snapshot['enrolledComData'],
      pastComData: snapshot['pastComData'],
      admins: snapshot['admins'],
      roles: snapshot['roles'],
      type: snapshot['type'],
      participation: snapshot['participation'],
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
        "firstName": firstName,
        "lastName": lastName,
        "isAdmin": isAdmin,
        "comments": comments,
        "enrolledComData": enrolledComData,
        "pastComData": pastComData,
        "admins": admins,
        "roles": roles,
        "type": type,
        "participation": participation
      };
}