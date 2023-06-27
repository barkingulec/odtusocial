import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'custom_image.dart';

class MessageWidget extends StatelessWidget {
  final message;
  final bool isMe;

  const MessageWidget({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        // if (!isMe)
        // CustomImage(
        //   message['photoUrl'],
        //   width: 40,
        //   height: 40,
        //   radius: 20,
        // ),
        Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(16),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 5 / 7),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: isMe
                ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
                : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
          ),
          child: buildMessage(),
        ),
      ],
    );
  }

  Widget buildMessage() => Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message['message'],
            style: TextStyle(color: Colors.black),
            textAlign: isMe ? TextAlign.end : TextAlign.start,
          ),
          const SizedBox(height: 7),
          Text(
            (DateFormat('HH:mm').format(message['createdAt'].toDate())),
            style: TextStyle(color: Colors.black.withOpacity(.7), fontSize: 13),
            textAlign: isMe ? TextAlign.end : TextAlign.start,
          ),
        ],
      );
}