import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social/services/auth/firestore_methods.dart';

import '../utils/colors.dart';

class NewCommunityMessageWidget extends StatefulWidget {
  final String communityId;
  final String communityGroupId;
  final String communityGroupName;

  const NewCommunityMessageWidget({
    Key? key, required this.communityId, required this.communityGroupId, required this.communityGroupName,
  }) : super(key: key);

  @override
  _NewCommunityMessageWidgetState createState() => _NewCommunityMessageWidgetState();
}

class _NewCommunityMessageWidgetState extends State<NewCommunityMessageWidget> {
  final _controller = TextEditingController();
  String message = '';

  void sendMessage() async {
    FocusScope.of(context).unfocus();

    await FireStoreMethods().uploadCommunityMessage(widget.communityId, widget.communityGroupId, FirebaseAuth.instance.currentUser!.uid, message, widget.communityGroupName);

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) => Container(
        color: white,
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  labelText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 0),
                    gapPadding: 10,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onChanged: (value) => setState(() {
                  message = value;
                }),
              ),
            ),
            SizedBox(width: 20),
            GestureDetector(
              onTap: message.trim().isEmpty ? null : sendMessage,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // color: Colors.blue,
                  color: pink2,
                ),
                child: Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      );
}