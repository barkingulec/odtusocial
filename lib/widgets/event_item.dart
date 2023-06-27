import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../utils/colors.dart';
import '../utils/utils.dart';
import '../views/event_detail_view.dart';
import 'custom_image.dart';

class UpcomingEventItem extends StatefulWidget {
  final data;
  final userUid;
  final communityData;
  const UpcomingEventItem({super.key, required this.data, required this.userUid, required this.communityData});

  @override
  State<UpcomingEventItem> createState() => _UpcomingEventItemState();
}

class _UpcomingEventItemState extends State<UpcomingEventItem> {
  var userData = {};
  bool isLoading = false;
  bool show = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {

      var userSnap = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(widget.userUid)
          .get();

      userData = userSnap.data()!;

      var admins = widget.communityData['admins'];
      var members = widget.communityData['enrolledUsers'];
      var options = widget.data['for_whom'];
      var uid = userData['uid'];

      // if admin, show always, independent of options
      if (admins.contains(uid)) {
          setState(() {
            show = true;
        });
      }

      // if member, show if options not admin
      else if (members.contains(uid) && options[0] != true) {
        setState(() {
            show = true;
        });
      }
      
      // if not member, show only if options everyone
      else if (options[2] == true) {
        setState(() {
            show = true;
        });
      }
      else {
        setState(() {
            show = false;
        });
      }
      setState(() {
        
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = widget.data.data()['date'].toDate();
    final end = widget.data.data()['endDate'].toDate();
    
    // final whom = widget.data['for_whom'];
    // final canSee = ((whom[0] == true && isAdmin) || (whom[1] == true && isMember) || whom[2] == true);

    var datediff = start.difference(now);
    //var minutes = datediff.inMinutes % datediff.inHours;
    var days = datediff.inDays;
    var textStr = "";
    var hours = datediff.inHours % 24;
    var minutes = datediff.inMinutes % 60;
    if (days > 0) {
      textStr = "$days days $hours hours later.";
    }
    else if (hours > 0) {
      textStr = "$hours hours $minutes minutes later.";
    }
    else {
      textStr = "$minutes minutes later.";
    }

    bool isUpcoming = end.difference(now).inSeconds > 0;

    if ((end.difference(now).inSeconds > 0) && (now.difference(start).inSeconds > 0)) {
        setState(() {
          textStr = "Currently happening";
        });
      }

    return isUpcoming && show ? 

    InkWell(
      onTap: () { Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EventDetailView(
                                communityId: widget.data.data()['communityId'],
                                eventId: widget.data.data()['eventId'], 
                              ),
                            ),
                          );},
      child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: pink.withOpacity(.0),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: pink.withOpacity(.2), width: 1),
              boxShadow: [
                BoxShadow(
                  color: pink.withOpacity(.01),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(1, 1),
                )
              ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomImage(widget.data.data()['image'], radius: 10, width:70, height: 70),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.data.data()['name'], style: TextStyle(color: black, fontSize: 14, fontWeight: FontWeight.w500),),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.schedule_outlined, color: pink, size: 16),
                          SizedBox(width: 5),
                          Text(textStr, style: TextStyle(color: black.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500),),
                        ],
                      ),
                  ],),
                ),
                Icon(Icons.arrow_forward_ios, color: pink.withOpacity(.8)),
              ],
            ),
          ),
    ) : const SizedBox(height: 0);
  }
}


class PastEventItem extends StatefulWidget {
  final data;
  final userUid;
  final communityData;
  const PastEventItem({super.key, required this.data, required this.userUid, required this.communityData});

  @override
  State<PastEventItem> createState() => _PastEventItemState();
}







class _PastEventItemState extends State<PastEventItem> {
  var userData = {};
  bool isLoading = false;
  bool show = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {

      var userSnap = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(widget.userUid)
          .get();

      userData = userSnap.data()!;

      var admins = widget.communityData['admins'];
      var members = widget.communityData['enrolledUsers'];
      var options = widget.data['for_whom'];
      var uid = userData['uid'];

      // if admin, show always, independent of options
      if (admins.contains(uid)) {
          setState(() {
            show = true;
        });
      }

      // if member, show if options not admin
      else if (members.contains(uid) && options[0] != true) {
        setState(() {
            show = true;
        });
      }
      
      // if not member, show only if options everyone
      else if (options[2] == true) {
        setState(() {
            show = true;
        });
      }
      else {
        setState(() {
            show = false;
        });
      }
      setState(() {
        
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var datediff = widget.data.data()['endDate'].toDate().difference(DateTime.now());
    bool isPast = datediff.inMinutes < 0;
    return isPast && show ?
     
     InkWell(
      onTap: () { Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EventDetailView(
                                communityId: widget.data.data()['communityId'],
                                eventId: widget.data.data()['eventId'], 
                              ),
                            ),
                          );},
      child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: pink.withOpacity(.0),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: pink.withOpacity(.2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: pink.withOpacity(.01),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(1, 1),
                )
              ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomImage(widget.data.data()['image'], radius: 10, width:70, height: 70),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.data.data()['name'], style: TextStyle(color: black, fontSize: 14, fontWeight: FontWeight.w500),),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.schedule_outlined, color: pink, size: 16),
                          SizedBox(width: 5),
                          Text("This event is past", style: TextStyle(color: pink, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                  ],),
                ),
                Icon(Icons.arrow_forward_ios, color: pink.withOpacity(.8)),
              ],
            ),
          ),
    ) : const SizedBox(height: 0);
  }
}