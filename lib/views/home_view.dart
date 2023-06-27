import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social/services/auth/auth_methods.dart';
import 'package:social/views/login_view.dart';

import '../utils/colors.dart';
import '../utils/global_variables.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  String? displayName = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  int _page = 0;
  late PageController pageController;


  @override
  void initState() {
    super.initState();
    pageController = PageController();
    final User? curUser = auth.currentUser;
    displayName = curUser!.displayName;
  }
  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: 
            //    (_page == 0) ? Padding(
            //   padding: const EdgeInsets.only(top: 10),
            //   child: Container(
            //     height: 40,
            //     width: 40,
            //     decoration: BoxDecoration(
            //     color: white,
            //     borderRadius: BorderRadius.all(
            //       Radius.circular(25)
            //     ), 
            //     boxShadow: [
            //       BoxShadow(
            //         color: black.withOpacity(0.17),
            //         blurRadius: 5,
            //         spreadRadius: 2,
            //         offset: Offset(0, 0)
            //       )
            //     ]
            //   ),
            //     child: Icon(
            //       Icons.home,
            //       color: (_page == 0) ? pink : gray,
            //       size: 30,
            //     ),
            //   ),
            // )
            // : 
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SvgPicture.asset("assets/home.svg", color: (_page == 0) ? pink : gray, width: 26, height: 26,)
              ),
            label: '',
            backgroundColor: white,
          ),
          BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SvgPicture.asset("assets/search.svg", color: (_page == 1) ? pink : gray, width: 26, height: 26,)
              ),
              label: '',
              backgroundColor: white),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SvgPicture.asset("assets/message.svg", color: (_page == 2) ? pink : gray, width: 26, height: 26,)
            ),
            label: '',
            backgroundColor: white,
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SvgPicture.asset("assets/profile.svg", color: (_page == 3) ? pink : gray, width: 26, height: 26,)
            ),
            label: '',
            backgroundColor: white,
          ),
        ],
        onTap: navigationTapped,
        currentIndex: _page,
      ),
    );
  }
}