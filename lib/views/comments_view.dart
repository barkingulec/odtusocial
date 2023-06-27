import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:social/services/auth/firestore_methods.dart';

import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/enroll_button.dart';
import '../widgets/single_comment.dart';

class CommentsView extends StatefulWidget {
  final communityId;
  final eventId;
  const CommentsView({super.key, this.communityId, this.eventId});

  @override
  State<CommentsView> createState() => _CommentsViewState();
}

class _CommentsViewState extends State<CommentsView> {
  TextEditingController _commentController = TextEditingController();
  String comment = "";
  var communityData = {};
  var eventData = {};
  var userData = {};
  var comments;
  bool isLoading = false;
  int commentNumber = 0;
  String userId = "";

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    getData();
  }

@override
  void dispose() {
    super.dispose();
    _commentController.dispose();
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

      var eventSnap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('events')
          .doc(widget.eventId)
          .get();

      eventData = eventSnap.data()!;
      
      var userSnap = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(userId)
          .get();

      userData = userSnap.data()!;

      var snap = await FirebaseFirestore.instance
            .collection('communities')
            .doc(widget.communityId)
            .collection('events')
            .doc(widget.eventId)
            .collection('comments').
            get();

      comments = snap.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      commentNumber = comments.length;

      setState(() {
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  addComment() async {
    var res = "Some error occurred.";
    try {
      res = await FireStoreMethods().addCommentToEvent(
        _commentController.text,
        userData['username'],
        userData['email'],
        userData['photoUrl'],
        userData['uid'],
        widget.communityId,
        widget.eventId,
      );
      _commentController.clear();
      setState(() {
        
      });
    } catch (e) {
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: black),
      leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: black.withOpacity(.7)),
            onPressed: () => Navigator.of(context).pop(),
          ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: whiteGray.withOpacity(0),
        title: const Text(
          "Comments",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: 
          isLoading ? const Center(child: CircularProgressIndicator()) : 
          Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  Expanded(
                    child: getComments()
                  ),
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(0.0),
                        alignment: Alignment.bottomCenter,
                        child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                            filled: true,
                            fillColor: white,
                            suffixIcon: Container(
                              height: 60,
                              width: 80,
                              //color: pink.withOpacity(.8),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: pink.withOpacity(.1),
                                    spreadRadius: 1,
                                    blurRadius: 15,
                                    offset: const Offset(5, 5),
                                  ),
                                  const BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(-5,-5),
                                    blurRadius: 15,
                                    spreadRadius: 1
                                  ) ,
                                ],
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    pink.withOpacity(.03),
                                    pink.withOpacity(.09),
                                    pink.withOpacity(.21),
                                    pink.withOpacity(.39),
                                    pink.withOpacity(.63),
                                  ],
                                ),
                              ),
                              child: IconButton(
                                  icon: Icon(Icons.arrow_forward_ios_outlined, color: pink.withOpacity(.8)),
                                  onPressed: addComment,
                                ),
                            ),
                            //prefixIcon: Icon(Icons.comment, color: pink), 
                            hintText: 'Type a comment...',
                            border: OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(0.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                      ),

                      // Container(
                      // padding: const EdgeInsets.all(0),
                      // alignment: Alignment.bottomRight,
                      // child: IconButton(
                      //       onPressed: addComment,
                      //       icon: Icon(Icons.arrow_forward_ios_outlined)
                      //     ),
                      //                   ),

                      // Container(
                      // padding: const EdgeInsets.all(0),
                      // alignment: Alignment.bottomRight,
                      // child: EnrollButton(
                      //       text: 'Post',
                      //       backgroundColor: whiteGray,
                      //       textColor: pink,
                      //       borderColor: pink,
                      //       function: addComment,
                      //       height: 25,
                      //       width: 60,
                      //     )
                      //                   ),
                    ],
                  ),
                  
              
            ],
          ),
          )
      );
  }

  Widget getComments() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('communities')
            .doc(widget.communityId)
            .collection('events')
            .doc(widget.eventId)
            .collection('comments')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SmartRefresher(
            enablePullDown: true,
            enablePullUp: false,
            header: ClassicHeader(),
            footer: ClassicFooter(),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (ctx, index) => SingleComment(
                commentData: snapshot.data!.docs[index],
              ),
            ),
          );
        },
      );
  }

  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    items.add((items.length+1).toString());
    if(mounted)
    setState(() {

    });
    _refreshController.loadComplete();
  }


}