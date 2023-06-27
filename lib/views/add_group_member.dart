import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../services/auth/firestore_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/custom_image.dart';

class AddGroupMember extends StatefulWidget {
  final communityId;
  final communityGroupId;
  final curUserId;
  const AddGroupMember({super.key, this.communityId, this.communityGroupId, this.curUserId});

  @override
  State<AddGroupMember> createState() => _AddGroupMemberState();
}

class _AddGroupMemberState extends State<AddGroupMember> {
  var communityData = {};
  var communityGroupData = {};
  var dataArr = [];
  bool isLoading = false;
  var communityRef;
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;
  String name = "";

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

      var communitySnap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .get();

      communityData = communitySnap.data()!;

      var communityGroupSnap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('messagesGroups')
          .doc(widget.communityGroupId)
          .get();

      communityGroupData = communityGroupSnap.data()!;

      communityRef = FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId);

      for (var uid in communityData['enrolledUsers']) {
        var groupMembers = (communityGroupData['members'] as List).map((item) => item as String).toList();
        if (!groupMembers.contains(uid)) {
            var userSnap = await FirebaseFirestore.instance
              .collection('profiles')
              .doc(uid)
              .get();

          var data = userSnap.data()!;
          dataArr.add(data); 
        }
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

  addAdmin() async {
    
  }

   @override
  void dispose() {
    super.dispose();
    searchController.dispose();
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
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text('Add ${data['username']} to group'),
                                  content: Text("Do you want to add ${data['username']} to group?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        String res = await FireStoreMethods().addGroupMember(data['uid'], widget.communityId, widget.communityGroupId, data['username']);
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const <Widget>[
                                Icon(Icons.add, color: pink),
                              ],
                            ),
                          ),
                        );
                      }
                      if (data['username']
                          .toString()
                          .toLowerCase()
                          .contains(name.toLowerCase())) {
                        return GestureDetector(
                          onTap: () {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text('Add ${data['username']} to group'),
                                  content: Text("Do you want to add ${data['username']} to group?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        String res = await FireStoreMethods().addGroupMember(data['uid'], widget.communityId, widget.communityGroupId, data['username']);
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const <Widget>[
                                Icon(Icons.add, color: pink),
                              ],
                            ),
                          ),
                        );
                      }
                  return Container();
                }));
  }
}