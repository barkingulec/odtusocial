import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/colors.dart';
import '../utils/utils.dart';
import '../views/post_detail_view.dart';
import 'custom_image.dart';

class SinglePost extends StatefulWidget {
  final postData;
  final userId;
  final communityData;
  const SinglePost({super.key, this.postData, this.userId, this.communityData});

  @override
  State<SinglePost> createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {
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
          .doc(widget.userId)
          .get();

      userData = userSnap.data()!;
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
    return InkWell(
      onTap: () { Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PostDetailView(
                                communityId: widget.postData.data()['communityId'],
                                postId: widget.postData.data()['postId'], 
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
                CustomImage(widget.postData.data()['image'], radius: 10, width:70, height: 70),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.postData.data()['name'], style: TextStyle(color: black, fontSize: 14, fontWeight: FontWeight.w500),),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          SvgPicture.asset("assets/dot.svg", color: pink.withOpacity(.6), width: 16, height: 16,),
                          SizedBox(width: 1),
                          Text(widget.postData.data()['desc'], style: TextStyle(color: black.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500),),
                        ],
                      ),
                  ],),
                ),
                Icon(Icons.arrow_forward_ios, color: pink.withOpacity(.8)),
              ],
            ),
          ),
    );
  }
}
