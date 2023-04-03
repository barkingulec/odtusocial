import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:social/views/requests_view.dart';
import 'package:social/views/update_event.dart';
import 'package:social/widgets/custom_image.dart';
import '../services/auth/firestore_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/add_event.dart';
import '../widgets/enroll_button.dart';
import '../widgets/event_item.dart';

class EventDetailView extends StatefulWidget {
  final communityId;
  final eventId;
  const EventDetailView({Key? key, required this.communityId, required this.eventId}) : super(key: key);

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> with SingleTickerProviderStateMixin{
  var communityData = {};
  var eventData = {};
  var datediff;
  var minutes;
  bool isLoading = false;
  bool isRequested = false;
  bool isMember = false;
  bool isAdmin = false;
  bool isBookmarked= false;
  int members = 0;
  int eventsNumber = 0;
  bool isUpcoming = false;
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

      var eventSnap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('events')
          .doc(widget.eventId)
          .get();

      eventData = eventSnap.data()!;
      
      datediff = eventData['date'].toDate().difference(DateTime.now());
      minutes = datediff.inMinutes % datediff.inHours;
      isUpcoming = datediff.inMinutes > 0;

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

  deleteEvent(String communityId, String eventId) async {
    try {
      await FireStoreMethods().deleteEvent(communityId, eventId);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
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
        "Event Detail", 
        style: TextStyle(color: black),
      ),
      actions: isAdmin ? [
                 
                 PopupMenuButton(
                   // add icon, by default "3 dot" icon
                   // icon: Icon(Icons.book)
                   itemBuilder: (context){
                     return const [
                            PopupMenuItem<int>(
                                value: 0,
                                child: Text("Update Event"),
                            ),

                            PopupMenuItem<int>(
                                value: 1,
                                child: Text("Delete Event"),
                            ),
                        ];
                   },
                   onSelected:(value){
                      if(value == 0){
                            Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => UpdateEvent(
                                communityId: communityData['communityId'].toString(),
                                eventId: eventData['eventId'].toString(),
                              ),
                            ),
                          );
                      }else if(value == 1){
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
                                        'Confirm Delete',
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
                                                  deleteEvent(
                                                    widget.communityId,
                                                    widget.eventId,
                                                  );
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
            eventData['image'],
            radius: 10,
            width: double.infinity,
            height: 200,
          ),
          const SizedBox(height: 15,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                eventData['name'],
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
          const SizedBox(height: 2,),
          Row(
            children: [
              const SizedBox(width: 5,),
              Text("from", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: gray)),
              const SizedBox(width: 5,),
              Text(communityData['name'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: black)),
            ],
          ),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule_outlined, color: pink, size: 16),
                      const SizedBox(width: 5,),
                      isUpcoming ? Text("${datediff.inHours} hours ${minutes} minutes later.", style: TextStyle(color: gray, fontSize: 12, fontWeight: FontWeight.w500),)
                        : const Text("This event is past", style: TextStyle(color: pink, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
              ],
              ),
          const SizedBox(height: 6,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset("assets/schedule.svg", color: pink, width: 16, height: 16,),
                      const SizedBox(width: 5,),
                      Text(DateFormat('HH:mm - dd/MM/yyyy, EEEE').format(eventData['date'].toDate()), style: TextStyle(color: gray, fontSize: 12, fontWeight: FontWeight.w500),),
                    ],
                  ),
              ],
              ),
          const SizedBox(height: 15,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("About Event", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: black)),
              const SizedBox(height: 10,),
              ReadMoreText(
                eventData['desc'], 
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
}