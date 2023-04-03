import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:social/views/profile_view.dart';

import '../utils/colors.dart';
import '../widgets/course_item.dart';
import '../widgets/custom_image.dart';
import 'community_detail_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;
  bool isLoading = false;
  List<Map<String, dynamic>> communities = [];

  @override
  void initState() {
    super.initState();
    getAllCommunities();
  }
  Future<void> getAllCommunities() async {
    setState(() {
      isLoading = true;
    });
    CollectionReference communitiesRef =
        FirebaseFirestore.instance.collection('communities');
    final snapshot = await communitiesRef.get();
    communities = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    setState(() {
      isLoading = false;
    });
  }
  
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center(child: CircularProgressIndicator(),) : Scaffold(
      
      appBar: isShowUsers ? AppBar(
        backgroundColor: whiteGray,
        title: Text(
              "Search",
              style: TextStyle(color: black, fontWeight: FontWeight.w600, fontSize: 24
              ),
        ),
        iconTheme: const IconThemeData(color: black),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined),
            tooltip: 'Go back to search screen',
            onPressed: () {
              setState(() {
               isShowUsers = false;
              });
            },
          ),
      ) : null,
      body: isShowUsers ? searchedView() : CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: whiteGray,
            pinned: true,
            title: getAppBar(),
          ),
          SliverToBoxAdapter(
            child: getSearchBox()
          ),
          SliverList(delegate: getCommunities(),),
        ],
      ),
    );
  }
    getAppBar() {
      return Container(
        child: Row(
          children: [
            Text(
              "Search",
              style: TextStyle(color: black, fontWeight: FontWeight.w600, fontSize: 24),
            ),
          ],
        ),
      );
    }

    getSearchBox() {
      return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                padding: EdgeInsets.only(bottom: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: black.withOpacity(0.97),
                      spreadRadius: .5,
                      blurRadius: .5,
                      offset: Offset(0, 0),
                    )
                  ]
                ),
                child: Form(
                  child: TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: gray),
                      border: InputBorder.none,
                      hintText: "Search",
                      hintStyle: TextStyle(color: gray, fontSize: 15),
                    ),
                    onFieldSubmitted: (String _) {
                     setState(() {
                       isShowUsers = true;
                     });},
                  ),
                )
              ))
        ]),
      );
    }

    getCommunities() {
      return SliverChildBuilderDelegate(
        childCount: communities.length, 
        (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15,),
          child: CourseItem(data: communities[index])
        );
      });
    }

    searchedView() {
      return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('communities')
                  .where(
                    'name',
                    isGreaterThanOrEqualTo: searchController.text,
                  )
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommunityDetailView(
                            communityId: (snapshot.data! as dynamic).docs[index]['communityId'],
                          ),
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                          bottom: BorderSide(width: 1.0, color: gray),
                        )
                        ),
                        child: ListTile(
                          // leading: CircleAvatar(
                          //   backgroundImage: NetworkImage(
                          //     (snapshot.data! as dynamic).docs[index]['image'],
                          //   ),
                          //   radius: 16,
                          // ),
                          leading: CustomImage(
                            (snapshot.data! as dynamic).docs[index]['image'],
                                radius: 8,
                                width: 40,
                                height: 40,),
                          title: Text(
                            (snapshot.data! as dynamic).docs[index]['name'],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
    }
    
          
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