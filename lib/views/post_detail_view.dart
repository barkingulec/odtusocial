import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:social/views/post_comments_view.dart';
import 'package:social/views/update_post.dart';

import '../services/auth/firestore_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/custom_image.dart';
import '../widgets/enroll_button.dart';
import 'comments_view.dart';
import 'community_detail_view.dart';

class PostDetailView extends StatefulWidget {
  final communityId;
  final postId;
  const PostDetailView({super.key, required this.communityId, required this.postId});

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  var communityData = {};
  var postData = {};
  bool isLoading = false;
  int commentsLen = 0;
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
          .doc(widget.communityId)
          .get();

      communityData = communitySnap.data()!;

      var postSnap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('posts')
          .doc(widget.postId)
          .get();

      postData = postSnap.data()!;
      commentsLen = postData['commentsCounter'];

      isAdmin = communitySnap
          .data()!['admins']
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

  deletePost() async {
    try {
      await FireStoreMethods().deletePost(widget.communityId, widget.postId);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
      Navigator.pop(context);
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
        "Post Detail", 
        style: TextStyle(color: black),
      ),
      actions: isAdmin ? [
                 
                 PopupMenuButton(
                   // add icon, by default "3 dot" icon
                   icon: SvgPicture.asset("assets/details.svg", color: black.withOpacity(.7), width: 25, height: 25,),
                   itemBuilder: (context){
                     return const [
                            PopupMenuItem<int>(
                                value: 0,
                                child: Text("Update Post"),
                            ),

                            PopupMenuItem<int>(
                                value: 1,
                                child: Text("Delete Post"),
                            ),
                        ];
                   },
                   onSelected:(value){
                      if(value == 0){
                            Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => UpdatePost(
                                communityId: communityData['communityId'].toString(),
                                postId: postData['postId'].toString(),
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
                                                  title: Text('Delete the Post'),
                                                  content: Text("Are you sure you really want to delete the post?"),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: deletePost,
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
      iconTheme: const IconThemeData(color: black),
      leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: black.withOpacity(.7)),
            onPressed: () => Navigator.of(context).pop(),
          ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: whiteGray.withOpacity(0),
    );
  }

  Widget buildBody() {
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          //stops: [0, 1],
                          colors: [
                            // pink.withOpacity(.06), 
                            // pink.withOpacity(.45),
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
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: PageView.builder(
                  itemCount: postData['photos'].length,
                  pageSnapping: true,
                  itemBuilder: (context,ind){
                  return Column(
                    children: [
                      CustomImage(
                          postData['photos'][ind],
                          radius: 10,
                          width: MediaQuery.of(context).size.width - 80,
                          height: 240,
                        ),
                        const SizedBox(height: 18,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_back_ios_new, size: 15, color: gray),
                          const SizedBox(width: 8,),
                          Text("${ind+1}", style: const TextStyle(fontSize: 18),),
                          const Text(" / ", style: TextStyle(fontSize: 18, color: darkGray),),
                          Text("${postData['photos'].length}", style: const TextStyle(fontSize: 18),),
                          const SizedBox(width: 8,),
                          const Icon(Icons.arrow_forward_ios_outlined, size: 15, color: gray),
                        ],
                      ),
                    ],
                  );
                }),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 5),
                        Text(
                          postData['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: black,
                          ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10,),
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
                                SvgPicture.asset("assets/schedule.svg", color: pink, width: 19, height: 19,),
                                const SizedBox(width: 5,),
                                Text(DateFormat('HH:mm - dd/MM/yyyy, EEEE').format(postData['datePublished'].toDate()), style: TextStyle(color: black.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500),),
                              ],
                            ),
                        ],
                        ),
                      const SizedBox(height: 8,),
                      Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PostCommentsView(
                                    communityId: communityData['communityId'].toString(),
                                    postId: postData['postId'].toString(),
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
                        ),
                    const SizedBox(height: 16,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("About Post", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: black)),
                        const SizedBox(height: 10,),
                          ReadMoreText(
                            postData['desc'], 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: black.withOpacity(0.7)),
                            trimLines: 2,
                            trimMode: TrimMode.Line,
                            trimCollapsedText: "Show more",
                            moreStyle: const TextStyle(fontSize: 16, color: pink),
                            lessStyle: const TextStyle(fontSize: 16, color: pink),
                            ), 
                    
                    ],),
                    const SizedBox(height: 20,),
                  ],
                ),
              ),
          //        getTabBar(),
          //        getTabBarPages(),
            ],
          ),
        )
      ),
    );
  }
}