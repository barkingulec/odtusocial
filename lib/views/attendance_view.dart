import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/single_attendance.dart';

class AttendanceView extends StatefulWidget {
  final communityId;
  final eventId;
  const AttendanceView({super.key, required this.communityId, required this.eventId});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  var eventData = {};
  var communityData = {};
  var members = [];
  var sortedMembers = [];
  var attendedMembers = [];
  bool isLoading = false;
  String count = "";

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

      var eventSnap = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('events')
          .doc(widget.eventId)
          .get();

      eventData = eventSnap.data()!;

      members = communitySnap.data()!['enrolledUsers'];
      attendedMembers = eventSnap.data()!['attendedUsers'];

      var attendedCount = attendedMembers.length.toString();
      var membersCount = members.length.toString();

      count = "$attendedCount / $membersCount";

      for (String member in attendedMembers) {
        sortedMembers.add(member);
      }
      for (Map hs in communityData['roles']) {
          for (String key in hs.keys) {
            if (!sortedMembers.contains(key)) {
              sortedMembers.add(key);
            }
        }
      }
      for (String member in members) {
        if (!sortedMembers.contains(member)) {
          sortedMembers.add(member);
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
          "[ ${eventData['code']} ] Attendance: $count",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
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
                return SingleAttendance(uid: sortedMembers[index], communityId: widget.communityId, eventId: widget.eventId);
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