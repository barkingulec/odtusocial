import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:social/widgets/single_follower.dart';

import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/single_member.dart';

class FollowersView extends StatefulWidget {
  final uid;
  const FollowersView({super.key, this.uid});

  @override
  State<FollowersView> createState() => _FollowersViewState();
}

class _FollowersViewState extends State<FollowersView> {
  var followers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getAllFollowers();
    //getData();
  }

  Future<void> getAllFollowers() async {
    setState(() {
      isLoading = true;
    });
    CollectionReference followersRef =
        FirebaseFirestore.instance.collection('profiles').doc(widget.uid).collection('followers');
    final snapshot = await followersRef.get();
    followers = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    setState(() {
      isLoading = false;
    });
  }

  // getData() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   try {

  //     var communitySnap = await FirebaseFirestore.instance
  //         .collection('communities')
  //         .doc(widget.communityId)
  //         .get();

  //     communityData = communitySnap.data()!;

  //     members = communitySnap.data()!['enrolledUsers'];

  //     for (Map hs in communityData['roles']) {
  //         for (String key in hs.keys) {
  //           sortedMembers.add(key);
  //       }
  //     }
  //     for (String member in members) {
  //       if (!sortedMembers.contains(member)) {
  //         sortedMembers.add(member);
  //       }
  //     }

  //     setState(() {
  //     });
  //   } catch (e) {
  //     showSnackBar(context, e.toString());
  //   }
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center( child: CircularProgressIndicator() )
      : Scaffold(
        appBar: AppBar(
        iconTheme: const IconThemeData(color: black),
      leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: black.withOpacity(.7)),
            onPressed: () => Navigator.of(context).pop(),
          ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: whiteGray.withOpacity(0),
        title: Text(
          "Followers",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
        body: SingleChildScrollView(
      //physics: const NeverScrollableScrollPhysics(),
        //padding: const EdgeInsets.all(5),
        //scrollDirection: Axis.vertical,
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(followers.length, (index) => 
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 4),
              child: SingleFollower(
                data: followers[index],
              )
            ) 
          ),
        ),
      ),
      );
  }
}