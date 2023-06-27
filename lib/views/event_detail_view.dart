import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:social/views/requests_view.dart';
import 'package:social/views/update_event.dart';
import 'package:social/widgets/custom_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth/firestore_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/add_event.dart';
import '../widgets/enroll_button.dart';
import '../widgets/event_item.dart';
import 'attendance_view.dart';
import 'comments_view.dart';
import 'community_detail_view.dart';

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
  var eventRef;
  var datediff;
  var days;
  String daysStr = "";
  String hoursStr = "";
  var hours;
  var minutes;
  var seconds;
  bool isLoading = false;
  bool isRequested = false;
  bool isMember = false;
  bool isAdmin = false;
  bool isAttended = false;
  //bool isBookmarked= false;
  int members = 0;
  int eventsNumber = 0;
  bool isUpcoming = false;
  bool inDuration = false;
  late TabController tabController;
  int commentsLen = 0;
  var durationHours;
  var durationMinutes;
  String durationMinutesText = "";
  String? curUserId;
  TextEditingController codeController = TextEditingController();
  String type = "";
  String attendedWith = "";
  
  double res = 0;

  @override
  void initState() {
    super.initState();
    getData();
    fetchEventLen();
    curUserId = FirebaseAuth.instance.currentUser!.uid;
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

      eventRef = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('events')
          .doc(widget.eventId);

      var eventSnap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('events')
          .doc(widget.eventId)
          .get();

      eventData = eventSnap.data()!;
      
      isAttended = eventData['attendedUsers'].contains(curUserId);
      datediff = eventData['date'].toDate().difference(DateTime.now());
      //minutes = datediff.inMinutes % datediff.inHours;
      days = datediff.inDays;
      if (days > 0 ) {
        daysStr = "$days days ";
      }
      hours = datediff.inHours % 24;
      if (hours > 0 ) {
        hoursStr = "$hours hours ";
      }
      minutes = datediff.inMinutes % 60;
      seconds = datediff.inSeconds % 60;
      isUpcoming = datediff.inSeconds > 0;

      final now = DateTime.now();
      final start = eventData['date'].toDate();
      final end = eventData['endDate'].toDate();

      var diff = end.difference(start);
      durationHours = diff.inHours;
      durationMinutes = diff.inMinutes % 60;
      if (durationMinutes > 0) {
        durationMinutesText = "$durationMinutes minutes";
      }

      if ((end.difference(now).inSeconds > 0) && (now.difference(start).inSeconds > 0)) {
        setState(() {
          inDuration = true;
        });
      }

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
      // isBookmarked = communitySnap
      //     .data()!['bookmarkedUsers']
      //     .contains(FirebaseAuth.instance.currentUser!.uid);

      commentsLen = eventData['commentsCounter'];
      type = eventData['attendanceType'];

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

  deleteEvent() async {
    try {
      await FireStoreMethods().deleteEvent(widget.communityId, widget.eventId);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
      Navigator.pop(context);
    }
  }

  addToCalender() {
      Event event = Event(
          title: eventData['name'],
          description: eventData['desc'],
          location: eventData['community_name'],
          startDate: eventData['date'].toDate(),
          endDate: eventData['endDate'].toDate(),
          allDay: false,
          // iosParams: IOSParams( 
          //   reminder: Duration(/* Ex. hours:1 */), // on iOS, you can set alarm notification after your event.
          // ),
          androidParams: AndroidParams( 
            emailInvites: [""], // on Android, you can add invite emails to your event.
          ),
        );
      Add2Calendar.addEvent2Cal(event,);
  }

 openMap() async {
   GeoPoint position = eventData['location'];
   final lat = position.latitude;
   final lng = position.longitude;

   Uri uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    await launchUrl(uri);
}

openOnlineLink() async {
  final eventLink = eventData['eventLink'];
  Uri uri = Uri.parse(eventLink);
  await launchUrl(uri);
}

  Future<double> calculateDistance() async {
    try {

      AndroidIntent intent = const AndroidIntent(
        action: 'action_location_source_settings',
      );
      await intent.launch();

      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
      }

    Position position = await Geolocator.getCurrentPosition(forceAndroidLocationManager: true, desiredAccuracy: LocationAccuracy.best);//get user's current location

    double startLatitude = 39.89171561144314;
    double startLongitude = 32.78581707629186;
    double endLatitude = position.latitude;
    double endLongitude = position.longitude;

    double distanceInMeters = Geolocator.distanceBetween(startLatitude,startLongitude, endLatitude, endLongitude);
    res = distanceInMeters;
    //res = distanceInMeters * 0.000621371192;//convert meters into miles.
    print("dist: $distanceInMeters");
    return distanceInMeters;
  } catch (e) {
    return Future.error(e);
  }
}

handleAttendance() async {
  double distance = await calculateDistance();
  setState(() {
      res = distance;
      print("res: $res");
    });
}

addToAttended() async {
  await FireStoreMethods().addParticipation(curUserId, widget.communityId, widget.eventId, attendedWith);
  eventRef.update({
        "attendedUsers": FieldValue.arrayUnion([curUserId]),
      });
  setState(() {
    isAttended = true;
  });
}

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
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
      centerTitle: true,
      actions: isAdmin ? [
                 
                 PopupMenuButton(
                   // add icon, by default "3 dot" icon
                   icon: SvgPicture.asset("assets/details.svg", color: black.withOpacity(.7), width: 25, height: 25,),
                   itemBuilder: (context){
                     return const [
                            PopupMenuItem<int>(
                                value: 2,
                                child: Text("Attendance"),
                            ),

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
                    if(value == 2){
                            Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AttendanceView(
                                communityId: communityData['communityId'].toString(),
                                eventId: eventData['eventId'].toString(),
                              ),
                            ),
                          );
                      }
                      else if(value == 0){
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
                                            showDialog<String>(
                                                context: context,
                                                builder: (BuildContext context) => AlertDialog(
                                                  title: Text('Delete the Event'),
                                                  content: Text("Are you sure you really want to delete the event?"),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: deleteEvent,
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                          },
                                                // onTap: () {
                                                //   deleteEvent(
                                                //     widget.communityId,
                                                //     widget.eventId,
                                                //   );
                                                //   // remove the dialog box
                                                //   Navigator.of(context).pop();
                                                //   Navigator.of(context).pop();
                                                // }
                                                ),
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
      leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: black.withOpacity(.7)),
            onPressed: () => Navigator.of(context).pop(),
          ),
      iconTheme: IconThemeData(color: black.withOpacity(.7)),
      backgroundColor: whiteGray.withOpacity(0),
      elevation: 0,
    );
  }

  Widget buildBody() {
    return isLoading ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 10),
          Text("It may take few seconds."),
        ],
      ),
    ) : Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
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
              eventData['image'],
              radius: 10,
              width: double.infinity,
              height: 200,
            ),
            const SizedBox(height: 10,),
            !inDuration ? const SizedBox() :
            isAttended ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("You already attended to this event.")
              ]
            )
            : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (type == "Location based") | (type == "Location and code based")  ? TextButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        double dist = await calculateDistance();
                        if (dist < 1000) {
                          setState(() {
                            attendedWith = "Location";
                          });
                          addToAttended();
                        }
                        showDialog<String>(
                                                    context: context,
                                                    builder: (BuildContext context) => AlertDialog(
                                                      title: dist < 1000 ? const Text('Successful') : const Text('Failed'),
                                                      content: dist < 1000 ? Text("Your attendance is successfully taken. $dist")
                                                                  : Text("Your attendance could not be taken. Please try again from event location. $dist"),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context, 'OK'),
                                                          child: const Text('OK'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: Text("Give Location Attendance"),
                    ) : const SizedBox(),

                    const SizedBox(width: 10,),

                    (type == "Code based") | (type == "Location and code based") ? TextButton(
                      onPressed: () async {
                        showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Code Attendance'),
                                  content: TextField(
                                    controller: codeController,
                                    decoration: InputDecoration(
                                      hintText: "Enter the four digit attendance code provided by admins.",
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        if (int.parse(codeController.text) == eventData['code']) {
                                          setState(() {
                                            attendedWith = "Code";
                                          });
                                          addToAttended();
                                          showSnackBar(context, "Successfully attended.");
                                        }
                                        else {
                                          showSnackBar(context, "Code is wrong. Please try again.");
                                        }
                                        Navigator.pop(context, "OK");
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                      },
                      child: Text("Give Code Attendance"),
                    ) : const SizedBox(),
                  ],
                ),
            const SizedBox(height: 2,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  eventData['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: black,
                  ),
                  ),
                IconButton(
                  onPressed: addToCalender,
                  icon: const Icon(Icons.edit_calendar, color: pink, size: 25)
                  //SvgPicture.asset("assets/bookmark.svg", color: pink, width: 25, height: 25,),
                  ),
              ],
            ),
                
            const SizedBox(height: 2,),
            Row(
              children: [
                const SizedBox(width: 5,),
                Text("From", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: gray)),
                const SizedBox(width: 5,),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommunityDetailView(
                            communityId: communityData['communityId'].toString(),
                          ),
                        ),
                      ),
                  child: Text(communityData['name'], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: black))
                  ),
              ],
            ),
            const SizedBox(height: 12,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule_outlined, color: pink, size: 18),
                        const SizedBox(width: 5,),
                        isUpcoming ? Text("$daysStr$hoursStr$minutes minutes later.", style: TextStyle(color: black.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500),)
                          : inDuration ? const Text("Currently happening.", style: TextStyle(color: pink, fontSize: 14, fontWeight: FontWeight.w500)) 
                          : const Text("This event is past.", style: TextStyle(color: pink, fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                ],
                ),
            const SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset("assets/schedule.svg", color: pink, width: 19, height: 19,),
                        const SizedBox(width: 5,),
                        Text(DateFormat('HH:mm - dd/MM/yyyy, EEEE').format(eventData['date'].toDate()), style: TextStyle(color: black.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500),),
                      ],
                    ),
                ],
                ),
            const SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule_outlined, color: pink, size: 18),
                        const SizedBox(width: 5,),
                        Text("$durationHours hours $durationMinutesText", style: TextStyle(color: black.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500),)
                      ],
                    ),
                ],
                ),
            const SizedBox(height: 8,),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset("assets/profile.svg", color: pink, width: 19, height: 19,),
                    const SizedBox(width: 5,),
                    forWhom(),
                ],
                ),

              const SizedBox(height: 8,),


            ((eventData['for_whom'][0] == true && isAdmin) || (eventData['for_whom'][1] == true && isMember) || eventData['for_whom'][2] == true)
             ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommentsView(
                            communityId: communityData['communityId'].toString(),
                            eventId: eventData['eventId'].toString(),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset("assets/comment.svg", color: pink, width: 21, height: 21,),
                          const SizedBox(width: 5,),
                          Text("Comments ($commentsLen)", style: TextStyle(color: pink, fontSize: 14, fontWeight: FontWeight.w500),),
                        ],
                      ),
                    ),
                ],
                ) : SizedBox(),
            const SizedBox(height: 8,),

                          eventData['isOnline'] ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset("assets/location-online.svg", color: pink, width: 19, height: 19,),
                    const SizedBox(width: 5,),
                    TextButton(
                      onPressed: openOnlineLink,
                      child: Text(
                        "Meeting Link", 
                        style: TextStyle(color: black.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                ],
                )
                : Row(
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
                
              const SizedBox(height: 8,),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("About Event", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: black)),
                const SizedBox(height: 10,),
                if ((eventData['for_whom'][0] == true && isAdmin) || (eventData['for_whom'][1] == true && isMember) || eventData['for_whom'][2] == true) 
                  ReadMoreText(
                    eventData['desc'], 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: black.withOpacity(0.7)),
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: "Show more",
                    moreStyle: const TextStyle(fontSize: 16, color: pink),
                    lessStyle: const TextStyle(fontSize: 16, color: pink),
                    ), 
                 if (eventData['for_whom'][0] == true && !isAdmin) Center(child: Text("Only admins can see event details.", style: TextStyle(color: pink, fontSize: 17),)),
                 if (eventData['for_whom'][1] == true && !isMember) Center(child: Text("Only members can see event details.", style: TextStyle(color: pink, fontSize: 17),)),
                
    
            ],),
            const SizedBox(height: 20,),
      //        getTabBar(),
      //        getTabBarPages(),
          ],
        )
      ),
    );
  }

  forWhom() {
    if (eventData['for_whom'][0] == true) {
      return Text("Admins only", style: TextStyle(fontSize: 14, color: black.withOpacity(0.7), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis,);
    }
    else if (eventData['for_whom'][1] == true) {
      return Text("Members only", style: TextStyle(fontSize: 14, color: black.withOpacity(0.7), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis,);
    }
    else {
      return Text("For everyone", style: TextStyle(fontSize: 14, color: black.withOpacity(0.7), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis,);
    }
  }

  // Widget getTabBar() {
  //   return Container(
  //     child: TabBar(
  //       controller: tabController,
  //       tabs: [
  //       Tab(child: Text("Upcoming Events", style: TextStyle(fontSize: 16, color: black),),),
  //       Tab(child: Text("Past Events", style: TextStyle(fontSize: 16, color: black)),)
  //     ],),
  //   );
  // }
  // Widget getTabBarPages() {
  //   return Container(
  //     height: 200,
  //     width: double.infinity,
  //     child: TabBarView(
  //       // physics: NeverScrollableScrollPhysics(),
  //       controller: tabController,
  //       children: [
  //         getUpcomingEvents(),
  //         getPastEvents(),
  //     ],
  //     ),
  //   );
  // }
  // Widget getUpcomingEvents() {
  //   return StreamBuilder(
  //       stream: FirebaseFirestore.instance
  //           .collection('communities')
  //           .doc(communityData["communityId"])
  //           .collection('events')
  //           .snapshots(),
  //       builder: (context,
  //           AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(
  //             child: CircularProgressIndicator(),
  //           );
  //         }

  //         return ListView.builder(
  //           itemCount: snapshot.data!.docs.length,
  //           itemBuilder: (ctx, index) => UpcomingEventItem(
  //             data: snapshot.data!.docs[index],
  //           ),
  //         );
  //       },
  //     );
  // }

  // Widget getPastEvents() {
  //   return StreamBuilder(
  //       stream: FirebaseFirestore.instance
  //           .collection('communities')
  //           .doc(communityData["communityId"])
  //           .collection('events')
  //           .snapshots(),
  //       builder: (context,
  //           AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(
  //             child: CircularProgressIndicator(),
  //           );
  //         }

  //         return ListView.builder(
  //           itemCount: snapshot.data!.docs.length,
  //           itemBuilder: (ctx, index) => PastEventItem(
  //             data: snapshot.data!.docs[index],
  //           ),
  //         );
  //       },
  //     );
  // }

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