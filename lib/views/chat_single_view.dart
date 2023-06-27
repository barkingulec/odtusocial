
import 'package:flutter/material.dart';
import 'package:social/views/profile_view.dart';

import '../utils/colors.dart';
import '../widgets/chat_messages.dart';
import '../widgets/chat_new_message.dart';
import 'chat_profile_header.dart';

class SingleChatPage extends StatefulWidget {
  final user;

  const SingleChatPage({
    @required this.user,
    Key? key,
  }) : super(key: key);

  @override
  _SingleChatPageState createState() => _SingleChatPageState();
}

class _SingleChatPageState extends State<SingleChatPage> {
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
            title: GestureDetector(
              onTap: (){
                          Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProfileView(
                                    uid: widget.user['uid'],
                                  ),
                                ),
                              );
                      },
              child: Text(
                widget.user['username'],
                style: TextStyle(
                  color: white,
                ),
              ),
            ),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: MessagesWidget(idUser: widget.user['uid']),
              ),
            ),
            NewMessageWidget(idUser: widget.user['uid'])
          ],
        ),
      );
}