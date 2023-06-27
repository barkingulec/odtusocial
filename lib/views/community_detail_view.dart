import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readmore/readmore.dart';
import 'package:social/views/chat_single_view.dart';
import 'package:social/views/requests_view.dart';
import 'package:social/widgets/custom_image.dart';
import 'package:social/widgets/single_post.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth/firestore_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/add_event.dart';
import '../widgets/enroll_button.dart';
import '../widgets/event_item.dart';
import 'add_group_chat_view.dart';
import 'add_post_view.dart';
import 'admins_view.dart';
import 'chat_single_community_view.dart';
import 'edit_community.dart';
import 'members_view.dart';

class CommunityDetailView extends StatefulWidget {
  final communityId;
  const CommunityDetailView({Key? key, required this.communityId}) : super(key: key);

  @override
  State<CommunityDetailView> createState() => _CommunityDetailViewState();
}

class _CommunityDetailViewState extends State<CommunityDetailView> with SingleTickerProviderStateMixin{
  var communityData = {};
  bool isLoading = false;
  bool isRequested = false;
  bool isMember = false;
  bool isAdmin = false;
  bool isBookmarked= false;
  int members = 0;
  int eventsNumber = 0;
  int postsNumber = 0;
  late TabController tabController;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userUid = ""; 

  @override
  void initState() {
    super.initState();
    final User? curUser = auth.currentUser;
    userUid = curUser!.uid;
    getData();
    fetchEventLen();
    fetchPostLen();
    tabController = TabController(length: 3, vsync: this);
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {

      var communitySnap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .get();

      communityData = communitySnap.data()!;
      members = communitySnap.data()!['enrolledUsers'].length;
      isRequested = communitySnap
          .data()!['requests']
          .contains(userUid);
      isMember = communitySnap
          .data()!['enrolledUsers']
          .contains(userUid);
      isAdmin = communitySnap
          .data()!['admins']
          .contains(userUid);
      isBookmarked = communitySnap
          .data()!['bookmarkedUsers']
          .contains(userUid);
      setState(() {

      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  fetchEventLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('events')
          .get();
      eventsNumber = snap.docs.length;
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
    setState(() {});
  }

  fetchPostLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('posts')
          .get();
      postsNumber = snap.docs.length;
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
    setState(() {});
  }

    leaveCommunity() async {
                        await FireStoreMethods()
                            .leaveCommunity(
                          FirebaseAuth.instance
                              .currentUser!.uid,
                              widget.communityId,
                        );
                        Navigator.popUntil(context, (route) => route.isFirst);
    }

  openMap() async {
   GeoPoint position = communityData['location'];
   final lat = position.latitude;
   final lng = position.longitude;

   Uri uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    await launchUrl(uri);
}

  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center( child: CircularProgressIndicator() )
      : Scaffold(
        appBar: buildAppBar(),
        body: buildBody(),
      );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: const Text(
        "Society Detail", 
        style: TextStyle(color: black),
      ),
      actions: isMember ? [
                 
                 PopupMenuButton(
                   // add icon, by default "3 dot" icon
                   icon: SvgPicture.asset("assets/details.svg", color: black.withOpacity(.7), width: 25, height: 25,),
                   itemBuilder: (context){
                     return isAdmin ? const [
                            PopupMenuItem<int>(
                                value: 0,
                                child: Text("Add Event"),
                            ),
                            PopupMenuItem<int>(
                                value: 6,
                                child: Text("Add Post"),
                            ),
                            PopupMenuItem<int>(
                                value: 7,
                                child: Text("Add Group Chat"),
                            ),

                            PopupMenuItem<int>(
                                value: 1,
                                child: Text("Requests"),
                            ),
                            PopupMenuItem<int>(
                                value: 5,
                                child: Text("Members"),
                            ),
                            PopupMenuItem<int>(
                                value: 3,
                                child: Text("Admins"),
                            ),
                            PopupMenuItem<int>(
                                value: 4,
                                child: Text("Edit Society"),
                            ),
                            PopupMenuItem<int>(
                                value: 2,
                                child: Text("Leave Society"),
                            ),
                        ] : const [
                          PopupMenuItem<int>(
                                value: 5,
                                child: Text("Members"),
                            ),
                            PopupMenuItem<int>(
                                value: 2,
                                child: Text("Leave Society"),
                            ),
                            ];
                   },
                   onSelected:(value){
                      if(value == 0){
                            Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddEventView(
                                communityId: communityData['communityId'].toString(),
                              ),
                            ),
                          ).then((_) => setState(() {}));
                      }else if(value == 1){
                         Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RequestsView(
                                communityId: communityData['communityId'].toString(),
                              ),
                            ),
                          ).then((_) => setState(() {}));
                          
                      }else if(value == 3){
                         Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AdminsView(
                                communityId: communityData['communityId'].toString(),
                              ),
                            ),
                          ).then((_) => setState(() {}));}
                          else if(value == 4){
                         Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditCommunityView(
                                communityId: communityData['communityId'].toString(),
                              ),
                            ),
                          ).then((_) => setState(() {}));}
                          else if(value == 5){
                         Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MembersView(
                                communityId: communityData['communityId'].toString(),
                              ),
                            ),
                          ).then((_) => setState(() {}));}
                          else if(value == 6){
                         Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddPostView(
                                communityId: communityData['communityId'].toString(),
                              ),
                            ),
                          ).then((_) => setState(() {}));}
                          else if(value == 7){
                         Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddGroupChat(
                                communityId: communityData['communityId'].toString(),
                              ),
                            ),
                          ).then((_) => setState(() {}));}
                      else if(value == 2){
                        showDialog(
                              useRootNavigator: false,
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: ListView(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shrinkWrap: true,
                                      children: [
                                        'Confirm Leave',
                                      ]
                                          .map(
                                            (e) => InkWell(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                          horizontal: 16),
                                                  child: Text(e),
                                                ),
                                                onTap: () {
                                            showDialog<String>(
                                                context: context,
                                                builder: (BuildContext context) => AlertDialog(
                                                  title: Text('Leave the society'),
                                                  content: Text("Are you sure you really want to leave the society? You will not be able to join unless an admin accept your request."),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: leaveCommunity,
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                          },),
                                          )
                                          .toList()),
                                );
                              },
                            );
                      }
                   }
                  ),  
            ]
            // if not member;
            : [],

      // actions: <Widget>[
      //   IconButton(
      //     icon: const Icon(
      //       Icons.add,
      //       color: black,
      //       size: 32,
      //     ),
      //     onPressed: () => Navigator.of(context).push(
      //                 MaterialPageRoute(
      //                   builder: (context) => AddEventView(
      //                     communityId: communityData['communityId'].toString(),
      //                   ),
      //                 ),
      //               ),
      //   )
      // ],
      iconTheme: const IconThemeData(color: black),
      leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: black.withOpacity(.7)),
            onPressed: () => Navigator.of(context).pop(),
          ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: whiteGray.withOpacity(0),
    );
  }

  Widget buildBody() {
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          //stops: [0, 1],
                          colors: [
                            // pink.withOpacity(.06), 
                            // pink.withOpacity(.45),
                            pink.withOpacity(.0),
                            pink.withOpacity(.01),
                            pink.withOpacity(.02),
                            pink.withOpacity(.03),
                            pink.withOpacity(.04),
                            pink.withOpacity(.05),
                            pink.withOpacity(.06),
                          ],
                        )
                      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomImage(
              communityData['image'],
              radius: 10,
              width: double.infinity,
              height: 200,
            ),
            const SizedBox(height: 6,),

            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MembersView(
                                  communityId: communityData['communityId'].toString(),
                                ),
                              ),
                            ).then((_) => setState(() {}));
                          },
                    child: Column(
                      children: [
                        Text("$members", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4,),
                        Text("Members", style: TextStyle(color: black.withOpacity(.80), fontSize: 13),),
                      ],
                    ),
                  ),
                  Container(
                    height: 26,
                    width: 1,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide( 
                          color: pink,
                          width: 1.0,
                        ),
                      )
                    ),
                  ),
                  Column(
                    children: [
                      Text("$eventsNumber".toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4,),
                      Text("Events", style: TextStyle(color: black.withOpacity(.80), fontSize: 13),),
                    ],
                  ),
                  Container(
                    height: 26,
                    width: 1,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide( 
                          color: pink,
                          width: 1.0,
                        ),
                      )
                    ),
                  ),
                  Column(
                    children: [
                      Text("$postsNumber", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4,),
                      Text("Posts", style: TextStyle(color: black.withOpacity(.80), fontSize: 13),),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  communityData['name'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: black,
                  ),
                  ),
                  !isMember ? enrollButton() : const SizedBox(width: 0),
                IconButton(
                  onPressed: () async {
                          await FireStoreMethods()
                              .bookmarkCommunity(
                            FirebaseAuth.instance
                                .currentUser!.uid,
                                widget.communityId,
                          );
    
                        setState(() {
                          isBookmarked = !isBookmarked;
                        });
                      },
                  icon: isBookmarked ? const Icon(Icons.bookmark, color: pink, size: 25)
                  : SvgPicture.asset("assets/bookmark.svg", color: pink, width: 25, height: 25,),
                  ),
              ],
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     TextButton(
            //       onPressed: () {
            //                 Navigator.of(context).push(
            //                   MaterialPageRoute(
            //                     builder: (context) => SingleCommunityGroupChatPage(
            //                       group: communityData,
            //                     ),
            //                   ),
            //                 ).then((_) => setState(() {}));
            //               },
            //       child: Text("Society Chat",),
            //       ),
            //   ],
            // ),
            // isMember ? const SizedBox(height: 10,) : const SizedBox(height: 0,),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Row(
            //           children: [
            //             GestureDetector(
            //               onTap: () {
            //                 Navigator.of(context).push(
            //                   MaterialPageRoute(
            //                     builder: (context) => MembersView(
            //                       communityId: communityData['communityId'].toString(),
            //                     ),
            //                   ),
            //                 ).then((_) => setState(() {}));
            //               },
            //               child: Row(
            //                 children: [
            //                   SvgPicture.asset("assets/profile.svg", color: pink, width: 20, height: 20,),
            //                   const SizedBox(width: 5,),
            //                   Text("$members Members", style: TextStyle(color: black.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500),),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //         isMember ? const SizedBox(width: 0) : enrollButton(),
            //     ],
            //     ),
            //     const SizedBox(height: 6),
            //     Row(
            //           children: [
            //             SvgPicture.asset("assets/schedule.svg", color: pink, width: 20, height: 20,),
            //             const SizedBox(width: 5,),
            //             Text("$eventsNumber Events", style: TextStyle(color: black.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500),),
            //           ]
            //         ),
            //         const SizedBox(height: 7),
            //             Row(
            //               children: [
            //                 const SizedBox(width: 3,),
            //                 SvgPicture.asset("assets/gallery.svg", color: pink.withOpacity(0.8), width: 15, height: 15,),
            //                 const SizedBox(width: 6,),
            //                 Text("$postsNumber Posts", style: TextStyle(color: black.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500),),
            //               ],
            //             ),

            // const SizedBox(height: 12,),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset("assets/location.svg", color: pink, width: 19, height: 19,),
                    const SizedBox(width: 5,),
                    TextButton(
                      onPressed: openMap,
                      child: Text(
                        "Location", 
                        style: TextStyle(color: black.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                ],
                ),

            isMember ? const SizedBox(height: 12,) : const SizedBox(height: 6,),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("About Society", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: black)),
                const SizedBox(height: 10,),
                ReadMoreText(
                  communityData['desc'], 
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: black.withOpacity(0.7)),
                  trimLines: 2,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: "Show more",
                  moreStyle: const TextStyle(fontSize: 14, color: pink),
                  lessStyle: const TextStyle(fontSize: 14, color: pink),
                  ),
            ],),
            const SizedBox(height: 20,),
            getTabBar(),
            getTabBarPages(),
          ],
        )
      ),
    );
  }
  Widget getTabBar() {
    return TabBar(
      controller: tabController,
      tabs: const [
      Tab(child: Text("Posts", style: TextStyle(fontSize: 16, color: black),),),
      Tab(child: Text("Events", style: TextStyle(fontSize: 16, color: black),),),
      Tab(child: Text("Past Events", style: TextStyle(fontSize: 16, color: black)),)
    ],);
  }
  
  Widget getTabBarPages() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2.1,
      //width: double.infinity,
      child: TabBarView(
        // physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          getPosts(),
          getUpcomingEvents(),
          getPastEvents(),
      ],
      ),
    );
  }
  
  Widget getPosts() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('communities')
            .doc(communityData["communityId"])
            .collection('posts')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
    
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) => SinglePost(
              postData: snapshot.data!.docs[index],
              userId: userUid,
              communityData: communityData,
            ),
          );
        },
      );
  }

  Widget getUpcomingEvents() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('communities')
            .doc(communityData["communityId"])
            .collection('events')
            .orderBy('date')
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) => UpcomingEventItem(
              data: snapshot.data!.docs[index],
              userUid: userUid,
              communityData: communityData,
            ),
          );
        },
      );
  }

  Widget getPastEvents() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('communities')
            .doc(communityData["communityId"])
            .collection('events')
            .orderBy('date')
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) => PastEventItem(
              data: snapshot.data!.docs[index],
              userUid: userUid,
              communityData: communityData,
            ),
          );
        },
      );
  }

  Widget enrollButton() {
    return isRequested ? EnrollButton(
                      text: 'Cancel Request',
                      backgroundColor: Colors.white,
                      textColor: pink,
                      borderColor: pink,
                      function: () async {
                        await FireStoreMethods()
                            .enrollCommunity(
                          FirebaseAuth.instance
                              .currentUser!.uid,
                              widget.communityId,
                        );

                        setState(() {
                          isRequested = false;
                        });
                      },
                      height: 30,
                      width: 120,
                    )
                  : EnrollButton(
                      text: 'Send Request',
                      backgroundColor: Colors.white,
                      textColor: pink,
                      borderColor: pink,
                      function: () async {
                        await FireStoreMethods()
                            .enrollCommunity(
                          FirebaseAuth.instance
                              .currentUser!.uid,
                              widget.communityId,
                        );

                      setState(() {
                        isRequested = true;
                      });
                    },
                    height: 30,
                    width: 120,
                  );
  }

    // : Scaffold(
    //   appBar: AppBar(
    //     backgroundColor: mobileBackgroundColor,
    //     title: Text(
    //       communityData['name']
    //     ),
    //     centerTitle: false,
    //   ),
    //   body: Container(
    //           padding: const EdgeInsets.symmetric(horizontal: 16),
    //           child: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: <Widget>[
    //               Container(
    //                 width: double.infinity,
    //                 padding: const EdgeInsets.only(
    //                   top: 8,
    //                 ),
    //                 child: RichText(
    //                   text: TextSpan(
    //                     style: const TextStyle(color: primaryColor),
    //                     children: [
    //                       TextSpan(
    //                         text: communityData['desc'].toString(),
    //                         style: const TextStyle(
    //                           fontWeight: FontWeight.bold,
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //               InkWell(
    //                 child: Container(
    //                   padding: const EdgeInsets.symmetric(vertical: 4),
    //                   child: Text(
    //                     'View all $commentLen events',
    //                     style: const TextStyle(
    //                       fontSize: 16,
    //                       color: primaryColor,
    //                     ),
    //                   ),
    //                 ),
    //                 onTap: () => Navigator.of(context).push(
    //                   MaterialPageRoute(
    //                     builder: (context) => AddEventView(
    //                       communityId: widget.communityId.toString(),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //               isMember ? EnrollButton(
    //                   text: 'Leave',
    //                   backgroundColor: Colors.white,
    //                   textColor: Colors.black,
    //                   borderColor: Colors.grey,
    //                   function: () async {
    //                     await FireStoreMethods()
    //                         .enrollCommunity(
    //                       FirebaseAuth.instance
    //                           .currentUser!.uid,
    //                           widget.communityId,
    //                     );

    //                     setState(() {
    //                       isMember = false;
    //                       members--;
    //                     });
    //                   },
    //                 )
    //               : EnrollButton(
    //                   text: 'Join',
    //                   backgroundColor: Colors.blue,
    //                   textColor: Colors.white,
    //                   borderColor: Colors.blue,
    //                   function: () async {
    //                     await FireStoreMethods()
    //                         .enrollCommunity(
    //                       FirebaseAuth.instance
    //                           .currentUser!.uid,
    //                           widget.communityId,
    //                     );

    //                   setState(() {
    //                     isMember = true;
    //                     members++;
    //                   });
    //                 },
    //               ),
    //               Text(members.toString()),
    //             ],
    //           ),
    //         )
    //   );
}