import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String? email;
  final String uid;
  final String? username;
  final String message;
  final String? userid;
  final DateTime date;

  const Contact(
      {required this.username,
      required this.uid,
      required this.email,
      required this.message,
      required this.userid,
      required this.date,});

  static Contact fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Contact(
      username: snapshot["username"],
      uid: snapshot["uid"],
      email: snapshot["email"],
      message: snapshot["message"],
      userid: snapshot["userid"],
      date: snapshot["date"],
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "message": message,
        "userid": userid,
        "date": date,
      };
}