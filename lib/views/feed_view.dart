import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:social/utils/colors.dart';

import '../services/auth/auth_methods.dart';
import '../services/auth/firestore_methods.dart';
import '../utils/utils.dart';
import '../widgets/community.dart';
import '../widgets/feature_item.dart';
import '../widgets/notification_box.dart';
import '../widgets/recommend_item.dart';
import 'notification_view.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String? username;
  String uid = "";
  List<Map<String, dynamic>> communities = [];
  List<Map<String, dynamic>> allEvents = [];
  var userData = {};
  var newNotifications = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getAllCommunities();
    getAllEvents();
    final User? curUser = auth.currentUser;
    username = curUser!.displayName;
    uid = curUser.uid;
    getNotifications();
  }

  Future<void> getAllCommunities() async {
    CollectionReference communitiesRef =
        FirebaseFirestore.instance.collection('communities');
    final snapshot = await communitiesRef.get();
    communities = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    setState(() {
      
    });
  }

  Future<void> getAllEvents()async
  {
    var query= await FirebaseFirestore.instance.collection("communities").get();
    for(var userdoc in query.docs)
      {
        QuerySnapshot feed = await FirebaseFirestore.instance.collection("communities")
            .doc(userdoc.id).collection("events").get();
                  
        for (var postDoc in feed.docs ) {
          allEvents.add(postDoc.data() as Map<String, dynamic>);
        }
      }
      setState(() {
      
    });
  }

  getNotifications() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(uid)
          .get();
      userData = userSnap.data()!;
      newNotifications = userData['notifications_new'];

    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center(child: CircularProgressIndicator()) : Scaffold(
      backgroundColor: whiteGray,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: whiteGray,
            pinned: true,
            snap: true,
            floating: true,
            title: getAppBar(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => buildBody(),
              childCount: 1,
            ),
          )
        ],
      )
    );
  }
  Widget getAppBar(){
    return
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: 
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(username ?? "user is not logged in", style: TextStyle(color: primaryColor, fontSize: 14,),),
                  SizedBox(height: 5,),
                  Text("Welcome back!", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500, fontSize: 18,)),
                ],
              )
            ),
            NotificationBox(
              notifiedNumber: newNotifications.length,
              onTap: () async{
                Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => NotificationView(newLength: newNotifications.length,),
                            ),
                          );
                    await FireStoreMethods()
                            .updateNotifications(
                          uid,
                        );
              },
            ),
          ],
        ),
      );
  }

  buildBody(){
    return
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                const Padding(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                  child: Text("Featured Communities", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 21,)),
                ),
                getFeature(),
                const SizedBox(height: 15,),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Upcoming Events", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primaryColor),),
                      Text("See all", style: TextStyle(fontSize: 14, color: primaryColor),),
                    ],
                  ),
                ),
                getRecommend(),
              ]
          ),
        ),
      );
  }

  getFeature(){
    return 
      CarouselSlider(
        options: CarouselOptions(
          height: 290,
          enlargeCenterPage: true,
          disableCenter: true,
          viewportFraction: .75,
        ),
        items: List.generate(communities.length, 
          (index) => FeatureItem(
            data: communities[index]
          )
        )
      );
  }

  getRecommend(){
    return
    SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(15, 5, 0, 5),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(allEvents.length, (index) => 
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: RecommendItem(
                data: allEvents[index],
              )
            ) 
          )
        ),
      );
   }
}