import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../services/auth/firestore_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../views/profile_view.dart';
import 'custom_image.dart';
import 'enroll_button.dart';
import 'package:slide_popup_dialog_null_safety/slide_popup_dialog.dart' as slideDialog;

class SingleChatGroupMember extends StatefulWidget {
  final String uid;
  final String communityId;
  final String communityGroupId;
  const SingleChatGroupMember({Key? key, required this.uid, required this.communityId, required this.communityGroupId}) : super(key: key);

  @override
  State<SingleChatGroupMember> createState() => _SingleChatGroupMemberState();
}

class _SingleChatGroupMemberState extends State<SingleChatGroupMember> {
  var userData = {};
  var enrolledComData = [];
  var pastComData = [];
  var communityGroupData = {};
  bool isLoading = false;
  bool isDeleted = false;
  bool isAdmin = false;
  bool isDefault = false;
  bool isCurUserAdmin = false;
  String? curUserId;

  @override
  void initState() {
    super.initState();
    curUserId = FirebaseAuth.instance.currentUser!.uid;
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
      enrolledComData = userData['enrolledComData'];
      pastComData = userData['pastComData'];

      var communitySnap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('messagesGroups')
          .doc(widget.communityGroupId)
          .get();

      communityGroupData = communitySnap.data()!;

      isCurUserAdmin = communityGroupData['admins'].contains(curUserId);
      isAdmin = communityGroupData['admins'].contains(widget.uid);
      isDefault = communityGroupData['isDefault'];

      setState(() {

      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
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
                          uid: userData['uid'],
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
                          uid: userData['uid'],
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
                          uid: userData['uid'],
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
      barrierColor: gray.withOpacity(.35),
      pillColor: black,
      backgroundColor: whiteGray,
    );
  }

  addAdmin(String userId, String username) async {
    var res = await FireStoreMethods().addGroupAdmin(userId, widget.communityId, widget.communityGroupId, username);
    showSnackBar(context, res);
    Navigator.of(context).pop();
    setState(() {
      isAdmin = true;
    });
  }

  removeAdmin(String userId, String username) async {
    var res = await FireStoreMethods().deleteGroupAdmin(userId, widget.communityId, widget.communityGroupId, username);
    showSnackBar(context, res);
    Navigator.of(context).pop();
    setState(() {
      isAdmin = false;
    });
  }

  kickMember(String userId, String username) async {
    var res = await FireStoreMethods().kickGroupMember(userId, widget.communityId, widget.communityGroupId, username);
    showSnackBar(context, res);
    Navigator.of(context).pop();
    setState(() {
      isDeleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center( child: CircularProgressIndicator() )
      : isDeleted ? const SizedBox(width: 0) : ListTile(
                            title: GestureDetector(
                              onTap: _showDialog,
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
                            subtitle: GestureDetector(
                              onTap: _showDialog,
                              child: Text(
                                isAdmin ? "Group Admin" : "Member",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: isAdmin ? pink : gray,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            leading: GestureDetector(
                              onTap: _showDialog,
                              child: CustomImage(
                                  userData['photoUrl'],
                                  width: 50,
                                  height: 50,
                                  radius: 25,
                                  ),
                            ),
                            trailing: curUserId == widget.uid ? const SizedBox() : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                isCurUserAdmin && !isAdmin ? IconButton(
                                  onPressed: () {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text('Make ${userData['username']} admin.'),
                                  content: Text("Are you sure you want to make ${userData['username']} admin?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        addAdmin(userData['uid'], userData['username']);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                          }, 
                                  icon: const Icon(Icons.add, color: pink)
                                  ) : SizedBox(),
                                isCurUserAdmin && isAdmin ? IconButton(
                                  onPressed: () {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text('Demote ${userData['username']}'),
                                  content: Text(
                                    "Are you sure to demote the user to member?"
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        removeAdmin(userData['uid'], userData['username']);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                          }, 
                                  icon: const Icon(Icons.remove, color: pink)
                                  ) : SizedBox(),

                              isCurUserAdmin && !isDefault ? IconButton(
                                  onPressed: () {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text('Kick ${userData['username']}'),
                                  content: Text(
                                    "Are you sure you want to kick the member from group chat?"
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        kickMember(userData['uid'], userData['username']);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                          }, 
                                  icon: const Icon(Icons.delete, color: pink)
                                  ) : SizedBox(),

                              ],
                            ),
                          );
  }
}