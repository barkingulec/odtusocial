import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:social/widgets/enroll_button.dart';

import '../services/auth/firestore_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/custom_image.dart';

class AddGroupChat extends StatefulWidget {
  final communityId;
  const AddGroupChat({super.key, this.communityId});

  @override
  State<AddGroupChat> createState() => _AddGroupChatState();
}

class _AddGroupChatState extends State<AddGroupChat> {
  var communityData = {};
  var dataArr = [];
  bool isLoading = false;
  var communityRef;
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;
  String name = "";
  final TextEditingController _groupNameController = TextEditingController();
  List groupMembers = [];
  String currentUserId = "";

@override
  void initState() {
    super.initState();
    getData();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    currentUserId = user!.uid;
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {

      var communitySnap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .get();

      communityData = communitySnap.data()!;

      communityRef = FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId);

      // first add admins DATA then add members DATA
      for (var uid in communityData['enrolledUsers']) {
        var admins = (communityData['admins'] as List).map((item) => item as String).toList();
        if (admins.contains(uid)) {
            var userSnap = await FirebaseFirestore.instance
              .collection('profiles')
              .doc(uid)
              .get();

          var data = userSnap.data()!;
          dataArr.add(data); 
        }
      }

      for (var uid in communityData['enrolledUsers']) {
        var admins = (communityData['admins'] as List).map((item) => item as String).toList();
        if (!admins.contains(uid)) {
            var userSnap = await FirebaseFirestore.instance
              .collection('profiles')
              .doc(uid)
              .get();

          var data = userSnap.data()!;
          dataArr.add(data); 
        }
      }

      groupMembers.add(currentUserId);
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
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: black),
      leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: black.withOpacity(.7)),
            onPressed: () => Navigator.of(context).pop(),
          ),
      actions: <Widget>[
      IconButton(
        icon: Icon(
          Icons.arrow_forward_ios_outlined,
          color: black.withOpacity(.7),
          ),
          onPressed: () {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text('Enter Group Name'),
                                  content: TextField(
                                    controller: _groupNameController,
                                    decoration: InputDecoration(
                                      hintText: "Group Name",
                                      //errorText: _roleValid ? null : "Password is not valid.",
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        String res = await FireStoreMethods().addGroupChat(widget.communityId, groupMembers, _groupNameController.text, currentUserId);
                                        Navigator.pop(context, "OK");
                                        showSnackBar(context, res);
                                        Navigator.pop(context, "OK");
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                          },
        )
      ],
      //centerTitle: true,
      elevation: 0,
      backgroundColor: whiteGray.withOpacity(0),
            title: Card(
              color: white,
          child: TextField(
            decoration: InputDecoration(
                filled: true,
                fillColor: whiteGray,
                prefixIcon: Icon(Icons.search), 
                hintText: 'Search from members...',
                border: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
            onChanged: (val) {
              setState(() {
                name = val;
              });
            },
          ),
        )),
        body: ListView.builder(
                itemCount: dataArr.length,
                itemBuilder: (context, index) {
                  var data = dataArr[index];

                  if (name.isEmpty) {
                        return GestureDetector(
                          onTap: () {
                            
                          },
                          child: ListTile(
                            title: Text(
                              data['username'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              data['email'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: gray,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            leading: CustomImage(
                              data['photoUrl'],
                              width: 50,
                              height: 50,
                              radius: 25,
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                if (groupMembers.contains(data['uid'])) {
                                  groupMembers.remove(data['uid']);
                                } else {
                                  groupMembers.add(data['uid']);
                                }
                                setState(() {
                                  
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  groupMembers.contains(data['uid']) ? Icon(Icons.remove, color: pink) : Icon(Icons.add, color: pink),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      if (data['username']
                          .toString()
                          .toLowerCase()
                          .contains(name.toLowerCase())) {
                        return GestureDetector(
                          child: ListTile(
                            title: Text(
                              data['username'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              data['email'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: gray,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            leading: CustomImage(
                                data['photoUrl'],
                                width: 50,
                                height: 50,
                                radius: 25,
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                if (groupMembers.contains(data['uid'])) {
                                  groupMembers.remove(data['uid']);
                                } else {
                                  groupMembers.add(data['uid']);
                                }
                                setState(() {
                                  
                                });
                              },
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    groupMembers.contains(data['uid']) ? Icon(Icons.remove, color: pink) : Icon(Icons.add, color: pink),
                                  ],
                                ),
                            ),
                          ),
                        );
                      }
                  return Container();
                }));
  }
}