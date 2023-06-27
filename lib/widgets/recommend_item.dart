import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social/utils/colors.dart';

import '../utils/utils.dart';
import '../views/event_detail_view.dart';
import 'custom_image.dart';

class RecommendItem extends StatefulWidget {
  final data;
  const RecommendItem({ Key? key, required this.data}) : super(key: key);

  @override
  State<RecommendItem> createState() => _RecommendItemState();

}

class _RecommendItemState extends State<RecommendItem>{
  var communityData = {};
  bool isLoading = false;
  bool isMember = false;
  bool isAdmin = false;

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

      var communitySnap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.data['communityId'])
          .get();

      communityData = communitySnap.data()!;

      isMember = communityData['enrolledUsers'].contains(FirebaseAuth.instance.currentUser!.uid);
      isAdmin = communityData['admins'].contains(FirebaseAuth.instance.currentUser!.uid);

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
    final start = widget.data['date'].toDate();
    final end = widget.data['endDate'].toDate();
    final whom = widget.data['for_whom'];
    final canSee = ((whom[0] == true && isAdmin) || (whom[1] == true && isMember) || whom[2] == true);
    
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

    return isLoading ? const Center(child: CircularProgressIndicator()) 
      : isUpcoming && canSee ? GestureDetector(
      onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EventDetailView(
                          communityId: widget.data['communityId'].toString(),
                          eventId: widget.data['eventId'].toString(),
                        ),
                      ),
                    ).then((_) => setState(() {})),
      child: Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.all(10),
          width: 360,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(1, 1), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            children: [
              CustomImage(widget.data["image"],
                radius: 15,
                height: 80,
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.data["name"], 
                    maxLines: 1, overflow: TextOverflow.ellipsis, 
                    style: const TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5,),
                  Text(communityData["name"], 
                    maxLines: 1, overflow: TextOverflow.ellipsis, 
                    style: TextStyle(color: black.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      // Icon(Icons.schedule_rounded, color: labelColor, size: 14,), 
                      // SizedBox(width: 2,),
                      // SizedBox(width: 20,),
                      // Icon(Icons.star, color: orange, size: 14,), 
                      // SizedBox(width: 2,),
                      // Text(data["review"], style: TextStyle(fontSize: 12, color: labelColor),),
                      Icon(Icons.schedule_outlined, color: pink, size: 14),
                      SizedBox(width: 5),
                      Text(textStr, style: TextStyle(color: black.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis, ),
                    ],
                  ),
                  const SizedBox(height: 5,),
                  Row(
                    children: [
                      SvgPicture.asset("assets/profile.svg", color: pink, width: 14, height: 14,),
                      const SizedBox(width: 5),
                      forWhom(),
                    ],
                  ),
                ],
              )
            ],
          )
        ),
    ) : const SizedBox();
  }

  forWhom() {
    if (widget.data['for_whom'][0] == true) {
      return const Text("Admins only", style: TextStyle(fontSize: 12, color: pink), overflow: TextOverflow.ellipsis,);
    }
    else if (widget.data['for_whom'][1] == true) {
      return const Text("Members only", style: TextStyle(fontSize: 12, color: pink), overflow: TextOverflow.ellipsis,);
    }
    else {
      return const Text("For everyone", style: TextStyle(fontSize: 12, color: pink), overflow: TextOverflow.ellipsis,);
    }
  }

}