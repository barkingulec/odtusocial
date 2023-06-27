import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../utils/colors.dart';
import '../views/profile_view.dart';
import 'custom_image.dart';
import 'package:slide_popup_dialog_null_safety/slide_popup_dialog.dart' as slideDialog;

import 'enroll_button.dart';

class CommunityMessageWidget extends StatelessWidget {
  final message;
  final bool isMe;

  const CommunityMessageWidget({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(20);
    final borderRadius = BorderRadius.all(radius);

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
                          uid: message['senderUserId'],
                        ),
                      ),
                    ),
                      child: CustomImage(
                        message['senderPhotoUrl'],
                        width: 100,
                        height: 100,
                        radius: 50,
                        ),
                    ),
                      Column(
                        children: [
                          EnrollButton(
                                    text: 'Follow',
                                    backgroundColor: white,
                                    textColor: pink.withOpacity(.7),
                                    borderColor: pink.withOpacity(.7),
                                    function: () {},
                                    height: 30,
                                    width: 120,
                              ),
                          EnrollButton(
                                    text: 'Message',
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
                          uid: message['senderUserId'],
                        ),
                      ),
                    ),
                    child: Text(
                                    message['senderUsername'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                  ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileView(
                          uid: message['senderUserId'],
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


    return GestureDetector(
      onTap: _showDialog,
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (!isMe)
          CustomImage(
            message['senderPhotoUrl'],
            width: 34,
            height: 34,
            radius: 20,
          ),
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 5 / 7),
            decoration: BoxDecoration(
              color: !isMe ? pink2.withOpacity(.4) : Color.fromARGB(255, 241, 241, 241),
              borderRadius: isMe
                  ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
                  : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
            ),
            child: buildMessage(),
          ),
        ],
      ),
    );
  }

  Widget buildMessage() => Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          !isMe ? Text(
            message['senderUsername'],
            style: TextStyle(color: Colors.black.withOpacity(.7), fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: isMe ? TextAlign.end : TextAlign.start,
          ) : const SizedBox(),
          const SizedBox(height: 7),
          Text(
            message['message'],
            style: TextStyle(color:Colors.black.withOpacity(.9), fontSize: 16, fontWeight: FontWeight.w500),
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