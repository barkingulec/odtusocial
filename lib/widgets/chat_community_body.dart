import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/utils.dart';
import '../views/chat_single_community_view.dart';
import '../views/chat_single_view.dart';
import 'custom_image.dart';

class ChatCommunityBodyWidget extends StatefulWidget {
  final groups;
  final allGroupsFromCommunity;

  const ChatCommunityBodyWidget({ @required this.groups, Key? key, this.allGroupsFromCommunity,}) : super(key: key);

  @override
  State<ChatCommunityBodyWidget> createState() => _ChatCommunityBodyWidgetState();
}

class _ChatCommunityBodyWidgetState extends State<ChatCommunityBodyWidget> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: widget.groups.isNotEmpty ? buildChats() : buildText(),
        ),
      );

  Widget buildChats() => ListView.builder(
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final group = widget.groups[index];
          final groupFromCommunity = widget.allGroupsFromCommunity[index];
          //return user['uid'] == FirebaseAuth.instance.currentUser!.uid ? const SizedBox() : 
          return SizedBox(
            height: 75,
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SingleCommunityGroupChatPage(group: group, groupFromCommunity: groupFromCommunity)
                ));
              },
              leading: CustomImage(
                group['photoUrl'],
                width: 40,
                height: 40,
                radius: 20,
              ),
              title: Text(group['username']),
              subtitle: Text(groupFromCommunity['lastMessage'], overflow: TextOverflow.ellipsis,),
              trailing: Text((DateFormat('HH:mm').format(groupFromCommunity['lastMessageTime'].toDate())),
                style: TextStyle(color: Colors.black.withOpacity(.7), fontSize: 13),),
                ),
          );
        },
        itemCount: widget.groups.length,
      );

      Widget buildText() => Padding(
        padding: const EdgeInsets.all(14.0),
        child: Center(
          child: Text(
            "You have not joined to any society.",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
}