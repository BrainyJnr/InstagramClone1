import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/add_post_screen.dart';
import 'package:instagram_clone/screens/search_screen.dart';
import '../screens/feed_screen.dart';
import '../screens/pofile_screen.dart';
import '../screens/profile_screen.dart';

const webScreenSize = 600;

var homescreenItems = [
  FeedScreen(),
  SearchScreen(),
  AddPostScreen(),
  Text("Samuel"),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  )
];
