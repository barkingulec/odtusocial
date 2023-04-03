import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/single_request.dart';

class RequestsView extends StatefulWidget {
  final communityId;
  const RequestsView({Key? key, required this.communityId}) : super(key: key);

  @override
  State<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends State<RequestsView> {
  var communityData = {};
  bool isLoading = false;


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
          backgroundColor: whiteGray,
          iconTheme: const IconThemeData(color: black),
          title: const Text(
            "Requests",
            style: TextStyle(color: black),),
          ),
        body: Container(
          child: ListView.builder(
            itemCount: null == communityData['requests'] ? 0 : communityData['requests'].length,
            itemBuilder: (context, index) {
              return SingleRequest(uid: communityData['requests'][index], communityId: widget.communityId);
            },
          ),
          ),
        );
  }
}