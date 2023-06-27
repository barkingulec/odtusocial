import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

import '../utils/colors.dart';
import '../views/chat_single_view.dart';

class ChatHeaderWidget extends StatefulWidget {
  final users;

  const ChatHeaderWidget({ @required this.users, Key? key,}) : super(key: key);

  @override
  State<ChatHeaderWidget> createState() => _ChatHeaderWidgetState();
}

class _ChatHeaderWidgetState extends State<ChatHeaderWidget> {
  int selectedIndex = 0;
  final List<String> categories = ['Messages', 'Societies', 'Requests'];
  
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Container(
            //   width: MediaQuery.of(context).size.width * 0.75,
            //   child: Text(
            //     'Messages',
            //     style: TextStyle(
            //       color: white,
            //       fontSize: 26,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            SizedBox(height: 12),
              Container(
                alignment: Alignment.center,
                height: 30.0,
                color: pink.withOpacity(.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Center(
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              //color: index == selectedIndex ? Colors.white : Color.fromARGB(179, 255, 255, 255),
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: index == selectedIndex ? FontWeight.bold : FontWeight.w500,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // child: ListView.builder(
              //   scrollDirection: Axis.horizontal,
              //   itemCount: users.length,
              //   itemBuilder: (context, index) {
              //     final user = users[index];
              //     if (index == 0) {
              //       return Container(
              //         margin: EdgeInsets.only(right: 12),
              //         child: CircleAvatar(
              //           radius: 24,
              //           child: Icon(Icons.search),
              //         ),
              //       );
              //     } else {
              //       return Container(
              //         margin: const EdgeInsets.only(right: 12),
              //         child: GestureDetector(
              //           onTap: () {
              //             Navigator.of(context).push(MaterialPageRoute(
              //               builder: (context) => SingleChatPage(user: users[index]),
              //             ));
              //           },
              //           child: CircleAvatar(
              //             radius: 24,
              //             backgroundImage: NetworkImage(user['photoUrl']),
              //           ),
              //         ),
              //       );
              //     }
              //   },
              // ),
          ],
        ),
      );
}