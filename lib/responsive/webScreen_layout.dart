import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clone/utilis/global.dart';

import '../utilis/colors.dart';

class WebscreenLayout extends StatefulWidget {
  const WebscreenLayout({super.key});

  @override
  State<WebscreenLayout> createState() => _WebscreenLayoutState();
}

class _WebscreenLayoutState extends State<WebscreenLayout> {
  String username = "";
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUsername();
    pageController = PageController();
  }

  void getUsername() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection("Instagram")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      username = (snap.data() as Map<String, dynamic>)["username"];
    });

    print(snap.data());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
    setState(() {
      _page = page;
    });
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          centerTitle: false,
          title: SvgPicture.asset(
            "assets/image/Instagram.svg",
            color: primaryColor,
            height: 32,
          ),
          actions: [
            IconButton(
                onPressed: () => navigationTapped(0),
                icon: Icon(
                  Icons.home,
                  color: _page == 0 ? primaryColor : secondaryColor,
                )),
            IconButton(
                onPressed: () => navigationTapped(1),
                icon: Icon(
                  Icons.search,
                  color: _page == 1 ? primaryColor : secondaryColor,
                )),

            IconButton(
                onPressed: () => navigationTapped(2),
                icon: Icon(
                  Icons.add_a_photo,
                  color: _page == 2 ? primaryColor : secondaryColor,
                )),
            IconButton(
                onPressed: () => navigationTapped(3),
                icon: Icon(
                  Icons.favorite,
                  color: _page == 3 ? primaryColor : secondaryColor,
                )),
            IconButton(
                onPressed: () => navigationTapped(4),
                icon: Icon(
                  Icons.person,
                  color: _page == 4 ? primaryColor : secondaryColor,
                )),
          ],
        ),
        body: PageView(
          children: homescreenItems,
          physics: NeverScrollableScrollPhysics(),
          controller: pageController,
          onPageChanged: onPageChanged,
        ));
  }
}
