import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:social/utils/colors.dart';
import 'package:social/views/community_detail_view.dart';

import '../utils/utils.dart';
import '../views/comments_view.dart';
import '../views/event_detail_view.dart';
import '../views/post_comments_view.dart';
import '../views/post_detail_view.dart';
import '../views/profile_view.dart';
import 'custom_image.dart';

class SingleEventSearch extends StatefulWidget {
  final data;
  const SingleEventSearch({ Key? key, required this.data}) : super(key: key);

  @override
  State<SingleEventSearch> createState() => _SingleEventSearchState();

}

class _SingleEventSearchState extends State<SingleEventSearch>{
  var datediff;
  var days;
  String dateStr = "";
  var hours;
  var minutes;
  var seconds;
  bool show = false;
  var communityData = {};
  bool isLoading = false;
  bool isMember = false;
  bool isAdmin = false;
  String uid = "";
  List admins = [];
  List members = [];
  var options;

  @override
  void initState() {
    super.initState();
    getData();
    init();
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

      admins = communityData['admins'];
      members = communityData['enrolledUsers'];
      options = widget.data['for_whom'];
      uid = FirebaseAuth.instance.currentUser!.uid;
      isAdmin = admins.contains(uid); 
      isMember = members.contains(uid);

      if (admins.contains(uid)) {
          setState(() {
            show = true;
        });
      }
      else if (members.contains(uid) && options[0] != true) {
        setState(() {
            show = true;
        });
      }
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

  init() {
    datediff = DateTime.now().difference(widget.data['datePublished'].toDate());
      days = datediff.inDays;
      hours = datediff.inHours % 24;
      minutes = datediff.inMinutes % 60;
      if (days > 0 ) {
        dateStr = "$days days ago";
      }
      else if (hours > 0 ) {
        dateStr = "$hours hours ago";
      }
      else {
        dateStr = "$minutes min ago";
      }

      setState(() {
        
      });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center(child: CircularProgressIndicator()) : 
      show ? Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(0),
        width: MediaQuery.of(context).size.width,
        height: 450,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommunityDetailView(
                          communityId: widget.data['communityId'].toString(),
                        ),
                      ),
                    ).then((_) => setState(() {})),
                  child: CustomImage(
                    widget.data["community_image"],
                    radius: 23,
                    height: 46,
                    width: 46,
                  ),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommunityDetailView(
                          communityId: widget.data['communityId'].toString(),
                        ),
                      ),
                    ).then((_) => setState(() {})),
                  child: Text(widget.data["community_name"], 
                    maxLines: 1, overflow: TextOverflow.ellipsis, 
                    style: const TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.w600),),
                ),
                const SizedBox(width: 7),
                SvgPicture.asset("assets/dot.svg", color: black, width: 14, height: 14,),
                const SizedBox(width: 8),
                Text(dateStr, style: TextStyle(color: black.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),),
              ],
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EventDetailView(
                          communityId: widget.data['communityId'].toString(),
                          eventId: widget.data['eventId'].toString(),
                        ),
                      ),
                    ).then((_) => setState(() {})),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomImage(
                        widget.data['photoUrl'],
                        radius: 10,
                        width: MediaQuery.of(context).size.width - 35,
                        height: 250,
                      ),
                  ],
                ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset("assets/schedule.svg", color: pink, width: 19, height: 19,),
                              const SizedBox(width: 5,),
                              Text(DateFormat('HH:mm - dd/MM/yyyy, EEEE').format(widget.data['date'].toDate()), style: TextStyle(color: black.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),),
                            ],
                          ),
            const SizedBox(height: 10),
            Text(widget.data['name'], style: const TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.w600),),
            const SizedBox(height: 5),
            Text(widget.data['desc'], style: TextStyle(color: black.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),),
            const SizedBox(height: 7),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CommentsView(
                                  communityId: widget.data['communityId'].toString(),
                                  eventId: widget.data['eventId'].toString(),
                                ),
                              ),
                            ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset("assets/comment.svg", color: pink, width: 19, height: 19,),
                                const SizedBox(width: 5,),
                                Text('${widget.data["commentsCounter"]} Comments', style: TextStyle(color: black.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),),
                              ],
                            ),
            ),
          ],
        )
      ) : const SizedBox();
  }
}