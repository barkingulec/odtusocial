import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/single_chat_group_member.dart';
import '../widgets/single_member.dart';
import 'add_group_member.dart';

class ChatGroupMembers extends StatefulWidget {
  final communityGroupId;
  final communityId;
  const ChatGroupMembers({super.key, this.communityGroupId, this.communityId});

  @override
  State<ChatGroupMembers> createState() => _ChatGroupMembersState();
}

class _ChatGroupMembersState extends State<ChatGroupMembers> {
  var communityGroupData = {};
  var members = [];
  var admins = [];
  var sortedMembers = [];
  bool isLoading = false;
  bool isDefault = false;
  String? curUserId;

  @override
  void initState() {
    super.initState();
    curUserId = FirebaseAuth.instance.currentUser!.uid;
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
          .collection('messagesGroups')
          .doc(widget.communityGroupId)
          .get();

      communityGroupData = communitySnap.data()!;

      members = communitySnap.data()!['members'];
      admins = communitySnap.data()!['admins'];
      isDefault = communitySnap.data()!['isDefault'];

      for (String memberId in admins) {
        sortedMembers.add(memberId);
      }
      for (String memberId in members) {
        if (!sortedMembers.contains(memberId)) {
          sortedMembers.add(memberId);
        }
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
    return isLoading ? const Center( child: CircularProgressIndicator() )
      : Scaffold(
        appBar: AppBar(
        iconTheme: const IconThemeData(color: black),
      leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: black.withOpacity(.7)),
            onPressed: () => Navigator.of(context).pop(),
          ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: whiteGray.withOpacity(0),
        title: Text(
          "Members",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      actions: admins.contains(curUserId) && !isDefault ? <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddGroupMember(
                          communityId: widget.communityId,
                          communityGroupId: widget.communityGroupId,
                          curUserId: curUserId,
                        ),
                      ),
                    ),
        )
      ] : [],
      ),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: ClassicHeader(),
          footer: ClassicFooter(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: ListView.builder(
              itemCount: sortedMembers.length,
              itemBuilder: (context, index) {
                return SingleChatGroupMember(uid: sortedMembers[index], communityId: widget.communityId, communityGroupId: widget.communityGroupId);
              },
            ),
        ),
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