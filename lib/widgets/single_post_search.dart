import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social/utils/colors.dart';
import 'package:social/views/community_detail_view.dart';

import '../utils/utils.dart';
import '../views/event_detail_view.dart';
import '../views/post_comments_view.dart';
import '../views/post_detail_view.dart';
import '../views/profile_view.dart';
import 'custom_image.dart';

class SinglePostSearch extends StatefulWidget {
  final data;
  const SinglePostSearch({ Key? key, required this.data}) : super(key: key);

  @override
  State<SinglePostSearch> createState() => _SinglePostSearchState();

}

class _SinglePostSearchState extends State<SinglePostSearch>{
  var datediff;
  var days;
  String dateStr = "";
  var hours;
  var minutes;
  var seconds;

  @override
  void initState() {
    super.initState();
    init();
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
    return Container(
        margin: const EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.all(0),
        width: MediaQuery.of(context).size.width,
        height: 410,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
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
            Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PostDetailView(
                          communityId: widget.data['communityId'].toString(),
                          postId: widget.data['postId'].toString(),
                        ),
                      ),
                    ).then((_) => setState(() {})),
              child: PageView.builder(
                itemCount: widget.data['photos'].length,
                pageSnapping: true,
                itemBuilder: (context,ind){
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomImage(
                        widget.data['photos'][ind],
                        radius: 10,
                        width: MediaQuery.of(context).size.width - 35,
                        height: 260,
                      ),
                      const SizedBox(height: 18,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_back_ios_new, size: 15, color: gray),
                        const SizedBox(width: 8,),
                        Text("${ind+1}", style: const TextStyle(fontSize: 18),),
                        const Text(" / ", style: TextStyle(fontSize: 18, color: darkGray),),
                        Text("${widget.data['photos'].length}", style: const TextStyle(fontSize: 18),),
                        const SizedBox(width: 8,),
                        const Icon(Icons.arrow_forward_ios_outlined, size: 15, color: gray),
                      ],
                    ),
                    
                  ],
                );
              }),
            ),
          ),
          // const SizedBox(height: 10),
          //   Text(widget.data['name'], style: const TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.w600),),
            //const SizedBox(height: 8),
            const SizedBox(width: 2,),
            Text(widget.data['desc'], style: TextStyle(color: primaryColor, fontSize: 15, fontWeight: FontWeight.w600),),
            const SizedBox(height: 9),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PostCommentsView(
                                  communityId: widget.data['communityId'].toString(),
                                  postId: widget.data['postId'].toString(),
                                ),
                              ),
                            ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 2,),
                                SvgPicture.asset("assets/comment.svg", color: pink, width: 19, height: 19,),
                                const SizedBox(width: 5,),
                                Text('${widget.data["commentsCounter"]} Comments', style: TextStyle(color: black.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),),
                              ],
                            ),
            ),
          ],
        )
      );
  }
}