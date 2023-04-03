import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social/views/feed_view.dart';
import 'package:social/views/my_communities_view.dart';
import 'package:social/views/profile_view.dart';
import 'package:social/views/search_view.dart';

List<Widget> homeScreenItems = [
  const FeedView(),
  const SearchView(),
  const MyCommunitiesView(),
  ProfileView(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];

const List<Widget> options = <Widget>[
  Text('Admins'),
  Text('Members'),
  Text('Everyone')
];