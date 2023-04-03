import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../services/auth/firestore_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/single_notification.dart';

class NotificationView extends StatefulWidget {
  final int newLength;
  const NotificationView({super.key, required this.newLength});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String? userUid;
  var userData = {};
  var notifications = [];
  var notificationsNew = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final User? curUser = auth.currentUser;
    userUid = curUser!.uid;
    getNotifications();
  }
  
  getNotifications() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(userUid)
          .get();
      userData = userSnap.data()!;
      notifications = userData['notifications'];

    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center( child: CircularProgressIndicator() )
      : SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: whiteGray,
            iconTheme: const IconThemeData(color: black),
            title: const Text(
              "Notifications",
              style: TextStyle(color: black),),
            ),
          body: Container(
            child: notifications.isNotEmpty ? ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return SingleNotification(eventId: notifications[index]['eventId'], communityId: notifications[index]['communityId'], isNew: widget.newLength - index > 0 ? true : false);
              },
            )
            : const Center(child: Text("There is no notification.")),
            ),
          ),
      );
  }
}