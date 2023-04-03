import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var datediff = widget.data['date'].toDate().difference(DateTime.now());
    var minutes = datediff.inMinutes % datediff.inHours;
    bool isUpcoming = datediff.inMinutes > 0;
    return isUpcoming ? GestureDetector(
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
          width: 320,
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
                  Text(widget.data["community_name"], 
                    maxLines: 1, overflow: TextOverflow.ellipsis, 
                    style: const TextStyle(color: gray, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      SvgPicture.asset("assets/profile.svg", color: pink, width: 14, height: 14,),
                      const SizedBox(width: 5),
                      forWhom(),
                    ],
                  ),

                  const SizedBox(height: 5,),
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
                      Text("${datediff.inHours} hours $minutes minutes later.", style: TextStyle(color: gray, fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis, ),
                    ],
                  )
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