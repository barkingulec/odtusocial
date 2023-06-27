import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social/utils/colors.dart';

import '../utils/utils.dart';
import '../views/community_detail_view.dart';
import 'custom_image.dart';


class CourseItem extends StatefulWidget {
  const CourseItem({ Key? key, required this.data, this.width = 280, this.height = 290}) : super(key: key);
  final data;
  final double width;
  final double height;

  @override
  State<CourseItem> createState() => _CourseItem();
}

class _CourseItem extends State<CourseItem> {
  int membersNumber = 0;
  int eventsNumber = 0;

  @override
  void initState() {
    super.initState();
    memberCount();
    membersNumber = widget.data["enrolledUsers"].length;
  }

  memberCount() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.data['communityId'])
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

  @override
  Widget build(BuildContext context) {
    return 
      GestureDetector(
        onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommunityDetailView(
                          communityId: widget.data['communityId'].toString(),
                        ),
                      ),
                    ),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 5, top: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(1, 1), // changes position of shadow
              ),
            ],
          ),
          child: Stack(
            children: [
              CustomImage(widget.data["image"],
                width: double.infinity, height: 190,
                radius: 15,
              ),
              Positioned(
                top: 170, right: 15,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: pink.withOpacity(.85),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/schedule.svg", color: white, width: 20, height: 20,),
                      const SizedBox(width: 5,),
                      Text("$eventsNumber Upcoming Event",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 210,
                child: Container(
                  width: widget.width - 20,
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.data["name"], maxLines: 1, overflow: TextOverflow.ellipsis, 
                        style: const TextStyle(fontSize: 17, color: primaryColor, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Row(
                              children: [
                                SvgPicture.asset("assets/profile.svg", color: pink, width: 18, height: 18,),
                                const SizedBox(width: 3,),
                                Text("$membersNumber Members", maxLines: 1, overflow: TextOverflow.ellipsis, 
                                  style: const TextStyle(color: primaryColor, fontSize: 13),
                                ),
                              ],
                            ),
                           const SizedBox(width: 12,),
                          // getAttribute(Icons.schedule_rounded, primaryColor, data["duration"]),
                          // SizedBox(width: 12,),
                          // getAttribute(Icons.star, primaryColor, data["review"]),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
  }
}