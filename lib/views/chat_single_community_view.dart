
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social/utils/utils.dart';

import '../services/auth/firestore_methods.dart';
import '../utils/colors.dart';
import '../widgets/chat_community_new_message.dart';
import '../widgets/chat_messages.dart';
import '../widgets/chat_messages_community.dart';
import '../widgets/chat_new_message.dart';
import 'chat_group_members.dart';
import 'chat_profile_header.dart';

class SingleCommunityGroupChatPage extends StatefulWidget {
  final group;
  final groupFromCommunity;

  const SingleCommunityGroupChatPage({
    @required this.group,
    Key? key, this.groupFromCommunity,
  }) : super(key: key);

  @override
  _SingleCommunityGroupChatPageState createState() => _SingleCommunityGroupChatPageState();
}

class _SingleCommunityGroupChatPageState extends State<SingleCommunityGroupChatPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userUid = ""; 
  TextEditingController _groupNameController = TextEditingController();
  String groupName = "";

  @override
  void initState() {
    super.initState();
    final User? curUser = auth.currentUser;
    userUid = curUser!.uid;
    _groupNameController = TextEditingController(text: widget.groupFromCommunity['username']);
    groupName = widget.group['username'];
  }

      removeGroupChat() async {
                        var res = await FireStoreMethods()
                            .deleteGroupChat(
                                widget.group['communityId'],
                                widget.group['communityGroupId'],
                          );
                        showSnackBar(context, res);
                        Navigator.popUntil(context, (route) => route.isFirst);
    }

    leaveGroupChat() async {
                        var res = await FireStoreMethods()
                            .leaveGroupChat(
                                userUid,
                                widget.group['communityId'],
                                widget.group['communityGroupId'],
                          );
                          showSnackBar(context, res);
                        Navigator.popUntil(context, (route) => route.isFirst);
    }

    changeGroupChatName() async {
                        var res = await FireStoreMethods()
                            .changeGroupChatName(
                                widget.group['communityId'],
                                widget.group['communityGroupId'],
                                _groupNameController.text,
                          );
                          setState(() {
                            groupName = _groupNameController.text;
                          });
                          showSnackBar(context, res);
                        Navigator.of(context).pop();
    }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            iconTheme: const IconThemeData(color: white),
          leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: white),
                onPressed: () => Navigator.of(context).pop(),
              ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: pink2,
          title: Text(
              groupName,
              style: TextStyle(
                color: white,
              ),
          ),
          actions: 
          //widget.groupFromCommunity['isDefault'] ? [] : 
          [ PopupMenuButton(
                   // add icon, by default "3 dot" icon
                   icon: SvgPicture.asset("assets/details.svg", color: white, width: 25, height: 25,),
                   itemBuilder: (context){
                     return widget.groupFromCommunity['isDefault'] ? [
                        const PopupMenuItem<int>(
                                value: 0,
                                child: Text("Members"),
                            ),
                     ] : 
                            widget.groupFromCommunity['admins'].contains(userUid) ? 
                            const [
                            PopupMenuItem<int>(
                                value: 0,
                                child: Text("Members"),
                            ),
                            PopupMenuItem<int>(
                                value: 1,
                                child: Text("Change Name"),
                            ),
                            PopupMenuItem<int>(
                                value: 2,
                                child: Text("Delete Group"),
                            ),
                            PopupMenuItem<int>(
                                value: 3,
                                child: Text("Leave Group"),
                            ),
                        ] : [
                            const PopupMenuItem<int>(
                                value: 0,
                                child: Text("Members"),
                            ),
                            PopupMenuItem<int>(
                                value: 3,
                                child: Text("Leave Group"),
                            ),
                        ];
                   },
                   onSelected:(value){
                      if(value == 0){
                            Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatGroupMembers(
                                communityId: widget.group['communityId'].toString(),
                                communityGroupId: widget.group['communityGroupId'].toString(),
                              ),
                            ),
                          ).then((_) => setState(() {}));
                      }else if(value == 1){
                                            showDialog<String>(
                                                context: context,
                                                builder: (BuildContext context) => AlertDialog(
                                                  title: Text('Change the group name'),
                                                  content: TextField(
                                                    controller: _groupNameController,
                                                    decoration: InputDecoration(
                                                      hintText: "Please enter your new group name.",
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: changeGroupChatName,
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              );
                      }
                      else if(value == 2){
                        showDialog(
                              useRootNavigator: false,
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: ListView(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shrinkWrap: true,
                                      children: [
                                        'Confirm Delete',
                                      ]
                                          .map(
                                            (e) => InkWell(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                          horizontal: 16),
                                                  child: Text(e),
                                                ),
                                                onTap: () {
                                            showDialog<String>(
                                                context: context,
                                                builder: (BuildContext context) => AlertDialog(
                                                  title: Text('Delete the group?'),
                                                  content: Text("Are you sure you really want to delete the group chat? All the messages and data will be lost and can not be returned."),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: removeGroupChat,
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                          },),
                                          )
                                          .toList()),
                                );
                              },
                            );
                      }
                      else if(value == 3){
                        showDialog(
                              useRootNavigator: false,
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: ListView(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shrinkWrap: true,
                                      children: [
                                        'Confirm Leave',
                                      ]
                                          .map(
                                            (e) => InkWell(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                          horizontal: 16),
                                                  child: Text(e),
                                                ),
                                                onTap: () {
                                            showDialog<String>(
                                                context: context,
                                                builder: (BuildContext context) => AlertDialog(
                                                  title: Text('Leave the group?'),
                                                  content: Text("Are you sure you really want to leave the group chat? You will not be able to access all the messages and data and you can not be return unless you are invited."),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: leaveGroupChat,
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                          },),
                                          )
                                          .toList()),
                                );
                              },
                            );
                      }
                   }
                  ),  
            ],
        ),
        //extendBodyBehindAppBar: true,
        backgroundColor: pink2,
        body: Column(
          children: [
            //ProfileHeaderWidget(name: widget.user['username']),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: CommunityMessagesWidget(communityId: widget.group['communityId'], communityGroupId: widget.group['communityGroupId']),
              ),
            ),
            NewCommunityMessageWidget(communityId: widget.group['communityId'], communityGroupId: widget.group['communityGroupId'], communityGroupName: widget.group['username'])
          ],
        ),
      );
}