import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social/utils/colors.dart';

import '../utils/utils.dart';
import '../views/event_detail_view.dart';
import '../views/profile_view.dart';
import 'custom_image.dart';

class SingleUserSearch extends StatefulWidget {
  final data;
  const SingleUserSearch({ Key? key, required this.data}) : super(key: key);

  @override
  State<SingleUserSearch> createState() => _SingleUserSearchState();

}

class _SingleUserSearchState extends State<SingleUserSearch>{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String fullName = (widget.data["firstName"] + " " + widget.data['lastName']);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileView(
                          uid: widget.data['uid'].toString(),
                        ),
                      ),
                    ).then((_) => setState(() {})),
      child: Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.all(10),
          width: 360,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.transparent,
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.grey.withOpacity(0.1),
            //     spreadRadius: 1,
            //     blurRadius: 1,
            //     offset: const Offset(1, 1), // changes position of shadow
            //   ),
            // ],
          ),
          child: Row(
            children: [
              CustomImage(widget.data["photoUrl"],
                radius: 27,
                height: 54,
                width: 54,
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  !widget.data["username"].isEmpty ? Text(widget.data["username"], 
                    maxLines: 1, overflow: TextOverflow.ellipsis, 
                    style: const TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.w600),
                  ) : const SizedBox(),
                  !widget.data["username"].isEmpty ? const SizedBox(height: 5,) : const SizedBox(),
                  fullName.trim().isNotEmpty ? Text(fullName, 
                    maxLines: 1, overflow: TextOverflow.ellipsis, 
                    style: TextStyle(color: black.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w600),
                  ) : const SizedBox(),
                  fullName.trim().isNotEmpty ? const SizedBox(height: 8,) : const SizedBox(),
                  // !widget.data['bio'].isEmpty ? Row(
                  //   children: [
                  //     SvgPicture.asset("assets/profile.svg", color: pink, width: 14, height: 14,),
                  //     SizedBox(width: 5),
                  //     Text(widget.data['bio'], style: TextStyle(color: black.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis, ),
                  //   ],
                  // ) : const SizedBox(),
                ],
              )
            ],
          )
        ),
    );
  }
}