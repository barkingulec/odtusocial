import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:social/services/auth/firestore_methods.dart';

import '../utils/colors.dart';
import '../utils/utils.dart';
import '../views/profile_view.dart';
import 'custom_image.dart';
import 'package:slide_popup_dialog_null_safety/slide_popup_dialog.dart' as slideDialog;

import 'enroll_button.dart';

class SinglePostComment extends StatefulWidget {
  final commentData;
  const SinglePostComment({super.key, this.commentData});

  @override
  State<SinglePostComment> createState() => _SinglePostCommentState();
}

class _SinglePostCommentState extends State<SinglePostComment> {
  bool isOwner = false;
  bool isLoading = false;
  var userData = {};
  String currentUserId = "";
    var enrolledComData = [];
  var pastComData = [];
    var datediff;
  var days;
  String dateStr = "";
  var hours;
  var minutes;
  var seconds;
  
  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    getData();
  }

getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      
      var userSnap = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(widget.commentData.data()['userId'])
          .get();

      userData = userSnap.data()!;
            enrolledComData = userData['enrolledComData'];
      pastComData = userData['pastComData'];

      datediff = DateTime.now().difference(widget.commentData.data()['date'].toDate());
      days = datediff.inDays;
      hours = datediff.inHours % 24;
      minutes = datediff.inMinutes % 60;
      if (days > 0 ) {
        dateStr = "$days days ago";
      }
      else if (hours > 0 ) {
        dateStr = "$hours hours ago";
      }
      else {
        dateStr = "$minutes min ago";
      }

      if (currentUserId == widget.commentData.data()['userId']) {
        setState(() {
          isOwner = true;
      });
      }

      setState(() {
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  deleteComment() async {
    var res = "Some error occurred.";
    try {
      res = await FireStoreMethods().deleteCommentFromPost(
                widget.commentData.data()['communityId'],
                widget.commentData.data()['postId'],
                widget.commentData.data()['commentId'],
                widget.commentData.data()['userId'],
                widget.commentData.data()['comment'],
              );
        setState(() {
          
        });
        Navigator.pop(context);
    } catch (e) {
      showSnackBar(context, res);
    }

  }

void _showDialog() {
    slideDialog.showSlideDialog(
      context: context,
      transitionDuration: const Duration(milliseconds: 360),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.59312,
        alignment: Alignment.topLeft,
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileView(
                          uid: widget.commentData['userId'],
                        ),
                      ),
                    ),
                      child: CustomImage(
                        userData['photoUrl'],
                        width: 100,
                        height: 100,
                        radius: 50,
                        ),
                    ),
                      Column(
                        children: [
                          EnrollButton(
                                    text: 'Follow (Soon)',
                                    backgroundColor: white,
                                    textColor: pink.withOpacity(.7),
                                    borderColor: pink.withOpacity(.7),
                                    function: () {},
                                    height: 30,
                                    width: 120,
                              ),
                          EnrollButton(
                                    text: 'Message (Soon)',
                                    backgroundColor: white,
                                    textColor: pink.withOpacity(.7),
                                    borderColor: pink.withOpacity(.7),
                                    function: () {},
                                    height: 30,
                                    width: 120,
                              ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileView(
                          uid: widget.commentData['userId'],
                        ),
                      ),
                    ),
                    child: Text(
                                    userData['username'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                  ),
                const SizedBox(height: 20),
                
                enrolledComData.isNotEmpty ? Text("Current Activities", style: const TextStyle(
                                          color: black,
                                          fontSize: 17,
                                          ),) : const SizedBox(),
                enrolledComData.isNotEmpty ? const SizedBox(height: 10) : const SizedBox(),
                for (var hs in enrolledComData) for (var field in hs.values) 
                  Text("${field['role'].toString()} in ${field['communityName']} since ${DateFormat('dd/MM/yyyy').format(field['joinDate'].toDate())}.", style: const TextStyle(
                                          color: darkGray,
                                          fontSize: 16,
                                          ),),
                const SizedBox(height: 10),
                pastComData.isNotEmpty ? Text("Past Activities", style: const TextStyle(
                                          color: black,
                                          fontSize: 17,
                                          ),) : const SizedBox(),
                pastComData.isNotEmpty ? SizedBox(height: 10) : const SizedBox(),
                for (var hs in pastComData) for (var field in hs.values) 
                  Text("${field['role'].toString()} in ${field['communityName']} between ${DateFormat('dd/MM/yyyy').format(field['joinDate'].toDate())} and ${DateFormat('dd/MM/yyyy').format(field['leftDate'].toDate())}.", style: const TextStyle(
                                          color: darkGray,
                                          fontSize: 16,
                                          ),),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileView(
                          uid: widget.commentData['userId'],
                        ),
                      ),
                    ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: pink.withOpacity(.35)),
                      borderRadius: BorderRadius.circular(25),
                      color: white,
                    ),
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      children: [
                        ListTile(
                          leading: SvgPicture.asset("assets/profile.svg", color: pink.withOpacity(.8), width: 25, height: 25,),
                          title: Text("View Profile"),
                          trailing: Icon(Icons.arrow_forward_ios, color: pink.withOpacity(.8)),
                          //iconColor: black,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierColor: gray.withOpacity(.4),
      pillColor: black,
      backgroundColor: whiteGray,
    );
  }

@override
  Widget build(BuildContext context) {  
    return isLoading ? const Center(child: CircularProgressIndicator()) : Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _showDialog, 
                    child: CustomImage(
                      userData['photoUrl'], 
                      radius: 25, 
                      width: 50, 
                      height: 50,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: GestureDetector(
                  onTap: _showDialog,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(userData['username'], style: TextStyle(color: black, fontSize: 17, fontWeight: FontWeight.bold),),
                          SizedBox(width: 2),
                          SvgPicture.asset("assets/dot.svg", color: black, width: 14, height: 14,),
                          SizedBox(width: 2),
                          Text(dateStr, style: TextStyle(color: black.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.w500),),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(widget.commentData.data()['comment'], style: TextStyle(color: black, fontSize: 16, fontWeight: FontWeight.w500),),
                  ],),
                ),
              ),
              isOwner ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text('Delete Comment'),
                                  content: Text("Are you sure you want to delete the comment?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: deleteComment,
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                          },
                    icon: SvgPicture.asset("assets/delete.svg", color: pink.withOpacity(.6), width: 24, height: 24,),
                    ),
                ],
              ) : SizedBox(),
            ],
          ),
        );
  }
}
