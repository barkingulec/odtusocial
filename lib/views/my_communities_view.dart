import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../utils/colors.dart';
import '../widgets/course_item.dart';
import 'community_detail_view.dart';

class MyCommunitiesView extends StatefulWidget {
  const MyCommunitiesView({super.key});

  @override
  State<MyCommunitiesView> createState() => _MyCommunitiesViewState();
}

class _MyCommunitiesViewState extends State<MyCommunitiesView> {
  List<Map<String, dynamic>> communities = [];
  String? uid = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  var userData = {};
  var myCommunities = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getAllCommunities();
    final User? curUser = auth.currentUser;
    uid = curUser!.uid;
  }

  Future<void> getAllCommunities() async {
    setState(() {
      isLoading = true;
    });
    CollectionReference communitiesRef =
        FirebaseFirestore.instance.collection('communities');
    final snapshot = await communitiesRef.get();
    communities = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    for (var community in communities) {
      if (community['enrolledUsers'].contains(uid)) {
        myCommunities.add(community);
      }
    }
    setState(() {
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center(child: CircularProgressIndicator()) : Scaffold(
      body: Container(
        // decoration: BoxDecoration(
        //                 gradient: LinearGradient(
        //                   begin: Alignment.topLeft,
        //                   end: Alignment.bottomRight,
        //                   //stops: [0, 1],
        //                   colors: [
        //                     // pink.withOpacity(.06), 
        //                     // pink.withOpacity(.45),
        //                     pink.withOpacity(.01),
        //                     pink.withOpacity(.02),
        //                     pink.withOpacity(.04),
        //                     pink.withOpacity(.06),
        //                     pink.withOpacity(.085),
        //                     pink.withOpacity(.12),
        //                   ],
        //                 )
        //               ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: whiteGray.withOpacity(0),
              pinned: true,
              title: getAppBar(),
            ),
            SliverList(delegate: getCommunities(),),
          ],
        ),
      ),
    );
  }
    getAppBar() {
      return Container(
        child: Row(
          children: [
            Text(
              "My Clubs & Societies",
              style: TextStyle(color: black, fontWeight: FontWeight.w600, fontSize: 24),
            ),
          ],
        ),
      );
    }

    getCommunities() {
      return SliverChildBuilderDelegate(
        childCount: myCommunities.isNotEmpty ? myCommunities.length : 1, 
        (context, index) {
        return myCommunities.isNotEmpty ? Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15,),
          child: CourseItem(data: myCommunities[index])
        ) : const Padding(
          padding: const EdgeInsets.only(top: 120.0, left: 80),
          child: Text("You have not enrolled to any community."),
        );
      });
    }
}