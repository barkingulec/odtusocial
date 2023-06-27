import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../views/chat_single_view.dart';
import 'custom_image.dart';

class ChatBodyWidget extends StatelessWidget {
  final users;

  const ChatBodyWidget({ @required this.users, Key? key,}) : super(key: key);

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
          child: users.isNotEmpty ? buildChats() : buildText(),
        ),
      );

  Widget buildChats() => ListView.builder(
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final user = users[index];

          //return user['uid'] == FirebaseAuth.instance.currentUser!.uid ? const SizedBox() : 
          return SizedBox(
            height: 75,
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SingleChatPage(user: user),
                ));
              },
              leading: CustomImage(
                user['photoUrl'],
                width: 40,
                height: 40,
                radius: 20,
              ),
              title: Text(user['username']),
              subtitle: Text(user['lastMessage'], overflow: TextOverflow.ellipsis,),
              trailing: Text((DateFormat('HH:mm').format(user['lastMessageTime'].toDate())),
                style: TextStyle(color: Colors.black.withOpacity(.7), fontSize: 13),),
                ),
          );
        },
        itemCount: users.length,
      );

      Widget buildText() => Padding(
        padding: const EdgeInsets.all(14.0),
        child: Center(
          child: Text(
            "You have not sent or received any message.",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
}