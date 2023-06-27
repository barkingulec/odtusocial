import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:social/widgets/single_request.dart';

import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/custom_image.dart';
import '../widgets/enroll_button.dart';
import '../widgets/single_add_admin.dart';
import '../widgets/single_admin.dart';
import 'add_admin_view.dart';
import 'edit_community.dart';

class AdminsView extends StatefulWidget {
  final communityId;
  const AdminsView({super.key, this.communityId});

  @override
  State<AdminsView> createState() => _AdminsViewState();
}

class _AdminsViewState extends State<AdminsView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var communityData = {};
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  bool _nameValid = true;
  bool _bioValid = true;
  var communityRef;

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

      communityRef = FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId);

      setState(() {
        nameController = TextEditingController(text: communityData['name']);
        bioController = TextEditingController(text: communityData['desc']);
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  addAdmin() {
    Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddAdminView(
                                communityId: communityData['communityId'].toString(),
                              ),
                            ),
                          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
          "Admins",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: 
          isLoading ? const Center(child: CircularProgressIndicator()) : 
          Container(
          child: Stack(
            children: [
              ListView.builder(
                itemCount: null == communityData['admins'] ? 0 : communityData['admins'].length,
                itemBuilder: (context, index) {
                  return SingleAdmin(uid: communityData['admins'][index], communityId: widget.communityId);
                },
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
                alignment: Alignment.bottomCenter,
                // child: ElevatedButton(
                //           child: Text(
                //             "Add Admin",
                //             style: TextStyle(
                //               color: white,
                //               fontSize: 18.0,
                //             ),
                //           ),
                //           onPressed: () { 
                //             Navigator.of(context).push(
                //             MaterialPageRoute(
                //               builder: (context) => AddAdminView(
                //                 communityId: communityData['communityId'].toString(),
                //               ),
                //             ),
                //           ).then((_) => setState(() {})).then((_) => setState(() {}));
                //           },
                //           style: ButtonStyle(
                //             backgroundColor: MaterialStateProperty.all(pink),)
                //             ),
                child: EnrollButton(
                      text: 'Add Admin',
                      backgroundColor: Colors.white,
                      textColor: pink,
                      borderColor: pink,
                      function: () { 
                            Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddAdminView(
                                communityId: communityData['communityId'].toString(),
                              ),
                            ),
                          ).then((_) => setState(() {})).then((_) => setState(() {}));
                          },
                      height: 30,
                      width: 120,
                    )
              )
            ],
          ),
          )
    );
  }
}