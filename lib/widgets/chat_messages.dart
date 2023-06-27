import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

import '../utils/colors.dart';
import 'chat_message.dart';

class MessagesWidget extends StatefulWidget {
  final String idUser;

  const MessagesWidget({
    required this.idUser,
    Key? key,
  }) : super(key: key);

  @override
  State<MessagesWidget> createState() => _MessagesWidgetState();
}

class _MessagesWidgetState extends State<MessagesWidget> {
  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: FirebaseFirestore.instance
          .collection('profiles')
          .doc(widget.idUser)
          .collection('messagesProfiles')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                return buildText('Something went wrong ,please try later.');
              } else {
                final messages = snapshot.data!.docs;

                return messages.isEmpty
                    ? buildText('Say Hi..') : 
                    GroupedListView(
                      elements: messages,
                      groupBy: (message) => DateTime(
                        int.parse(DateFormat('dd/MM/yyyy').format(message['createdAt'].toDate()).toString().split("/")[2]),
                        int.parse(DateFormat('dd/MM/yyyy').format(message['createdAt'].toDate()).toString().split("/")[1]),
                        int.parse(DateFormat('dd/MM/yyyy').format(message['createdAt'].toDate()).toString().split("/")[0]),
                      ),
                        physics: BouncingScrollPhysics(),
                        sort: false,
                        reverse: true,
                        order: GroupedListOrder.DESC,
                        useStickyGroupSeparators: true,
                        floatingHeader: true,
                        groupHeaderBuilder: (message) => SizedBox(
                          height: 40,
                          child: Center(
                            child: Card(
                              color: pink2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  DateFormat.yMMMd().format(message['createdAt'].toDate()),
                                  style: TextStyle(color: white),
                                ),
                              ),
                            ),
                          ),
                          ),
                        itemBuilder: (context, message) {
                          return MessageWidget(
                            message: message,
                            isMe: message['senderUserId'] == FirebaseAuth.instance.currentUser!.uid,
                          );
                        },
                      );
                    
                    // ListView.builder(
                    //     physics: BouncingScrollPhysics(),
                    //     reverse: true,
                    //     itemCount: messages.length,
                    //     itemBuilder: (context, index) {
                    //       final message = messages[index];

                    //       return MessageWidget(
                    //         message: message,
                    //         isMe: message['senderUserId'] == FirebaseAuth.instance.currentUser!.uid,
                    //       );
                    //     },
                    //   );
              }
          }
        },
      );

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 20),
        ),
      );
}