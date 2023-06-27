import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:store_redirect/store_redirect.dart';

import '../services/auth/auth_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/create_community.dart';
import '../widgets/custom_image.dart';
import '../widgets/enroll_button.dart';
import '../widgets/setting_item.dart';
import 'add_community_view.dart';
import 'bookmarks_view.dart';
import 'contact_view.dart';
import 'edit_profile_view.dart';
import 'login_view.dart';
import 'notification_view.dart';

class SettingsView extends StatefulWidget {
  final userId;
  const SettingsView({super.key, this.userId});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  var userData = {};
  var newNotifications = [];
  bool isLoading = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userUid = ""; 

  @override
  void initState() {
    final User? curUser = auth.currentUser;
    userUid = curUser!.uid;
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
  
  Future resetPassword() async {
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(),));
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: userData['email']);
      showSnackBar(context, "Password reset email is sent.");
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      showSnackBar(context, e.toString());
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center(child: CircularProgressIndicator())  : Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(
                                          color: pink.withOpacity(.7),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: pink.withOpacity(.7)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
        iconTheme: IconThemeData(color: pink.withOpacity(.7)),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Container(
        child: Stack(
          alignment: Alignment.topCenter,
          //overflow: Overflow.visible,
          children: <Widget>[
            Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          //stops: [0, 1],
                          colors: [
                            // pink.withOpacity(.06), 
                            // pink.withOpacity(.45),
                            pink.withOpacity(.0),
                            pink.withOpacity(.03),
                            pink.withOpacity(.06),
                            pink.withOpacity(.09),
                            pink.withOpacity(.12),
                            pink.withOpacity(.15),
                          ],
                        )
                      ),
                    margin: EdgeInsets.only(top: 0),
                    child: getBody(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getBody() {
    return 
    SingleChildScrollView(
      padding: EdgeInsets.only(top: 150, left: 15, right: 15),
      child: Column(
        children: [
          SizedBox(height: 20,),
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
              border: Border.all(color: pink.withOpacity(.4)),
              borderRadius: BorderRadius.circular(25),
              color: pink.withOpacity(0.04),
              // boxShadow: [
              //   BoxShadow(
              //     color: black.withOpacity(0.2),
              //     spreadRadius: 1,
              //     blurRadius: 1,
              //     offset: Offset(0, 1), // changes position of shadow
              //   ),
              //],
            ),
            child: Column(
              children: [
                SettingItem(title: "Edit Profile", 
                  leadingIcon: "assets/edit_profile.svg",
                  leadingIconColor: pink,
                  bgIconColor: Colors.transparent,
                  //boxBackgroundColor: pink.withOpacity(0.12),
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
                  child: Divider(height: 2, color: pink,),
                ),
                SettingItem(title: "Bookmarks", 
                  leadingIcon: "assets/bookmark.svg",
                  leadingIconColor: pink,
                  bgIconColor: Colors.transparent,
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
                  child: Divider(height: 2, color: pink),
                ),
                SettingItem(title: "Notifications", 
                  leadingIcon: "assets/notification.svg",
                  leadingIconColor: pink,
                  bgIconColor: Colors.transparent, 
                  onTap: (){
                      Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => NotificationView(newLength: newNotifications.length,),
                            ),
                          );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 45),
                  child: Divider(height: 3, color: pink),
                ),
                SettingItem(title: "Contact", 
                  leadingIcon: "assets/message-contact.svg",
                  leadingIconColor: pink,
                  bgIconColor: Colors.transparent,
                  onTap: (){
                      Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ContactView(),
                            ),
                          );
                  },
                ),
                !userData['isAdmin'] ? Padding(
                  padding: const EdgeInsets.only(left: 45),
                  child: Divider(height: 2, color: pink,),
                ) : SizedBox(),
                !userData['isAdmin'] ? SettingItem(title: "Apply for Adding Society", 
                  leadingIcon: "assets/schedule-alert.svg",
                  leadingIconColor: pink,
                  bgIconColor: Colors.transparent,
                  onTap: (){
                      Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CreateCommunity(),
                            ),
                          );
                  },
                ) : SizedBox(),
                userData['isAdmin'] ? Padding(
                  padding: const EdgeInsets.only(left: 45),
                  child: Divider(height: 2, color: pink,),
                ) : SizedBox(),
                userData['isAdmin'] ? SettingItem(title: "Add Society", 
                  leadingIcon: "assets/schedule-alert.svg",
                  leadingIconColor: pink,
                  bgIconColor: Colors.transparent,
                  onTap: (){
                      Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AddCommunityView(),
                            ),
                          );
                  },
                ) : SizedBox(),
                Padding(
                  padding: const EdgeInsets.only(left: 45),
                  child: Divider(height: 2, color: pink,),
                ),
                SettingItem(title: "Rate us", 
                  leadingIcon: "assets/star.svg",
                  leadingIconColor: pink,
                  bgIconColor: Colors.transparent,
                  onTap: (){
                      StoreRedirect.redirect(
                        androidAppId: 'com.barkingulec.odtusocial', 
                      );
                  },
                ),
              ]
            ),
          ),
      
          // SizedBox(height: 20,),
          // Container(
          //   padding: const EdgeInsets.only(left: 15, right: 15),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(5),
          //     color: white,
          //     boxShadow: [
          //       BoxShadow(
          //         color: black.withOpacity(0.1),
          //         spreadRadius: 1,
          //         blurRadius: 1,
          //         offset: Offset(0, 1), // changes position of shadow
          //       ),
          //     ],
          //   ),
          //   child: Column(
          //     children: [
          //       // SettingItem(title: "Settings", 
          //       //   leadingIcon: "assets/settings.svg",
          //       //   bgIconColor: blue,
          //       //   onTap: (){
                  
          //       //   },
          //       // ),
          //       // Padding(
          //       //   padding: const EdgeInsets.only(left: 45),
          //       //   child: Divider(height: 0, color: gray,),
          //       // ),
          //       // SettingItem(title: "Privacy", 
          //       //   leadingIcon: "assets/privacy.svg",
          //       //   bgIconColor: purple,
          //       //   onTap: (){
                  
          //       //   },
          //       // ),
          //       // Padding(
          //       //   padding: const EdgeInsets.only(left: 45),
          //       //   child: Divider(height: 0, color: gray,),
          //       // ),
          //       SettingItem(title: "Contact", 
          //         leadingIcon: "assets/message-contact.svg",
          //         leadingIconColor: pink,
          //         bgIconColor: white,
          //         onTap: (){
          //             Navigator.of(context).push(
          //                   MaterialPageRoute(
          //                     builder: (context) => const ContactView(),
          //                   ),
          //                 );
          //         },
          //       ),
          //       !userData['isAdmin'] ? Padding(
          //         padding: const EdgeInsets.only(left: 45),
          //         child: Divider(height: 1, color: lightGray,),
          //       ) : SizedBox(),
          //       !userData['isAdmin'] ? SettingItem(title: "Apply for Adding Society", 
          //         leadingIcon: "assets/schedule-alert.svg",
          //         leadingIconColor: pink,
          //         bgIconColor: white,
          //         onTap: (){
          //             Navigator.of(context).push(
          //                   MaterialPageRoute(
          //                     builder: (context) => const CreateCommunity(),
          //                   ),
          //                 );
          //         },
          //       ) : SizedBox(),
          //       userData['isAdmin'] ? Padding(
          //         padding: const EdgeInsets.only(left: 45),
          //         child: Divider(height: 1, color: lightGray,),
          //       ) : SizedBox(),
          //       userData['isAdmin'] ? SettingItem(title: "Add Society", 
          //         leadingIcon: "assets/schedule-alert.svg",
          //         leadingIconColor: pink,
          //         bgIconColor: white,
          //         onTap: (){
          //             Navigator.of(context).push(
          //                   MaterialPageRoute(
          //                     builder: (context) => const AddCommunityView(),
          //                   ),
          //                 );
          //         },
          //       ) : SizedBox(),
          //       Padding(
          //         padding: const EdgeInsets.only(left: 45),
          //         child: Divider(height: 1, color: darkGray,),
          //       ),
          //       SettingItem(title: "Rate us", 
          //         leadingIcon: "assets/star.svg",
          //         leadingIconColor: pink,
          //         bgIconColor: white,
          //         onTap: (){
          //             StoreRedirect.redirect(
          //               androidAppId: 'com.barkingulec.odtusocial', 
          //             );
          //         },
          //       ),
          //     ]
          //   ),
          // ),
          SizedBox(height: 20,),
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            decoration: BoxDecoration(
              border: Border.all(color: pink.withOpacity(.4)),
              borderRadius: BorderRadius.circular(20),
              color: pink.withOpacity(0.04),
              // boxShadow: [
              //   BoxShadow(
              //     color: black.withOpacity(0.1),
              //     spreadRadius: 1,
              //     blurRadius: 1,
              //     offset: Offset(0, 1), // changes position of shadow
              //   ),
              // ],
            ),
            child: Column(
              children: [
                SettingItem(title: "Reset Password", 
                  leadingIcon: "assets/reset-password.svg",
                  leadingIconColor: black.withOpacity(0.8),
                  bgIconColor: Colors.transparent,
                  trailingIconColor: black.withOpacity(0.8),
                  onTap: () {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text('Reset Password'),
                                  content: Text("Password reset link will be sent to your email."),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: resetPassword,
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                          },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 45),
                  child: Divider(height: 1, color: pink,),
                ),
                SettingItem(title: "Log Out", 
                  leadingIcon: "assets/logout.svg",
                  leadingIconColor: black.withOpacity(0.8),
                  bgIconColor: Colors.transparent,
                  trailingIconColor: black.withOpacity(0.8),
                  onTap: () {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text('Log out'),
                                  content: Text("Are you sure you want to log out?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: signOut,
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
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