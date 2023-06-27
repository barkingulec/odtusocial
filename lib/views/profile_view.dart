import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:social/services/auth/firestore_methods.dart';
import 'package:social/utils/utils.dart';
import 'package:social/views/chat_single_view.dart';
import 'package:social/views/participation_view.dart';
import 'package:social/views/settings_view.dart';
import 'package:social/widgets/enroll_button.dart';
import 'package:store_redirect/store_redirect.dart';

import '../services/auth/auth_methods.dart';
import '../utils/colors.dart';
import '../widgets/create_community.dart';
import '../widgets/custom_image.dart';
import '../widgets/followers_view.dart';
import '../widgets/following_view.dart';
import '../widgets/setting_box.dart';
import '../widgets/setting_item.dart';
import 'add_community_view.dart';
import 'bookmarks_view.dart';
import 'contact_view.dart';
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
  var enrolledComData = [];
  var pastComData = [];
  String bio = "";
  String lastName = "";
  String firstName = "";
  String fullName = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userUid = "";
  int _followersCount = 0;
  int _followingCount = 0;
  bool _isFollowing = false;

  @override
  void initState() {
    final User? curUser = auth.currentUser;
    userUid = curUser!.uid;
    super.initState();
    getFollowersCount();
    getFollowingCount();
    setupIsFollowing();
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

      enrolledComData = userData['enrolledComData'];
      pastComData = userData['pastComData'];
      bio = userData["bio"];
      firstName = userData["firstName"];
      lastName = userData["lastName"];
      fullName = "$firstName $lastName";
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

getFollowersCount() async {
    int followersCount =
        await FireStoreMethods().followersNum(widget.uid);
    if (mounted) {
      setState(() {
        _followersCount = followersCount;
      });
    }
  }

  getFollowingCount() async {
    int followingCount =
        await FireStoreMethods().followingNum(widget.uid);
    if (mounted) {
      setState(() {
        _followingCount = followingCount;
      });
    }
  }

  followOrUnFollow() {
    if (_isFollowing) {
      unFollowUser();
    } else {
      followUser();
    }
  }

  unFollowUser() async {
    await FireStoreMethods().unFollowUser(userUid, widget.uid);
    setState(() {
      _isFollowing = false;
      _followersCount--;
    });
  }

  followUser() async {
    await FireStoreMethods().followUser(userUid, widget.uid);
    setState(() {
      _isFollowing = true;
      _followersCount++;
    });
  }

  setupIsFollowing() async {
    bool isFollowingThisUser = await FireStoreMethods().isFollowingUser(
        userUid, widget.uid);
    setState(() {
      _isFollowing = isFollowingThisUser;
    });
  }

 @override
  Widget build(BuildContext context) {
    final hasPagePushed = Navigator.of(context).canPop();
    return isLoading ? const Center(child: CircularProgressIndicator())  : Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: hasPagePushed ? IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: pink.withOpacity(.7)),
            onPressed: () => Navigator.of(context).pop(),
          ) : const SizedBox(),
        title: Text(userData['username'], style: TextStyle(
                                          color: pink.withOpacity(.7),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),),
          centerTitle: true,
        actions: userUid == userData['uid'] ? <Widget>[
        IconButton(
          icon: SvgPicture.asset("assets/settings.svg", color: pink.withOpacity(.7), width: 27, height: 27,),
          onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SettingsView(
                          userId: userUid,
                        ),
                      ),
                    ),
        )
      ] : [],
      iconTheme: IconThemeData(color: pink.withOpacity(.7)),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Container(
        child: Stack(
          alignment: Alignment.topCenter,
          //overflow: Overflow.visible,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 220.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: pink.withOpacity(.25), width: 1),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.elliptical(10000, 1500), bottomRight: Radius.elliptical(10000, 1500)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0, 1],
                    colors: [
                      pink.withOpacity(.06), 
                      pink.withOpacity(.45),
                      ],
                  )
                ),
                  ),
                )
              ],
            ),
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            pink.withOpacity(.01),
                            pink.withOpacity(.02),
                            pink.withOpacity(.04),
                            pink.withOpacity(.05),
                            pink.withOpacity(.06),
                            pink.withOpacity(.07),
                            pink.withOpacity(.09),
                          ],
                        )
                      ),
                      margin: EdgeInsets.only(top: 160),
                      child: getBody(),
                    ),
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
      padding: EdgeInsets.all(0),
      child: Container(
        decoration: BoxDecoration(
          //border: Border.all(color: pink.withOpacity(.1), width: 1),
                        color: whiteGray.withOpacity(.0),
                        borderRadius: BorderRadius.only(topLeft: Radius.elliptical(10000, 1500), topRight: Radius.elliptical(10000, 1500)),
                                              gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          //stops: [0, 1],
                          colors: [
                            // pink.withOpacity(.06), 
                            // pink.withOpacity(.45),
                            pink.withOpacity(.02),
                            pink.withOpacity(.05),
                            pink.withOpacity(.09),
                            pink.withOpacity(.15),
                            pink.withOpacity(.22),
                          ],
                        ),
                    //borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    border: Border.all(color: pink.withOpacity(.7), width: 1),
                       // borderRadius: BorderRadius.only(topLeft: Radius.elliptical(10000, 1500), topRight: Radius.elliptical(10000, 1500)),
                      borderRadius: BorderRadius.all(Radius.circular(60)),
                  ),
                  //margin: EdgeInsets.only(top: 20),
                  child: Container(
                    decoration: BoxDecoration(
                    border: Border.all(color: pink.withOpacity(.7), width: 1),
                       // borderRadius: BorderRadius.only(topLeft: Radius.elliptical(10000, 1500), topRight: Radius.elliptical(10000, 1500)),
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                    child: CustomImage(
                      userData["photoUrl"],
                      width: 100, 
                      height: 100, 
                      radius: 50,
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Text(userData["username"]!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
              ],
            ),
            SizedBox(height: 10,),
            widget.uid != userUid ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EnrollButton(
                                  text: 'Message',
                                  backgroundColor: Colors.white,
                                  textColor: pink,
                                  borderColor: pink,
                                  function: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => SingleChatPage(
                                        user: userData,
                                      ),
                                    ),
                                  ),
                                  height: 35,
                                  width: 130,
                            ),
                EnrollButton(
                              text: _isFollowing ? 'Unfollow' : 'Follow',
                              backgroundColor: Colors.white,
                              textColor: pink,
                              borderColor: pink,
                              function: followOrUnFollow,
                              height: 35,
                              width: 130,
                        ),
              ],
            ) : const SizedBox(),
            SizedBox(height: 18,),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: (){
                          Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ParticipationView(
                                    uid: widget.uid,
                                    userData: userData,
                                  ),
                                ),
                              );
                      },
                    child: Column(
                      children: [
                        Text("${userData['participation'].length}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4,),
                        Text("Participation", style: TextStyle(color: black.withOpacity(.80), fontSize: 13),),
                      ],
                    ),
                  ),
                  Container(
                    height: 26,
                    width: 1,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide( 
                          color: pink,
                          width: 1.0,
                        ),
                      )
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                          Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => FollowersView(
                                    uid: widget.uid,
                                  ),
                                ),
                              );
                      },
                    child: Column(
                      children: [
                        Text(_followersCount.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4,),
                        Text("Followers", style: TextStyle(color: black.withOpacity(.80), fontSize: 13),),
                      ],
                    ),
                  ),
                  Container(
                    height: 26,
                    width: 1,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide( 
                          color: pink,
                          width: 1.0,
                        ),
                      )
                    ),
                  ),
                  GestureDetector(
                      onTap: (){
                          Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => FollowingView(
                                    uid: widget.uid,
                                  ),
                                ),
                              );
                      },
                    child: Column(
                      children: [
                        Text(_followingCount.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4,),
                        Text("Following", style: TextStyle(color: black.withOpacity(.80), fontSize: 13),),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: MediaQuery.of(context).size.width - 30,
                margin: const EdgeInsets.only(top: 15,),
                padding: const EdgeInsets.only(left: 15, right: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: pink.withOpacity(.35)),
                  borderRadius: BorderRadius.circular(25),
                  //color: pink.withOpacity(0.04),
                  gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          //stops: [0, 1],
                          colors: [
                            // pink.withOpacity(.06), 
                            // pink.withOpacity(.45),
                            pink.withOpacity(.0),
                            pink.withOpacity(.015),
                            pink.withOpacity(.030),
                            pink.withOpacity(.045),
                            pink.withOpacity(.060),
                            pink.withOpacity(.045),
                            pink.withOpacity(.030),
                            pink.withOpacity(.015),
                            pink.withOpacity(.0),
                          ],
                        ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 18.0, bottom: 18, left: 8, right: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name", style: const TextStyle(
                                                color: black,
                                                fontSize: 17,
                                                ),),
                      const SizedBox(height: 10),
                      fullName.trim().isNotEmpty ? Text(fullName, style: const TextStyle(
                                                color: darkGray,
                                                fontSize: 17,
                                                ),) : Text("-", style: const TextStyle(
                                                color: darkGray,
                                                fontSize: 17,
                                                ),),
                      const SizedBox(height: 10),
              
                      Text("Biography", style: const TextStyle(
                                                color: black,
                                                fontSize: 17,
                                                ),),
                      const SizedBox(height: 10),
                      bio.isNotEmpty ? Text(bio, style: const TextStyle(
                                                color: darkGray,
                                                fontSize: 16,
                                                ),) : Text("-", style: const TextStyle(
                                                color: darkGray,
                                                fontSize: 16,
                                                ),),
                      const SizedBox(height: 10),
              
                      Text("Current Activities", style: const TextStyle(
                                                color: black,
                                                fontSize: 17,
                                                ),),
                      const SizedBox(height: 10),
                      enrolledComData.isEmpty ? const Text("-") : const SizedBox(),
                      for (var hs in enrolledComData) for (var field in hs.values) 
                        Text("${field['role'].toString()} in ${field['communityName']} since ${DateFormat('dd/MM/yyyy').format(field['joinDate'].toDate())}.", style: const TextStyle(
                                                color: darkGray,
                                                fontSize: 16,
                                                ),),
                      const SizedBox(height: 10),
                      const Text("Past Activities", style: TextStyle(
                                                color: black,
                                                fontSize: 17,
                                                ),),
                      const SizedBox(height: 10),
                      pastComData.isEmpty ? const Text("-") : const SizedBox(),
                      for (var hs in pastComData) for (var field in hs.values) 
                        Column(
                          children: [
                            Text("${field['role'].toString()} in ${field['communityName']} between ${DateFormat('dd/MM/yyyy').format(field['joinDate'].toDate())} and ${DateFormat('dd/MM/yyyy').format(field['leftDate'].toDate())}.", style: const TextStyle(
                                                    color: darkGray,
                                                    fontSize: 16,
                                                    ),),
                            const SizedBox(height: 10),
                          ],
                        ),

                    ],
                  ),
                ),
              ),
            ),
            // SizedBox(height: 20,),
            // Container(
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Expanded(
            //         child: SettingBox(title: "Test", icon: "assets/privacy.svg",)
            //       ),
            //       SizedBox(width: 10,),
            //       Expanded(
            //         child: SettingBox(title: "Test", icon: "assets/privacy.svg",)
            //       ),
            //       SizedBox(width: 10,),
            //       Expanded(
            //         child: SettingBox(title: "Test", icon: "assets/privacy.svg",)
            //       ),
            //     ],
            //   ),
            // ),
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
            //       SettingItem(title: "Edit Profile", 
            //         leadingIcon: "assets/edit_profile.svg",
            //         leadingIconColor: pink,
            //         bgIconColor: white,
            //         onTap: (){
            //             Navigator.of(context).push(
            //                   MaterialPageRoute(
            //                     builder: (context) => const EditProfileView(),
            //                   ),
            //                 );
            //         },
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.only(left: 45),
            //         child: Divider(height: 1, color: gray,),
            //       ),
            //       SettingItem(title: "Bookmarks", 
            //         leadingIcon: "assets/bookmark.svg",
            //         leadingIconColor: pink,
            //         bgIconColor: white,
            //         onTap: (){
            //             Navigator.of(context).push(
            //                   MaterialPageRoute(
            //                     builder: (context) => const BookmarksViews(),
            //                   ),
            //                 );
            //         },
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.only(left: 45),
            //         child: Divider(height: 0, color: darkGray),
            //       ),
            //       SettingItem(title: "Notifications", 
            //         leadingIcon: "assets/notification.svg",
            //         leadingIconColor: pink,
            //         bgIconColor: white, 
            //         onTap: (){
            //             Navigator.of(context).push(
            //                   MaterialPageRoute(
            //                     builder: (context) => NotificationView(newLength: newNotifications.length,),
            //                   ),
            //                 );
            //         },
            //       ),
      
            //     ]
            //   ),
            // ),
      
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
            //       SettingItem(title: "Reset Password", 
            //         leadingIcon: "assets/reset-password.svg",
            //         leadingIconColor: black.withOpacity(0.75),
            //         bgIconColor: white, 
            //         onTap: () {
            //                   showDialog<String>(
            //                       context: context,
            //                       builder: (BuildContext context) => AlertDialog(
            //                         title: Text('Reset Password'),
            //                         content: Text("Password reset link will be sent to your email."),
            //                         actions: <Widget>[
            //                           TextButton(
            //                             onPressed: () => Navigator.pop(context, 'Cancel'),
            //                             child: const Text('Cancel'),
            //                           ),
            //                           TextButton(
            //                             onPressed: resetPassword,
            //                             child: const Text('OK'),
            //                           ),
            //                         ],
            //                       ),
            //                     );
            //                 },
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.only(left: 45),
            //         child: Divider(height: 1, color: darkGray,),
            //       ),
            //       SettingItem(title: "Log Out", 
            //         leadingIcon: "assets/logout.svg",
            //         leadingIconColor: black.withOpacity(0.75),
            //         bgIconColor: white, 
            //         onTap: () {
            //                   showDialog<String>(
            //                       context: context,
            //                       builder: (BuildContext context) => AlertDialog(
            //                         title: Text('Log out'),
            //                         content: Text("Are you sure you want to log out?"),
            //                         actions: <Widget>[
            //                           TextButton(
            //                             onPressed: () => Navigator.pop(context, 'Cancel'),
            //                             child: const Text('Cancel'),
            //                           ),
            //                           TextButton(
            //                             onPressed: signOut,
            //                             child: const Text('OK'),
            //                           ),
            //                         ],
            //                       ),
            //                     );
            //                 },
            //       ),
            //     ]
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
