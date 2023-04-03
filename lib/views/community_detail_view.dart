import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readmore/readmore.dart';
import 'package:social/views/requests_view.dart';
import 'package:social/widgets/custom_image.dart';
import '../services/auth/firestore_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/add_event.dart';
import '../widgets/enroll_button.dart';
import '../widgets/event_item.dart';

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
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    getData();
    fetchEventLen();
    tabController = TabController(length: 2, vsync: this);
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
          .contains(FirebaseAuth.instance.currentUser!.uid);
      isMember = communitySnap
          .data()!['enrolledUsers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      isAdmin = communitySnap
          .data()!['admins']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      isBookmarked = communitySnap
          .data()!['bookmarkedUsers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
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

    leaveCommunity() async {
                        await FireStoreMethods()
                            .leaveCommunity(
                          FirebaseAuth.instance
                              .currentUser!.uid,
                              widget.communityId,
                        );
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
        "Community Detail", 
        style: TextStyle(color: black),
      ),
      actions: isMember ? [
                 
                 PopupMenuButton(
                   // add icon, by default "3 dot" icon
                   // icon: Icon(Icons.book)
                   itemBuilder: (context){
                     return isAdmin ? const [
                            PopupMenuItem<int>(
                                value: 0,
                                child: Text("Add Event"),
                            ),

                            PopupMenuItem<int>(
                                value: 1,
                                child: Text("Requests"),
                            ),

                            PopupMenuItem<int>(
                                value: 2,
                                child: Text("Leave Community"),
                            ),
                        ] : const [
                            PopupMenuItem<int>(
                                value: 2,
                                child: Text("Leave Community"),
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
                      }else if(value == 2){
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
                                                  leaveCommunity();
                                                  // remove the dialog box
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context).pop();
                                                }),
                                          )
                                          .toList()),
                                );
                              },
                            );
                      }
                   }
                  ),  
            ] : [],
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
      backgroundColor: whiteGray,
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
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
          const SizedBox(height: 15,),
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
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset("assets/profile.svg", color: pink, width: 20, height: 20,),
                      const SizedBox(width: 5,),
                      Text("$members Active Members"),
                      const SizedBox(width: 10,),
                      SvgPicture.asset("assets/schedule.svg", color: pink, width: 20, height: 20,),
                      const SizedBox(width: 5,),
                      Text("$eventsNumber Events"),
                    ],
                  ),
                  isMember ? const SizedBox(width: 0) : enrollButton(),
              ],
              ),
          const SizedBox(height: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("About Community", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: black)),
              const SizedBox(height: 10,),
              ReadMoreText(
                communityData['desc'], 
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: gray),
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
    );
  }
  Widget getTabBar() {
    return Container(
      child: TabBar(
        controller: tabController,
        tabs: [
        Tab(child: Text("Upcoming Events", style: TextStyle(fontSize: 16, color: black),),),
        Tab(child: Text("Past Events", style: TextStyle(fontSize: 16, color: black)),)
      ],),
    );
  }
  Widget getTabBarPages() {
    return Container(
      height: 200,
      width: double.infinity,
      child: TabBarView(
        // physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          getUpcomingEvents(),
          getPastEvents(),
      ],
      ),
    );
  }
  Widget getUpcomingEvents() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('communities')
            .doc(communityData["communityId"])
            .collection('events')
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
                      width: 120,
                    )
                  : EnrollButton(
                      text: 'Send Request',
                      backgroundColor: pink,
                      textColor: Colors.white,
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