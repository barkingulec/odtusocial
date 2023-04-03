import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../services/auth/firestore_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import 'enroll_button.dart';

class SingleRequest extends StatefulWidget {
  final String uid;
  final String communityId;
  const SingleRequest({Key? key, required this.uid, required this.communityId}) : super(key: key);

  @override
  State<SingleRequest> createState() => _SingleRequestState();
}

class _SingleRequestState extends State<SingleRequest> {
  var userData = {};
  bool isLoading = false;
  bool notClicked = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {

      var userSnap = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(widget.uid)
          .get();

      userData = userSnap.data()!;
      setState(() {
        
      });
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
      : notClicked ? Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1.0, color: gray),
            )
          ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(userData['username'], style: TextStyle(fontSize: 18)),
            const SizedBox(width: 120),
            acceptButton(),
            declineButton(),
          ],
        ),
      ) : const SizedBox(width: 0);
  }

  Widget acceptButton() {
    return EnrollButton(
                      text: 'Accept',
                      backgroundColor: pink,
                      textColor: Colors.white,
                      borderColor: pink,
                      function: () async {
                        await FireStoreMethods()
                            .acceptRequest(
                              widget.uid,
                              widget.communityId,
                        );
                        setState(() {
                          notClicked = false;
                        });
                      },
                      width: 80,
                      height: 25,
                    );
  }


  Widget declineButton() {
    return EnrollButton(
                      text: 'Decline',
                      backgroundColor: Colors.white,
                      textColor: pink,
                      borderColor: pink,
                      function: () async {
                        await FireStoreMethods()
                            .declineRequest(
                              widget.uid,
                              widget.communityId,
                        );
                        setState(() {
                          notClicked = false;
                        });
                      },
                      width: 80,
                      height: 25,
                    );
  }
}