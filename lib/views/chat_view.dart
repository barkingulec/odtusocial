import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social/utils/colors.dart';

import '../utils/utils.dart';
import '../widgets/chat_body.dart';
import '../widgets/chat_community_body.dart';
import '../widgets/chat_header.dart';

class ChatsPage extends StatefulWidget {
  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  int selectedIndex = 0;
  final List<String> categories = ['Messages', 'Societies', 'Requests'];
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userUid = "";
  Stream<QuerySnapshot<Map<String, dynamic>>>? messagesStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? groupsStream;
  List allGroups = [];
  List allGroupsFromCommunity = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final User? curUser = auth.currentUser;
    userUid = curUser!.uid;
    getAllGroups();
    getData();
  }

  getData() {
    setState(() {
      isLoading = true;
    });
    try {
      
      messagesStream = FirebaseFirestore.instance
                .collection('profiles')
                .doc(userUid)
                .collection('messagesProfiles')
                .orderBy('lastMessageTime', descending: true)
                .snapshots();

      setState(() {
        
      });

    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getAllGroups()async
  {
    setState(() {
      isLoading = true;
    });
    var query= await FirebaseFirestore.instance.collection("profiles").doc(userUid).collection('messagesCommunities').get();
    for(var community in query.docs)
      {
        QuerySnapshot feed = await FirebaseFirestore.instance.collection("profiles")
            .doc(userUid)
            .collection("messagesCommunities")
            .doc(community.id)
            .collection('messagesGroups')
            .orderBy('lastMessageTime', descending: true)
            .get();
                  
        for (var postDoc in feed.docs ) {
          allGroups.add(postDoc.data() as Map<String, dynamic>);
        }
      }

      for (var group in allGroups) {
        var dataSnap = await FirebaseFirestore.instance
                .collection('communities')
                .doc(group['communityId'])
                .collection('messagesGroups')
                .doc(group['communityGroupId'])
                .get();
        var data = dataSnap.data()!;
        allGroupsFromCommunity.add(data);

      }
      setState(() {
        isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: pink.withOpacity(.4),
        body: isLoading ? const Center(child: CircularProgressIndicator()) : StreamBuilder(
          stream: messagesStream,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return buildText('Something Went Wrong Try later');
                } else {
                  final dataArr = snapshot.data!.docs;
                  // if (users.isEmpty) {
                  //   return buildText('No Users Found');
                  // } else {
                    return Column(
                      children: [
                        //ChatHeaderWidget(users: users),
                        buildHeader(),
                        selectedIndex == 0 ? ChatBodyWidget(users: dataArr) : ChatCommunityBodyWidget(groups: allGroups, allGroupsFromCommunity: allGroupsFromCommunity)
                      ],
                    );
                  //}
                }
            }
          },
        ),
      );

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24),
        ),
      );

  Widget buildHeader() => Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
          ],
        ),
      );

}