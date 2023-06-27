import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:social/utils/colors.dart';
import 'package:upgrader/upgrader.dart';

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
    requestPermission();
    getToken();
    getLastLogin();
  }
  
void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print("permission");
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print("provisional");
    } else {
        print("denied");
    }

    // QuerySnapshot snap = await FirebaseFirestore.instance.collection('profiles').get();
    //   final allComments = snap.docs.map((doc) => doc.data()! as dynamic).toList();

    //   for (var comment in allComments) {    
    //     await  FirebaseFirestore.instance.collection('profiles').doc(comment['uid']).update({
    //           'participation': [],
    //       });
    //   }
  }

void getToken() async {
    await FirebaseMessaging.instance.getToken().then(
      (token) {
        setState(() {
          //mtoken = token;
          //print("my token is $mtoken");
        });
        saveToken(token!);
      }
    );
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection("profiles").doc(uid).update({
      "token": token,
    });
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

  getLastLogin() async {
    try {
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(uid)
          .update({
            'last_login': DateTime.now(),
          });
    } catch(e) {
      showSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center(child: CircularProgressIndicator()) : UpgradeAlert(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: whiteGray.withOpacity(.3),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: whiteGray.withOpacity(.0),
              //pinned: true,
              //snap: true,
              //floating: true,
              title: getAppBar(),
              expandedHeight: 80,
              // flexibleSpace: Container(
              //   // decoration: BoxDecoration(
              //   //   //borderRadius: BorderRadius.all(Radius.circular(15)),
              //   //   gradient: LinearGradient(
              //   //     begin: Alignment.topCenter,
              //   //     end: Alignment.bottomCenter,
              //   //     stops: [0, 1],
              //   //     colors: [whiteGray.withOpacity(.3), whiteGray.withOpacity(.3)],
              //   //   )
              //   // ),

              //   // child: ClipRRect(
              //   //   borderRadius: BorderRadius.circular(18.0),
              //   //   child: FlexibleSpaceBar(
              //   //     centerTitle: true,
              //   //     title: getAppBar(),
              //   //     titlePadding: EdgeInsets.all(20),
              //   //     background: Image.network(
              //   //       "https://images.unsplash.com/photo-1545243424-0ce743321e11?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max&ixid=eyJhcHBfaWQiOjE0NTg5fQ",
              //   //       //"https://images.unsplash.com/photo-1533903345306-15d1c30952de?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max&ixid=eyJhcHBfaWQiOjE0NTg5fQ",
              //   //       //"https://images.unsplash.com/photo-1531306728370-e2ebd9d7bb99?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max&ixid=eyJhcHBfaWQiOjE0NTg5fQ",
              //   //       fit: BoxFit.cover,
              //   //       )
              //   //   ),
              //   // )
              // ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => buildBody(),
                childCount: 1,
              ),
            )
          ],
        )
      ),
    );
  }
  Widget getAppBar(){
    return
      Container(
        child: Column(
          children: [
            SizedBox(height: 22, ), 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: 
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text(username ?? "user is not logged in", style: TextStyle(color: primaryColor, fontSize: 14,),),
                      // SizedBox(height: 5,),
                      // Text("Welcome back!", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500, fontSize: 18,)),         
                      Text("ODTÜ SOCIAL", style: GoogleFonts.kalam(color: primaryColor, fontSize: 40),)
                      // caveat, 40
                      // kalam, 40
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
          ],
        ),
      );
  }

  buildBody(){
    return
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 36, bottom: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                const Padding(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                  child: Text("Featured Societies", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 21,)),
                ),
                getFeature(),
                const SizedBox(height: 36,),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Upcoming Events", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primaryColor),),
                      // Text("See all", style: TextStyle(fontSize: 14, color: primaryColor),),
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