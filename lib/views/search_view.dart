import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social/views/post_detail_view.dart';
import 'package:social/views/profile_view.dart';
import 'package:async/async.dart';
import 'package:social/widgets/enroll_button.dart';
import '../utils/colors.dart';
import '../widgets/course_item.dart';
import '../widgets/custom_image.dart';
import '../widgets/recommend_item.dart';
import '../widgets/single_event_search.dart';
import '../widgets/single_post_search.dart';
import '../widgets/single_user_search.dart';
import 'community_detail_view.dart';
import 'event_detail_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with SingleTickerProviderStateMixin{
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  bool isLoading = false;
  List<Map<String, dynamic>> communities = [];
  List<Map<String, dynamic>> allEvents = [];
  List<Map<String, dynamic>> allPosts = [];
  List<Map<String, dynamic>> profiles = [];
  List<Map<String, dynamic>> allData = [];
  String name = "";
  String selected = "s";
  late TabController tabController;
  //var stream;

  @override
  void initState() {
    super.initState();
    getAllCommunities();
    getAllEvents();
    getAllProfiles();
    getAllPosts();
    tabController = TabController(length: 2, vsync: this);
    //queryValues();
    print(allEvents);
  }

  Future<void> getAllCommunities() async {
    setState(() {
      isLoading = true;
    });
    CollectionReference communitiesRef =
        FirebaseFirestore.instance.collection('communities');
    final snapshot = await communitiesRef.get();
    communities = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    allData = allData + communities;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getAllProfiles() async {
    setState(() {
      isLoading = true;
    });
    CollectionReference profilesRef =
        FirebaseFirestore.instance.collection('profiles');
    final snapshot = await profilesRef.get();
    profiles = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    allData = allData + profiles;
    setState(() {
      isLoading = false;
    });
  }
  
   Future<void> getAllEvents() async
    {
      setState(() {
        isLoading = true;
      });
      var query= await FirebaseFirestore.instance.collection("communities").get();
      for(var userdoc in query.docs)
        {
          QuerySnapshot feed = await FirebaseFirestore.instance.collection("communities")
              .doc(userdoc.id).collection("events").get();
                    
          for (var postDoc in feed.docs ) {
            setState(() {
              allEvents.add(postDoc.data() as Map<String, dynamic>);
              //allData.add(postDoc.data() as Map<String, dynamic>);
            });
          }
        }
        allData = allData + allEvents;
        setState(() {
          isLoading = false;
      });
    }

    Future<void> getAllPosts() async
  {
    setState(() {
      isLoading = true;
    });
    var query= await FirebaseFirestore.instance.collection("communities").get();
    for(var userdoc in query.docs)
      {
        QuerySnapshot feed = await FirebaseFirestore.instance.collection("communities")
            .doc(userdoc.id).collection("posts").get();
                  
        for (var postDoc in feed.docs ) {
          setState(() {
            allPosts.add(postDoc.data() as Map<String, dynamic>);
            //allData.add(postDoc.data() as Map<String, dynamic>);
          });
        }
      }
      allData = allData + allPosts;
      setState(() {
        isLoading = false;
    });
  }

  searchOnTapHandler(data) {
    if (data['type'] == "User") {
      Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfileView(
                                  uid: data['uid'],
                                ),
                              ));
    }
    else if (data['type'] == "Society") {
      Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CommunityDetailView(
                                  communityId: data['communityId'],
                                ),
                              ));
    }
    else if (data['type'] == "Event") {
      Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EventDetailView(
                                  eventId: data['eventId'],
                                  communityId: data['communityId'],
                                ),
                              ));
    }
    else if (data['type'] == "Post") {
      Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PostDetailView(
                                  communityId: data['communityId'],
                                  postId: data['postId'],
                                ),
                              ));
    }
  }

  Stream<List<QuerySnapshot>> mergeStreams() {
        Stream<QuerySnapshot<Object?>> stream1 = FirebaseFirestore.instance.collection('communities').snapshots();
        Stream<QuerySnapshot<Object?>> stream2 = FirebaseFirestore.instance.collection('profiles').snapshots();
        return StreamZip([stream1, stream2]);
      }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //automaticallyImplyLeading: false,
          titleSpacing: 0.0,
          backgroundColor: white,
          elevation: 0,
          title: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(0.0),
                        alignment: Alignment.bottomCenter,
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              name = val;
                              isSearching = true;
                            });
                            if (val.isEmpty) {
                              setState(() {
                                isSearching = false;
                            });
                            }
                          },
                            //controller: _commentController,
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
                                    color: pink.withOpacity(.2),
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
                                    // Colors.grey.shade50,
                                    // Colors.grey.shade100,
                                    // Colors.grey.shade200,
                                    // Colors.grey.shade300,
                                    // Colors.grey.shade400,
                                    pink.withOpacity(.02),
                                    pink.withOpacity(.05),
                                    pink.withOpacity(.09),
                                    pink.withOpacity(.15),
                                    pink.withOpacity(.22),
                                  ],
                                ),
                              ),
                              child: Icon(Icons.search, size: 30, color: pink.withOpacity(.7)),
                            ),
                            //prefixIcon: Icon(Icons.comment, color: pink), 
                            hintText: '    Search...',
                            hintStyle: TextStyle(color: pink.withOpacity(.9)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                      ),
            // title: Card(
            //   child: TextField(
            //     decoration: InputDecoration(
            //         filled: true,
            //         fillColor: whiteGray.withOpacity(0),
            //         prefixIcon: Icon(Icons.search), hintText: 'Search...',
            //         border: OutlineInputBorder(
            //             borderRadius: new BorderRadius.circular(10.0),
            //             borderSide: BorderSide.none,
            //           ),
            //         ),
            //     onChanged: (val) {
            //       setState(() {
            //         name = val;
            //         isSearching = true;
            //       });
            //       if (val.isEmpty) {
            //         setState(() {
            //           isSearching = false;
            //       });
            //       }
            //     },
            //   ),
            // ),
        ),
        // body: isSearching ? StreamBuilder<QuerySnapshot>(
        //   stream: FirebaseFirestore.instance.collection('communities').snapshots(),
        //   builder: (context, snapshots) {
        //     return (snapshots.connectionState == ConnectionState.waiting)
        //         ? const Center(
        //             child: CircularProgressIndicator(),
        //           )
        //         : ListView.builder(
        //             itemCount: snapshots.data!.docs.length,
        //             itemBuilder: (context, index) {
        //               var data = snapshots.data!.docs[index].data()
        //                   as Map<String, dynamic>;
                     
        //               if (
        //                 data['name']
        //                   .toString()
        //                   .toLowerCase()
        //                   .contains(name.toLowerCase())) 
        //                   {
        //                 return InkWell(
        //                   onTap: () => Navigator.of(context).push(
        //                       MaterialPageRoute(
        //                         builder: (context) => CommunityDetailView(
        //                           communityId: data['communityId'],
        //                         ),
        //                       ),
        //                   ),
        //                   child: ListTile(
        //                     title: Text(
        //                       data['name'],
        //                       maxLines: 1,
        //                       overflow: TextOverflow.ellipsis,
        //                       style: TextStyle(
        //                           color: black,
        //                           fontSize: 16,
        //                           fontWeight: FontWeight.bold),
        //                     ),
        //                     subtitle: Text(
        //                       "${data['enrolledUsers'].length} members",
        //                       maxLines: 1,
        //                       overflow: TextOverflow.ellipsis,
        //                       style: TextStyle(
        //                           color: gray,
        //                           fontSize: 16,
        //                           fontWeight: FontWeight.bold),
        //                     ),
        //                     leading: CustomImage(
        //                       data['image'],
        //                     ),
        //                   ),
        //                 );
        //               }
        //               return Container();
        //             });
        //   },
        // ) : SingleChildScrollView(
        //   padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
        //   child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //         children: [
        //           getTabBar(),
        //           getTabBarPages(),
        //         ]
        //   ),
        // )

        body: isSearching ? ListView.builder(
                itemCount: allData.length,
                itemBuilder: ((context, index) {
                  if (allData[index]['username']
                          .toString()
                          .toLowerCase()
                          .contains(name.toLowerCase())) {
                  return GestureDetector(
                    onTap: () {
                      searchOnTapHandler(allData[index]);
                    },
                    child: ListTile(
                      title: Text(allData[index]['username']),
                      leading: CustomImage(
                        allData[index]['photoUrl'],
                        width: 40,
                        height: 40,
                        radius: 20,
                      ),
                      subtitle: Text(allData[index]['type']),
                    ),
                  );
                          }
                  return Container();
                }),
          ) 
              : mainWidget(),
        );
  }

  Widget mainWidget() {
    return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buttons(),
                    getView(),
                  ]
            ),
          );
  }

  Widget buttons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
      padding: const EdgeInsets.only(top: 2),
      child: TextButton(
        onPressed: () {
          setState(() {
            selected = "s";
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: white,
            border: Border.all(
              color: pink.withOpacity(.8),
            ),
            borderRadius: BorderRadius.circular(20),
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
                                gradient: selected == "s" ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    pink.withOpacity(.02),
                                    pink.withOpacity(.05),
                                    pink.withOpacity(.10),
                                    pink.withOpacity(.17),
                                    pink.withOpacity(.25),
                                  ],
                                ) : const LinearGradient(colors: [Colors.transparent, Colors.transparent]),
                              ),
          alignment: Alignment.center,
          width: 100,
          height: 45,
          child: Text(
            "Societies",
            style: TextStyle(
              color: pink.withOpacity(.8),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ),



            Container(
      padding: const EdgeInsets.only(top: 2),
      child: TextButton(
        onPressed: () {
          setState(() {
            selected = "e";
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: white,
            border: Border.all(
              color: pink.withOpacity(.8),
            ),
            borderRadius: BorderRadius.circular(20),
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
                                gradient: selected == "e" ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    pink.withOpacity(.02),
                                    pink.withOpacity(.05),
                                    pink.withOpacity(.10),
                                    pink.withOpacity(.17),
                                    pink.withOpacity(.25),
                                  ],
                                ) : const LinearGradient(colors: [Colors.transparent, Colors.transparent]),
                              ),
          alignment: Alignment.center,
          width: 100,
          height: 45,
          child: Text(
            "Events",
            style: TextStyle(
              color: pink.withOpacity(.8),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ),



          Container(
      padding: const EdgeInsets.only(top: 2),
      child: TextButton(
        onPressed: () {
          setState(() {
            selected = "p";
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: white,
            border: Border.all(
              color: pink.withOpacity(.8),
            ),
            borderRadius: BorderRadius.circular(20),
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
                                gradient: selected == "p" ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    pink.withOpacity(.02),
                                    pink.withOpacity(.05),
                                    pink.withOpacity(.10),
                                    pink.withOpacity(.17),
                                    pink.withOpacity(.25),
                                  ],
                                ) : const LinearGradient(colors: [Colors.transparent, Colors.transparent]),
                              ),
          alignment: Alignment.center,
          width: 100,
          height: 45,
          child: Text(
            "Posts",
            style: TextStyle(
              color: pink.withOpacity(.8),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ),



 Container(
      padding: const EdgeInsets.only(top: 2),
      child: TextButton(
        onPressed: () {
          setState(() {
            selected = "u";
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: white,
            border: Border.all(
              color: pink.withOpacity(.8),
            ),
            borderRadius: BorderRadius.circular(20),
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
                                gradient: selected == "u" ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    pink.withOpacity(.02),
                                    pink.withOpacity(.05),
                                    pink.withOpacity(.10),
                                    pink.withOpacity(.17),
                                    pink.withOpacity(.25),
                                  ],
                                ) : const LinearGradient(colors: [Colors.transparent, Colors.transparent]),
                              ),
          alignment: Alignment.center,
          width: 100,
          height: 45,
          child: Text(
            "Users",
            style: TextStyle(
              color: pink.withOpacity(.8),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ),

        ],
      ),
    );
  }


  Widget getView() {
    if (selected == "s") {
      return getCommunities();
    }
    else if (selected == "e") {
      return getEvents();
    }
    else if (selected == "u") {
      return getUsers();
    }
    else if (selected == "p") {
      return getPosts();
    }
    return getCommunities();
  }

  Widget getCommunities() {
    return SingleChildScrollView(
      //physics: const NeverScrollableScrollPhysics(),
        //padding: const EdgeInsets.all(5),
        //scrollDirection: Axis.vertical,
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(communities.length, (index) => 
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 4),
              child: CourseItem(
                data: communities[index],
                width: MediaQuery.of(context).size.width,
              )
            ) 
          ),
        ),
      );
  }

  Widget getEvents() {
    return SingleChildScrollView(
      //physics: const NeverScrollableScrollPhysics(),
        //padding: const EdgeInsets.all(5),
        //scrollDirection: Axis.vertical,
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(allEvents.length, (index) => 
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 4),
              child: SingleEventSearch(
                data: allEvents[index],
              )
            ) 
          ),
        ),
      );
  }

  Widget getUsers() {
    return SingleChildScrollView(
      //physics: const NeverScrollableScrollPhysics(),
        //padding: const EdgeInsets.all(5),
        //scrollDirection: Axis.vertical,
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(profiles.length, (index) => 
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2, left: 1, right: 1),
              child: SingleUserSearch(
                data: profiles[index],
              )
            ) 
          ),
        ),
      );
  }

  Widget getPosts() {
    return SingleChildScrollView(
      //physics: const NeverScrollableScrollPhysics(),
        //padding: const EdgeInsets.all(5),
        //scrollDirection: Axis.vertical,
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(allPosts.length, (index) => 
            Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 3, left: 1, right: 1),
              child: SinglePostSearch(
                data: allPosts[index],
              )
            ) 
          ),
        ),
      );
  }


//   Widget getTabBar() {
//     return Container(
//       child: TabBar(
//         controller: tabController,
//         tabs: const [
//           Tab(child: Text("Societies", style: TextStyle(fontSize: 16, color: black),),),
//           Tab(child: Text("Events", style: TextStyle(fontSize: 16, color: black)),)
//       ],),
//     );
//   }
  
//   Widget getTabBarPages() {
//     return Container(
//       height: (290 * communities.length).toDouble() + 20,
//       //height: 200,
//       width: double.infinity,
//       child: TabBarView(
//         physics: const NeverScrollableScrollPhysics(),
//         controller: tabController,
//         children: [
//           getUpcomingEvents(),
//           getPastEvents(),
//       ],
//       ),
//     );
//   }
  
//   Widget getUpcomingEvents() {
//     return StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('communities')
//             .snapshots(),
//         builder: (context,
//             AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
    
//           return ListView.builder(
//             //shrinkWrap: true,
//             //primary: false,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (ctx, index) => CourseItem(
//               data: snapshot.data!.docs[index],
//             ),
//           );
//         },
//       );
//   }

// // Widget getPastEvents() {
// //     return Expanded(
// //       child: ListView.builder(primary: false, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: allEvents.length ,itemBuilder: (context, index) {
// //         return RecommendItem(
// //           data: allEvents[index]
// //         );
// //       })
// //     );
// //   }

//   Widget getPastEvents() {
//     return SingleChildScrollView(
//       //physics: const NeverScrollableScrollPhysics(),
//         //padding: const EdgeInsets.all(5),
//         //scrollDirection: Axis.vertical,
//         child: Column(
//           //mainAxisSize: MainAxisSize.min,
//           //mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: List.generate(allEvents.length, (index) => 
//             Padding(
//               padding: const EdgeInsets.all(10),
//               child: RecommendItem(
//                 data: allEvents[index],
//               )
//             ) 
//           ),
//         ),
//       );
//   }


  // @override
  // Widget build(BuildContext context) {
  //   return isLoading ? const Center(child: CircularProgressIndicator(),) : Scaffold(
      
  //     appBar: isShowUsers ? AppBar(
  //       backgroundColor: whiteGray,
  //       title: Text(
  //             "Search",
  //             style: TextStyle(color: black, fontWeight: FontWeight.w600, fontSize: 24
  //             ),
  //       ),
  //       iconTheme: const IconThemeData(color: black),
  //       leading: IconButton(
  //           icon: const Icon(Icons.arrow_back_ios_new_outlined),
  //           tooltip: 'Go back to search screen',
  //           onPressed: () {
  //             setState(() {
  //              isShowUsers = false;
  //             });
  //           },
  //         ),
  //     ) : null,
  //     body: isShowUsers ? searchedView() : CustomScrollView(
  //       slivers: [
  //         SliverAppBar(
  //           backgroundColor: whiteGray,
  //           pinned: true,
  //           title: getAppBar(),
  //         ),
  //         SliverToBoxAdapter(
  //           child: getSearchBox()
  //         ),
  //         SliverList(delegate: getCommunities(),),
  //       ],
  //     ),
  //   );
  // }
  //   getAppBar() {
  //     return Container(
  //       child: Row(
  //         children: [
  //           Text(
  //             "Search",
  //             style: TextStyle(color: black, fontWeight: FontWeight.w600, fontSize: 24),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   getSearchBox() {
  //     return Padding(
  //       padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
  //       child: Row(
  //         children: [
  //           Expanded(
  //             child: Container(
  //               height: 40,
  //               padding: EdgeInsets.only(bottom: 3),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(10),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: black.withOpacity(0.97),
  //                     spreadRadius: .5,
  //                     blurRadius: .5,
  //                     offset: Offset(0, 0),
  //                   )
  //                 ]
  //               ),
  //               child: Form(
  //                 child: TextFormField(
  //                   onChanged: (val) {
  //                     setState(() {
  //                       name = val;
  //                     });
  //                   },
  //                   //controller: searchController,
  //                   decoration: InputDecoration(
  //                     prefixIcon: Icon(Icons.search, color: gray),
  //                     border: InputBorder.none,
  //                     hintText: "Search",
  //                     hintStyle: TextStyle(color: gray, fontSize: 15),
  //                   ),
  //                   onFieldSubmitted: (String _) {
  //                    setState(() {
  //                      isShowUsers = true;
  //                    });},
  //                 ),
  //               )
  //             ))
  //       ]),
  //     );
  //   }

  //   getCommunities() {
  //     return SliverChildBuilderDelegate(
  //       childCount: communities.length, 
  //       (context, index) {
  //       return Padding(
  //         padding: const EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15,),
  //         child: CourseItem(data: communities[index])
  //       );
  //     });

    // searchedView() {
    //   return FutureBuilder(
    //           future: FirebaseFirestore.instance
    //               .collection('communities')
    //               .where(
    //                 'name',
    //                 isGreaterThanOrEqualTo: searchController.text,
    //                 isLessThan: searchController.text.substring(0, searchController.text.length-1) + String.fromCharCode(searchController.text.codeUnitAt(searchController.text.length - 1) + 1),
    //                 )
    //               // .where(
    //               //   'nameSearch',
    //               //   arrayContains: searchController.text,
    //               // )
    //               .get(),
    //           builder: (context, snapshot) {
    //             if (!snapshot.hasData) {
    //               return const Center(
    //                 child: CircularProgressIndicator(),
    //               );
    //             }
    //             return ListView.builder(
    //               itemCount: (snapshot.data! as dynamic).docs.length,
    //               itemBuilder: (context, index) {
    //                 return InkWell(
    //                   onTap: () => Navigator.of(context).push(
    //                     MaterialPageRoute(
    //                       builder: (context) => CommunityDetailView(
    //                         communityId: (snapshot.data! as dynamic).docs[index]['communityId'],
    //                       ),
    //                     ),
    //                   ),
    //                   child: Container(
    //                     decoration: const BoxDecoration(
    //                       border: Border(
    //                       bottom: BorderSide(width: 1.0, color: gray),
    //                     )
    //                     ),
    //                     child: ListTile(
    //                       // leading: CircleAvatar(
    //                       //   backgroundImage: NetworkImage(
    //                       //     (snapshot.data! as dynamic).docs[index]['image'],
    //                       //   ),
    //                       //   radius: 16,
    //                       // ),
    //                       leading: CustomImage(
    //                         (snapshot.data! as dynamic).docs[index]['image'],
    //                             radius: 8,
    //                             width: 40,
    //                             height: 40,),
    //                       title: Text(
    //                         (snapshot.data! as dynamic).docs[index]['name'],
    //                       ),
    //                     ),
    //                   ),
    //                 );
    //               },
    //             );
    //           },
    //         );
    // }
    
          
    //   appBar: AppBar(
    //     backgroundColor: mobileBackgroundColor,
    //     title: Form(
    //       child: TextFormField(
    //         controller: searchController,
    //         decoration:
    //             const InputDecoration(labelText: 'Search for a community...'),
    //         onFieldSubmitted: (String _) {
    //           setState(() {
    //             isShowUsers = true;
    //           });
    //           print(_);
    //         },
    //       ),
    //     ),
    //   ),
    //   body: isShowUsers
    //       ? FutureBuilder(
    //           future: FirebaseFirestore.instance
    //               .collection('communities')
    //               .where(
    //                 'name',
    //                 isGreaterThanOrEqualTo: searchController.text,
    //               )
    //               .get(),
    //           builder: (context, snapshot) {
    //             if (!snapshot.hasData) {
    //               return const Center(
    //                 child: CircularProgressIndicator(),
    //               );
    //             }
    //             return ListView.builder(
    //               itemCount: (snapshot.data! as dynamic).docs.length,
    //               itemBuilder: (context, index) {
    //                 return InkWell(
    //                   onTap: () => Navigator.of(context).push(
    //                     MaterialPageRoute(
    //                       builder: (context) => CommunityDetailView(
    //                         communityId: (snapshot.data! as dynamic).docs[index]['communityId'],
    //                       ),
    //                     ),
    //                   ),
    //                   child: ListTile(
    //                     leading: CircleAvatar(
    //                       backgroundImage: NetworkImage(
    //                         (snapshot.data! as dynamic).docs[index]['image'],
    //                       ),
    //                       radius: 16,
    //                     ),
    //                     title: Text(
    //                       (snapshot.data! as dynamic).docs[index]['name'],
    //                     ),
    //                   ),
    //                 );
    //               },
    //             );
    //           },
    //         )
    //       : const Center(child: Text("User is not found"))
    // );
}