import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:social/utils/utils.dart';

import '../services/auth/auth_methods.dart';
import '../utils/colors.dart';
import '../widgets/custom_image.dart';
import '../widgets/setting_box.dart';
import '../widgets/setting_item.dart';
import 'bookmarks_view.dart';
import 'edit_profile_view.dart';
import 'login_view.dart';
import 'notification_view.dart';

class ProfileView extends StatefulWidget {
  final String uid;
  const ProfileView({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  var userData = {};
  bool isLoading = false;
  var newNotifications = [];

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
          .doc(widget.uid)
          .get();

      userData = userSnap.data()!;
      newNotifications = userData["notifications_new"];
      setState(() {
        
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  void signOut() async {
    await AuthMethods().signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));      
  }
  
  // @override
  // Widget build(BuildContext context) {
  //   return isLoading ? const Center( child: CircularProgressIndicator())
  //   : Scaffold(
  //     appBar: AppBar(
  //       backgroundColor: mobileBackgroundColor,
  //             title: Text(
  //               userData['username']
  //             ),
  //             centerTitle: false,
  //     ),
  //     body: TextButton(
  //     style: ButtonStyle(
  //     foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
  //     ),
  //     onPressed: signOut,
  //     child: const Text('Logout'),
  //   ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center( child: CircularProgressIndicator())
    : CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: whiteGray,
            pinned: true,
            snap: true,
            floating: true,
            title: getHeader()
          ),
          SliverToBoxAdapter(
            child: getBody()
          )
        ],
      );
  }

  getHeader(){
    return
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("Account",
            style: TextStyle(color: black, fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ],
      );
  }

  Widget getBody() {
    return 
    SingleChildScrollView(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        children: [
          Column(
            children: [
              CustomImage(
                userData["photoUrl"]!,
                width: 70, height: 70, radius: 20,
              ),
              SizedBox(height: 10,),
              Text(userData["username"]!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
            ],
          ),
          SizedBox(height: 20,),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SettingBox(title: "Test", icon: "assets/privacy.svg",)
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: SettingBox(title: "Test", icon: "assets/privacy.svg",)
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: SettingBox(title: "Test", icon: "assets/privacy.svg",)
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: white,
              boxShadow: [
                BoxShadow(
                  color: black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                
                SettingItem(title: "Edit Profile", 
                  leadingIcon: "assets/edit_profile.svg",
                  bgIconColor: green,
                  onTap: (){
                      Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const EditProfileView(),
                            ),
                          );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 45),
                  child: Divider(height: 0, color: Colors.grey.withOpacity(0.8),),
                ),
                SettingItem(title: "Bookmarks", 
                  leadingIcon: "assets/bookmark.svg",
                  bgIconColor: pink,
                  onTap: (){
                      Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BookmarksViews(),
                            ),
                          );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 45),
                  child: Divider(height: 0, color: Colors.grey.withOpacity(0.8),),
                ),
                SettingItem(title: "Notifications", 
                  leadingIcon: "assets/notification.svg",
                  bgIconColor: orange, 
                  onTap: (){
                      Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => NotificationView(newLength: newNotifications.length,),
                            ),
                          );
                  },
                ),

              ]
            ),
          ),

          SizedBox(height: 20,),
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: white,
              boxShadow: [
                BoxShadow(
                  color: black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                SettingItem(title: "Settings", 
                  leadingIcon: "assets/settings.svg",
                  bgIconColor: blue,
                  onTap: (){
                  
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 45),
                  child: Divider(height: 0, color: Colors.grey.withOpacity(0.8),),
                ),
                SettingItem(title: "Privacy", 
                  leadingIcon: "assets/privacy.svg",
                  bgIconColor: purple,
                  onTap: (){
                  
                  },
                ),
              ]
            ),
          ),
          SizedBox(height: 20,),
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: white,
              boxShadow: [
                BoxShadow(
                  color: black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                SettingItem(title: "Log Out", 
                  leadingIcon: "assets/logout.svg",
                  bgIconColor: gray, 
                  onTap: (){
                    signOut();
                  },
                ),
              ]
            ),
          ),
        ],
      ),
    );
  }
}
