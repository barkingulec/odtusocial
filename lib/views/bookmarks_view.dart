import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../utils/colors.dart';
import '../widgets/course_item.dart';

class BookmarksViews extends StatefulWidget {
  const BookmarksViews({super.key});

  @override
  State<BookmarksViews> createState() => _BookmarksViewsState();
}

class _BookmarksViewsState extends State<BookmarksViews> {
  List<Map<String, dynamic>> communities = [];
  String? uid = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  var userData = {};
  var bookmarkedCommunities = [];
  
  @override
  void initState() {
    super.initState();
    getAllCommunities();
    final User? curUser = auth.currentUser;
    uid = curUser!.uid;
  }
  Future<void> getAllCommunities() async {
    CollectionReference communitiesRef =
        FirebaseFirestore.instance.collection('communities');
    final snapshot = await communitiesRef.get();
    communities = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    for (var community in communities) {
      if (community['bookmarkedUsers'].contains(uid)) {
        bookmarkedCommunities.add(community);
      }
    }
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      iconTheme: const IconThemeData(color: black),
      backgroundColor: whiteGray,
      title: const Text(
        "Bookmarks",
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    ),
      body: bookmarkedCommunities.isNotEmpty ? CustomScrollView(
        slivers: [
          SliverList(delegate: getCommunities(),),
        ],
      ): const Center(child: Text("You have not bookmarked any community.")),
    );
  }
    getCommunities() {
      return SliverChildBuilderDelegate(
        childCount: bookmarkedCommunities.length, 
        (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15,),
          child: CourseItem(data: bookmarkedCommunities[index])
        );
      });
    }   
}